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
  , installLazyMount
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

foreign import installLazyMountImpl :: Effect Unit

installLazyMount :: Effect Unit
installLazyMount = installLazyMountImpl
