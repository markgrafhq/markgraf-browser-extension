module Pack (main) where

import Prelude

import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Markgraf.Extension.Scripts.ChildProcess (spawnSync)
import Markgraf.Extension.Scripts.Json (getStringField, parse)
import Node.Encoding (Encoding(..))
import Node.FS.Perms (all, mkPerms)
import Node.FS.Sync (mkdir', rm')
import Node.FS.Sync (readTextFile) as FS

main :: Effect Unit
main = do
  pkg <- FS.readTextFile UTF8 "package.json" >>= parse
  let version = getStringField "version" pkg
  let out = "dist/markgraf-browser-extension-" <> version <> ".zip"
  mkdir' "dist" { recursive: true, mode: mkPerms all all all }
  rm' out { force: true, maxRetries: 0, recursive: false, retryDelay: 0 }
  status <- spawnSync "zip"
    [ "-r", out
    , "manifest.json"
    , "assets"
    , "extension.css"
    ]
  if status == 0 then log ("packed " <> out)
  else throw ("zip exited with status " <> show status)
