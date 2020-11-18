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

onSeek :: (Number -> Effect Unit) -> WaveSurfer -> Effect Unit
onSeek = on "seek"

onFinish :: (Unit -> Effect Unit) -> WaveSurfer -> Effect Unit
onFinish = on "finish"

onPause :: (Unit -> Effect Unit) -> WaveSurfer -> Effect Unit
onPause = on "pause"
