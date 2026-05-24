module Markgraf.Extension.Content (main) where

import Prelude

import Data.Array (any, null)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.String as String
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Ref as Ref
import Markgraf.Extension.Platform (addClickListener, callTryParse, classListToggle, clickElement, loadFontThen, lookupTryParse, mountEmbed, newViewportObserver, observeElement, outerCodeContainer, parseOk, queueMicrotask, replaceWith, requestIdle, runtimeGetURL, setInnerHTML, unobserveElement)
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

preSelector :: String
preSelector = ".markdown-body [lang=\"markgraf\"], .comment-body [lang=\"markgraf\"]"

fontSpec :: String
fontSpec = "12px \"CommitMono\""

codeBracketSvg :: String
codeBracketSvg =
  "<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\""
    <> " stroke-width=\"1.75\" stroke=\"currentColor\" aria-hidden=\"true\">"
    <> "<path stroke-linecap=\"round\" stroke-linejoin=\"round\""
    <> " d=\"M17.25 6.75 22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3-4.5 16.5\"/></svg>"

main :: Effect Unit
main = do
  installFontFace
  _ <- transform
  installLazyMount
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
      when changed installLazyMount

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
    fontHost <- fontFaceTarget
    _ <- appendChild (toNode style) fontHost
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
        embed <- buildEmbed src
        host <- outerCodeContainer pre
        replaceWith host embed
        pure true
  where
  decide src
    | String.trim src == "" = pure false
    | otherwise = confirmParse src

  buildEmbed src = do
    div <- createElement "div" doc
    setClassName "markgraf-embed markgraf-gh" div
    setAttribute "data-markgraf" "" div
    setAttribute "data-markgraf-replaced" "1" div
    setAttribute "data-markgraf-src" src div
    setAttribute "data-markgraf-mounted" "1" div
    setAttribute "data-markgraf-lazy" "pending" div
    placeholder <- createElement "pre" doc
    setClassName "markgraf-source markgraf-placeholder" placeholder
    setTextContent src (toNode placeholder)
    _ <- appendChild (toNode placeholder) (toNode div)
    pure div

sourceOf :: Element -> Effect String
sourceOf pre = do
  inside <-
    if tagName pre == "PRE" then do
      mInner <- querySelector (QuerySelector "code") (Element.toParentNode pre)
      pure (fromMaybe pre mInner)
    else pure pre
  textContent (toNode inside)

confirmParse :: String -> Effect Boolean
confirmParse src = do
  mFn <- lookupTryParse
  case mFn of
    Nothing -> pure true
    Just fn -> parseOk <$> callTryParse fn src

installLazyMount :: Effect Unit
installLazyMount = do
  doc <- toDocument <$> (window >>= document)
  nl <- querySelectorAll (QuerySelector "[data-markgraf-lazy='pending']") (toParentNode doc)
  pending <- toArray nl
  when (not (null pending)) do
    observerRef <- Ref.new Nothing
    observer <- newViewportObserver 300 (onEnter doc observerRef)
    Ref.write (Just observer) observerRef
    for_ pending (observeElement observer <<< nodeToElement)
  where
  onEnter doc observerRef el = do
    mObserver <- Ref.read observerRef
    for_ mObserver \io -> unobserveElement io el
    requestIdle (mountAndDecorate doc el)

mountAndDecorate :: Document -> Element -> Effect Unit
mountAndDecorate doc el = do
  state <- getAttribute "data-markgraf-lazy" el
  case state of
    Just "pending" -> do
      setAttribute "data-markgraf-lazy" "mounting" el
      loadFontThen fontSpec do
        src <- fromMaybe "" <$> getAttribute "data-markgraf-src" el
        mountEmbed el src
        setAttribute "data-markgraf-lazy" "done" el
        ensurePaused el
        installToggle doc el
    _ -> pure unit

ensurePaused :: Element -> Effect Unit
ensurePaused el = do
  mBtn <- querySelector (QuerySelector "[data-mg=\"play\"]") (Element.toParentNode el)
  for_ mBtn \btn -> do
    playing <- getAttribute "data-mg-playing" btn
    when (playing == Just "1") (clickElement btn)

installToggle :: Document -> Element -> Effect Unit
installToggle doc el = do
  already <- getAttribute "data-markgraf-toggle" el
  case already of
    Just "1" -> pure unit
    _ -> do
      setAttribute "data-markgraf-toggle" "1" el
      src <- fromMaybe "" <$> getAttribute "data-markgraf-src" el
      pre <- createElement "pre" doc
      setClassName "markgraf-source" pre
      setTextContent src (toNode pre)
      _ <- appendChild (toNode pre) (toNode el)
      btn <- createElement "button" doc
      setClassName "markgraf-source-toggle" btn
      setAttribute "type" "button" btn
      setAttribute "aria-label" "toggle source" btn
      setInnerHTML codeBracketSvg btn
      addClickListener btn (classListToggle "markgraf-show-source" el)
      _ <- appendChild (toNode btn) (toNode el)
      pure unit
