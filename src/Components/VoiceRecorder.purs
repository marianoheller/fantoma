module Components.VoiceRecorder (mkVoiceRecorder) where

import Prelude
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class.Console (warn)
import Hooks.AudioPlayback (useAudioPlayback)
import Hooks.VoiceRecorder (useVoiceRecorder)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, useEffect, (/\))
import React.Basic.Hooks as React

type VoiceRecorderProps
  = { onRecordingFinish :: Effect Unit
    , onRecordingStart :: Effect Unit
    , onVoicePlay :: Effect Unit
    , onVoiceStop :: Effect Unit
    , disabled :: Boolean
    }

mkVoiceRecorder :: Component VoiceRecorderProps
mkVoiceRecorder =
  component "VoiceRecorder" \{ onRecordingStart, onRecordingFinish, onVoicePlay, onVoiceStop, disabled } -> React.do
    { mUrl: mUrlVoice, isRecording, start: starRecording, stop: stopRecording } <- useVoiceRecorder
    { mUrl: mUrlAudio, isPlaying, start: startPlaying, stop: stopPlaying, setMUrl: setAudioMUrl } <- useAudioPlayback
    useEffect mUrlVoice do
      setAudioMUrl mUrlVoice
      pure $ pure unit
    let
      actionR /\ labelR = case isRecording of
        true -> (stopRecording <> onRecordingFinish) /\ "Stop Recording"
        false -> (starRecording <> onRecordingStart) /\ "Start Recording"

      actionA /\ labelA = case isPlaying of
        true -> (stopPlaying <> onVoiceStop) /\ "Stop Playing"
        false -> (startPlaying <> onVoicePlay) /\ "Start Playing"
    pure
      $ DOM.div_
          [ DOM.button
              { onClick: handler currentTarget (\_ -> actionR)
              , children: [ DOM.text labelR ]
              , disabled: disabled || isPlaying
              }
          , DOM.button
              { onClick: handler currentTarget (\_ -> actionA)
              , children: [ DOM.text labelA ]
              , disabled: disabled || isRecording || mUrlVoice == Nothing
              }
          ]
