module Markgraf.Extension.Platform
  ( runtimeGetURL
  , queueMicrotask
  , TryParseFn
  , lookupTryParse
  , callTryParse
  , replaceWith
  , ParseResult
  , parseOk
  , outerCodeContainer
  , mountEmbed
  , ViewportObserver
  , newViewportObserver
  , observeElement
  , unobserveElement
  , requestIdle
  , loadFontThen
  , clickElement
  , classListToggle
  , setInnerHTML
  , addClickListener
  ) where

import Prelude

import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Web.DOM.Element (Element)

foreign import runtimeGetURLImpl :: String -> Effect String

runtimeGetURL :: String -> Effect String
runtimeGetURL = runtimeGetURLImpl

foreign import queueMicrotaskImpl :: Effect Unit -> Effect Unit

queueMicrotask :: Effect Unit -> Effect Unit
queueMicrotask = queueMicrotaskImpl

foreign import data TryParseFn :: Type
foreign import data ParseResult :: Type

foreign import windowMarkgrafTryParseFnImpl :: Effect (Nullable TryParseFn)

lookupTryParse :: Effect (Maybe TryParseFn)
lookupTryParse = toMaybe <$> windowMarkgrafTryParseFnImpl

foreign import callTryParseImpl :: TryParseFn -> String -> Effect ParseResult

callTryParse :: TryParseFn -> String -> Effect ParseResult
callTryParse = callTryParseImpl

foreign import replaceWithImpl :: Element -> Element -> Effect Unit

replaceWith :: Element -> Element -> Effect Unit
replaceWith = replaceWithImpl

foreign import parseOkImpl :: ParseResult -> Boolean

parseOk :: ParseResult -> Boolean
parseOk = parseOkImpl

foreign import outerCodeContainerImpl :: Element -> Effect Element

outerCodeContainer :: Element -> Effect Element
outerCodeContainer = outerCodeContainerImpl

foreign import mountEmbedImpl :: Element -> String -> Effect Unit

mountEmbed :: Element -> String -> Effect Unit
mountEmbed = mountEmbedImpl

foreign import data ViewportObserver :: Type

foreign import newViewportObserverImpl :: Int -> (Element -> Effect Unit) -> Effect ViewportObserver

newViewportObserver :: Int -> (Element -> Effect Unit) -> Effect ViewportObserver
newViewportObserver = newViewportObserverImpl

foreign import observeElementImpl :: ViewportObserver -> Element -> Effect Unit

observeElement :: ViewportObserver -> Element -> Effect Unit
observeElement = observeElementImpl

foreign import unobserveElementImpl :: ViewportObserver -> Element -> Effect Unit

unobserveElement :: ViewportObserver -> Element -> Effect Unit
unobserveElement = unobserveElementImpl

foreign import requestIdleImpl :: Effect Unit -> Effect Unit

requestIdle :: Effect Unit -> Effect Unit
requestIdle = requestIdleImpl

foreign import loadFontThenImpl :: String -> Effect Unit -> Effect Unit

loadFontThen :: String -> Effect Unit -> Effect Unit
loadFontThen = loadFontThenImpl

foreign import clickElementImpl :: Element -> Effect Unit

clickElement :: Element -> Effect Unit
clickElement = clickElementImpl

foreign import classListToggleImpl :: String -> Element -> Effect Unit

classListToggle :: String -> Element -> Effect Unit
classListToggle = classListToggleImpl

foreign import setInnerHTMLImpl :: String -> Element -> Effect Unit

setInnerHTML :: String -> Element -> Effect Unit
setInnerHTML = setInnerHTMLImpl

foreign import addClickListenerImpl :: Element -> Effect Unit -> Effect Unit

addClickListener :: Element -> Effect Unit -> Effect Unit
addClickListener = addClickListenerImpl
