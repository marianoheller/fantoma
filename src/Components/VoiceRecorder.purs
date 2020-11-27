module Components.VoiceRecorder (mkVoiceRecorder) where

import Prelude
import Effect (Effect)
import Hooks.VoiceRecorder (useVoiceRecorder)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, (/\))
import React.Basic.Hooks as React

type VoiceRecorderProps
  = { onRecordingFinish :: String -> Effect Unit
    , onRecordingStart :: Effect Unit
    }

mkVoiceRecorder :: Component VoiceRecorderProps
mkVoiceRecorder =
  component "VoiceRecorder" \_ -> React.do
    { mUrl, isRecording, start, stop } <- useVoiceRecorder
    let
      action /\ label = case isRecording of
        true -> stop /\ "Stop"
        false -> start /\ "Record"
    pure
      $ DOM.div_
          [ DOM.button
              { onClick: handler currentTarget (\_ -> action)
              , children: [ DOM.text label ]
              }
          ]
