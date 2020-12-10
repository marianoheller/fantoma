module Foreign.WaveSurfer where

import Prelude
import Effect (Effect)
import Web.DOM (Element)

data WaveSurfer
  = WaveSurfer

type WaveSurferConfig
  = { container :: Element
    }

foreign import create :: WaveSurferConfig -> Effect WaveSurfer

foreign import playRegion :: WaveSurfer -> Effect Unit

foreign import play :: WaveSurfer -> Effect Unit

foreign import pause :: WaveSurfer -> Effect Unit

foreign import playPause :: WaveSurfer -> Effect Unit

foreign import stop :: WaveSurfer -> Effect Unit

foreign import destroy :: WaveSurfer -> Effect Unit

foreign import load :: String -> WaveSurfer -> Effect Unit

foreign import on :: forall a. String -> (a -> Effect Unit) -> WaveSurfer -> Effect Unit

foreign import zoom :: Number -> WaveSurfer -> Effect Unit

foreign import minPxPerSec :: WaveSurfer -> Number

foreign import setCursorColor :: String -> WaveSurfer -> Effect Unit

foreign import clearRegions :: WaveSurfer -> Effect Unit

onSeek :: (Number -> Effect Unit) -> WaveSurfer -> Effect Unit
onSeek = on "seek"

onFinish :: Effect Unit -> WaveSurfer -> Effect Unit
onFinish cb = on "finish" \_ -> cb

onPause :: (Unit -> Effect Unit) -> WaveSurfer -> Effect Unit
onPause = on "pause"

onReady :: Effect Unit -> WaveSurfer -> Effect Unit
onReady cb = on "ready" \_ -> cb

onRegionFinish :: Effect Unit -> WaveSurfer -> Effect Unit
onRegionFinish cb = on "region-out" \_ -> cb
