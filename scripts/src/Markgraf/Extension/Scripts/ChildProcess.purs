module Markgraf.Extension.Scripts.ChildProcess (spawnSync) where

import Effect (Effect)

foreign import spawnSyncImpl :: String -> Array String -> Effect Int

spawnSync :: String -> Array String -> Effect Int
spawnSync = spawnSyncImpl
