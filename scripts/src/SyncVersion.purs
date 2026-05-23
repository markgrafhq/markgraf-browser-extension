module SyncVersion (main) where

import Prelude

import Effect (Effect)
import Effect.Class.Console (log)
import Markgraf.Extension.Scripts.Json (getStringField, parse, setStringField, stringify)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (readTextFile, writeTextFile)

main :: Effect Unit
main = do
  pkg <- readJson "package.json"
  manifest <- readJson "manifest.json"
  let version = getStringField "version" pkg
  let manifestVersion = getStringField "version" manifest
  if manifestVersion == version then
    log ("manifest.json already at " <> version)
  else do
    setStringField "version" version manifest
    serialised <- stringify 2 manifest
    writeTextFile UTF8 "manifest.json" (serialised <> "\n")
    log ("manifest.json -> " <> version)
  where
  readJson path = readTextFile UTF8 path >>= parse
