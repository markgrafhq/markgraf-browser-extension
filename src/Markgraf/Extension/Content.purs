module Markgraf.Extension.Content (main) where

import Prelude

import Data.Array (any, null)
import Data.Either (Either(..))
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.String as String
import Data.String.Regex (Regex, regex, test) as Regex
import Data.String.Regex.Flags (multiline) as Regex
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Ref as Ref
import Markgraf.Extension.Platform (callMountAll, callTryParse, lookupMountAll, lookupTryParse, parseOk, queueMicrotask, replaceWith, runtimeGetURL)
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.Document (Document, createElement, toNonElementParentNode, toParentNode)
import Web.DOM.Element (Element, getAttribute, setAttribute, setClassName, setId, tagName, toNode)
import Web.DOM.Element as Element
import Web.DOM.MutationObserver (mutationObserver, observe)
import Web.DOM.MutationRecord (MutationRecord, addedNodes)
import Web.DOM.Node (Node, appendChild, setTextContent, textContent)
import Web.DOM.NodeList (toArray)
import Web.DOM.NonElementParentNode (getElementById)
import Web.DOM.ParentNode (QuerySelector(..), querySelector, querySelectorAll)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body, documentElement, head, toDocument)
import Web.HTML.HTMLElement (toNode) as HTMLElement
import Web.HTML.HTMLHtmlElement (toNode) as HTMLHtmlElement
import Web.HTML.Window (document)

containers :: String
containers = ".markdown-body, .comment-body"

shape :: Regex.Regex
shape = case Regex.regex pattern Regex.multiline of
  Right r -> r
  Left _ -> unsafeCoerce unit
  where
  pattern = "^\\s*(seed\\s+\\d|frame\\b|par\\s*\\{|seq\\s*\\{|[+-]node\\b|[+-]edge\\b)"

main :: Effect Unit
main = do
  installFontFace
  _ <- transform
  mountPending
  observeMutations

observeMutations :: Effect Unit
observeMutations = do
  htmlDoc <- window >>= document
  mb <- body htmlDoc
  for_ mb \el -> do
    scheduled <- Ref.new false
    observer <- mutationObserver \records _ -> do
      added <- recordsAddedAny records
      when added (schedule scheduled)
    observe (HTMLElement.toNode el) { childList: true, subtree: true } observer

schedule :: Ref.Ref Boolean -> Effect Unit
schedule scheduled = do
  already <- Ref.read scheduled
  when (not already) do
    Ref.write true scheduled
    queueMicrotask do
      Ref.write false scheduled
      changed <- transform
      when changed mountPending

recordsAddedAny :: Array MutationRecord -> Effect Boolean
recordsAddedAny records = do
  flags <- traverse hasAdded records
  pure (any identity flags)
  where
  hasAdded r = do
    nodes <- addedNodes r
    arr <- toArray nodes
    pure (not (null arr))

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
  nl <- querySelectorAll (QuerySelector (containers <> " pre")) (toParentNode doc)
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
        setAttribute "data-markgraf-replaced" "1" div
        setTextContent src (toNode div)
        replaceWith pre div
        pure true
  where
  decide src
    | String.trim src == "" = pure false
    | not (Regex.test shape src) = pure false
    | otherwise = confirmParse src

sourceOf :: Element -> Effect String
sourceOf pre = do
  target <-
    if tagName pre == "PRE" then do
      mInner <- querySelector (QuerySelector "code") (Element.toParentNode pre)
      pure (fromMaybe pre mInner)
    else pure pre
  textContent (toNode target)

confirmParse :: String -> Effect Boolean
confirmParse src = do
  -- window.markgraf is set by the embed bundle running in the same
  -- isolated world; if not yet present, trust the regex this pass and
  -- let the bundle's auto-mount pick up the divs synchronously.
  mFn <- lookupTryParse
  case mFn of
    Nothing -> pure true
    Just fn -> parseOk <$> callTryParse fn src

mountPending :: Effect Unit
mountPending = do
  mFn <- lookupMountAll
  for_ mFn callMountAll
