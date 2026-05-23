module Markgraf.Extension.Platform
  ( runtimeGetURL
  , queueMicrotask
  , TryParseFn
  , MountAllFn
  , lookupTryParse
  , lookupMountAll
  , callTryParse
  , callMountAll
  , replaceWith
  , ParseResult
  , parseOk
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
foreign import data MountAllFn :: Type
foreign import data ParseResult :: Type

foreign import windowMarkgrafTryParseFnImpl :: Effect (Nullable TryParseFn)

lookupTryParse :: Effect (Maybe TryParseFn)
lookupTryParse = toMaybe <$> windowMarkgrafTryParseFnImpl

foreign import windowMarkgrafMountAllFnImpl :: Effect (Nullable MountAllFn)

lookupMountAll :: Effect (Maybe MountAllFn)
lookupMountAll = toMaybe <$> windowMarkgrafMountAllFnImpl

foreign import callTryParseImpl :: TryParseFn -> String -> Effect ParseResult

callTryParse :: TryParseFn -> String -> Effect ParseResult
callTryParse = callTryParseImpl

foreign import callMountAllImpl :: MountAllFn -> Effect Unit

callMountAll :: MountAllFn -> Effect Unit
callMountAll = callMountAllImpl

foreign import replaceWithImpl :: Element -> Element -> Effect Unit

replaceWith :: Element -> Element -> Effect Unit
replaceWith = replaceWithImpl

foreign import parseOkImpl :: ParseResult -> Boolean

parseOk :: ParseResult -> Boolean
parseOk = parseOkImpl
