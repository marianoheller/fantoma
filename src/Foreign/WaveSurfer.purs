module Foreign.WaveSurfer (WaveSurfer, WaveSurferConfig, create, play, pause, destroy) where

import Prelude
import Effect (Effect)
import Web.DOM (Element)

data WaveSurfer
  = WaveSurfer

type WaveSurferConfig
  = { container :: Element
    }

foreign import create :: WaveSurferConfig -> Effect WaveSurfer

foreign import play :: WaveSurfer -> Effect Unit

foreign import pause :: WaveSurfer -> Effect Unit

foreign import destroy :: WaveSurfer -> Effect Unit
