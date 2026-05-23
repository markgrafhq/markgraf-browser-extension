module Markgraf.Extension.Scripts.Json
  ( Json
  , parse
  , stringify
  , getStringField
  , setStringField
  ) where

import Prelude

import Effect (Effect)

foreign import data Json :: Type

foreign import parseImpl :: String -> Effect Json

parse :: String -> Effect Json
parse = parseImpl

foreign import stringifyImpl :: Json -> Int -> Effect String

stringify :: Int -> Json -> Effect String
stringify indent value = stringifyImpl value indent

foreign import getStringFieldImpl :: String -> Json -> String

getStringField :: String -> Json -> String
getStringField = getStringFieldImpl

foreign import setStringFieldImpl :: String -> String -> Json -> Effect Unit

setStringField :: String -> String -> Json -> Effect Unit
setStringField = setStringFieldImpl
