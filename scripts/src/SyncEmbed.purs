module SyncEmbed (main) where

import Prelude

import Data.Either (Either(..))
import Data.String.Regex (regex, replace) as Regex
import Data.String.Regex.Flags (noFlags) as Regex
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Node.Encoding (Encoding(..))
import Node.FS.Perms (all, mkPerms)
import Node.FS.Sync (mkdir', readFile, readTextFile, writeFile, writeTextFile)

src :: String
src = "node_modules/@markgrafhq/markgraf-embed/dist"

dst :: String
dst = "assets"

main :: Effect Unit
main = do
  mkdir' dst { recursive: true, mode: mkPerms all all all }
  jsBuf <- readFile (src <> "/markgraf-embed.js")
  writeFile (dst <> "/markgraf-embed.js") jsBuf
  css <- readTextFile UTF8 (src <> "/markgraf-embed.css")
  stripped <- stripFontFace css
  writeTextFile UTF8 (dst <> "/markgraf-embed.css") stripped
  log "synced markgraf-embed.{js,css} (font-face stripped)"

-- The embed CSS ships an @font-face with a relative url() which, when
-- injected as a content-script stylesheet, resolves against the page
-- origin (github.com) and trips the page's font-src CSP. content.js
-- installs a replacement pointing at chrome.runtime.getURL().
stripFontFace :: String -> Effect String
stripFontFace css = case Regex.regex "@font-face\\s*\\{[^}]*\\}\\s*" Regex.noFlags of
  Left err -> throw ("invalid regex: " <> err)
  Right r -> pure (Regex.replace r "" css)
