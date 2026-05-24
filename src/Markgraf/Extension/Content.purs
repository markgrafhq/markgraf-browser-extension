module Markgraf.Extension.Content (main) where

import Prelude

import Data.Array (any, null)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.String as String
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Ref as Ref
import Markgraf.Extension.Platform (callMountAll, callTryParse, lookupMountAll, lookupTryParse, outerCodeContainer, parseOk, pauseAllEmbeds, queueMicrotask, replaceWith, runtimeGetURL)
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.Document (Document, createElement, toNonElementParentNode, toParentNode)
import Web.DOM.Element (Element, closest, getAttribute, setAttribute, setClassName, setId, tagName, toNode)
import Web.DOM.Element as Element
import Web.DOM.MutationObserver (mutationObserver, observe)
import Web.DOM.MutationRecord (MutationRecord, addedNodes, target)
import Web.DOM.Node (Node, appendChild, parentElement, setTextContent, textContent)
import Web.DOM.NodeList (toArray)
import Web.DOM.NonElementParentNode (getElementById)
import Web.DOM.ParentNode (QuerySelector(..), querySelector, querySelectorAll)
import Web.HTML (window)
import Web.HTML.HTMLDocument (documentElement, head, toDocument)
import Web.HTML.HTMLElement (toNode) as HTMLElement
import Web.HTML.HTMLHtmlElement (toNode) as HTMLHtmlElement
import Web.HTML.Window (document)

-- | GitHub preserves the fence language hint as `lang="markgraf"` on the
-- | rendered element — match it directly instead of guessing by content.
preSelector :: String
preSelector = ".markdown-body [lang=\"markgraf\"], .comment-body [lang=\"markgraf\"]"

main :: Effect Unit
main = do
  installFontFace
  _ <- transform
  mountPending
  observeMutations

observeMutations :: Effect Unit
observeMutations = do
  doc <- toDocument <$> (window >>= document)
  nl <- querySelectorAll (QuerySelector ".markdown-body, .comment-body") (toParentNode doc)
  containers <- toArray nl
  scheduled <- Ref.new false
  observer <- mutationObserver \records _ -> do
    added <- recordsAddedAny records
    when added (schedule scheduled)
  for_ containers \node ->
    observe node { childList: true, subtree: true } observer

schedule :: Ref.Ref Boolean -> Effect Unit
schedule scheduled = do
  already <- Ref.read scheduled
  when (not already) do
    Ref.write true scheduled
    queueMicrotask do
      Ref.write false scheduled
      changed <- transform
      when changed mountPending

-- | True if any record adds nodes AND the mutation isn't happening inside
-- | an already-mounted markgraf player (whose tick-by-tick DOM churn would
-- | otherwise re-trigger transform on every animation frame).
recordsAddedAny :: Array MutationRecord -> Effect Boolean
recordsAddedAny records = do
  flags <- traverse hasAddedOutsidePlayer records
  pure (any identity flags)
  where
  hasAddedOutsidePlayer r = do
    nodes <- addedNodes r
    arr <- toArray nodes
    if null arr then pure false
    else do
      inside <- targetInsidePlayer r
      pure (not inside)
  targetInsidePlayer r = do
    t <- target r
    me <- case Element.fromNode t of
      Just el -> pure (Just el)
      Nothing -> parentElement t
    case me of
      Nothing -> pure false
      Just el -> isJust <$> closest (QuerySelector "[data-markgraf]") el

installFontFace :: Effect Unit
installFontFace = do
  htmlDoc <- window >>= document
  let doc = toDocument htmlDoc
  existing <- getElementById "markgraf-fontface" (toNonElementParentNode doc)
  when (not (isJust existing)) do
    style <- createElement "style" doc
    setId "markgraf-fontface" style
    url <- runtimeGetURL "assets/CommitMono-Regular.woff2"
    let css = "@font-face{font-family:'CommitMono';src:url('" <> url <> "') format('woff2');font-weight:400;font-display:swap;}"
    setTextContent css (toNode style)
    target <- fontFaceTarget
    _ <- appendChild (toNode style) target
    pure unit
  where
  fontFaceTarget = do
    htmlDoc <- window >>= document
    mh <- head htmlDoc
    case mh of
      Just h -> pure (HTMLElement.toNode h)
      Nothing -> do
        mde <- documentElement htmlDoc
        let de = fromMaybe (unsafeCoerce unit) mde
        pure (HTMLHtmlElement.toNode de)

transform :: Effect Boolean
transform = do
  doc <- toDocument <$> (window >>= document)
  nl <- querySelectorAll (QuerySelector preSelector) (toParentNode doc)
  pres <- toArray nl
  results <- traverse (tryReplacePre doc <<< nodeToElement) pres
  pure (any identity results)

nodeToElement :: Node -> Element
nodeToElement = unsafeCoerce

tryReplacePre :: Document -> Element -> Effect Boolean
tryReplacePre doc pre = do
  already <- getAttribute "data-markgraf-replaced" pre
  case already of
    Just "1" -> pure false
    _ -> do
      src <- sourceOf pre
      shouldReplace <- decide src
      if not shouldReplace then pure false
      else do
        div <- createElement "div" doc
        setClassName "markgraf-embed markgraf-gh" div
        setAttribute "data-markgraf" "" div
        setAttribute "data-markgraf-paused" "true" div
        setAttribute "data-markgraf-replaced" "1" div
        setTextContent src (toNode div)
        host <- outerCodeContainer pre
        replaceWith host div
        pure true
  where
  decide src
    | String.trim src == "" = pure false
    | otherwise = confirmParse src

sourceOf :: Element -> Effect String
sourceOf pre = do
  target <-
    if tagName pre == "PRE" then do
      mInner <- querySelector (QuerySelector "code") (Element.toParentNode pre)
      pure (fromMaybe pre mInner)
    else pure pre
  textContent (toNode target)

-- | Confirm via the embed bundle's parser; if the bundle hasn't exposed
-- | itself yet, trust the lang-attribute selector this pass and let
-- | auto-mount pick up the resulting divs synchronously.
confirmParse :: String -> Effect Boolean
confirmParse src = do
  mFn <- lookupTryParse
  case mFn of
    Nothing -> pure true
    Just fn -> parseOk <$> callTryParse fn src

mountPending :: Effect Unit
mountPending = do
  mFn <- lookupMountAll
  for_ mFn \fn -> do
    callMountAll fn
    pauseAllEmbeds
