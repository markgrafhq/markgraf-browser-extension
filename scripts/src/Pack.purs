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

-- | Stages the extension's runtime files into dist/unpacked/ (so Chrome's
-- | "Load unpacked" gets a clean dir without node_modules/src/spago state)
-- | and zips the same staged tree into dist/markgraf-browser-extension-VER.zip.
main :: Effect Unit
main = do
  pkg <- FS.readTextFile UTF8 "package.json" >>= parse
  let version = getStringField "version" pkg
  let zipOut = "dist/markgraf-browser-extension-" <> version <> ".zip"
  let unpacked = "dist/unpacked"

  mkdir' "dist" { recursive: true, mode: mkPerms all all all }
  rm' unpacked { force: true, maxRetries: 0, recursive: true, retryDelay: 0 }
  rm' zipOut { force: true, maxRetries: 0, recursive: false, retryDelay: 0 }
  mkdir' unpacked { recursive: true, mode: mkPerms all all all }

  copyInto unpacked [ "manifest.json", "extension.css", "assets" ]
    >>= guardStatus "cp"

  spawnSync "sh" [ "-c", "cd " <> unpacked <> " && zip -r ../../" <> zipOut <> " ." ]
    >>= guardStatus "zip"

  log ("staged " <> unpacked <> " and packed " <> zipOut)
  where
  copyInto dst sources = spawnSync "cp" (["-R"] <> sources <> [dst])
  guardStatus what status =
    if status == 0 then pure unit
    else throw (what <> " exited with status " <> show status)
