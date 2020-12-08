module Views.Home where

import Prelude

import Components.Controls (mkControls)
import Components.FileUpload (mkFileUpload)
import Components.PlaybackOptions (mkPlaybackOptions)
import Components.Player (mkPlayer)
import Components.VoiceRecorder (mkVoiceRecorder)
import Effect.Class.Console (warn)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, empty, useContext, (/\))
import React.Basic.Hooks as React
import Slice as S
import Store (storeContext)

mkHomeView :: Component Unit
mkHomeView = do
  player <- mkPlayer
  fileUpload <- mkFileUpload
  controls <- mkControls
  playbackOptions <- mkPlaybackOptions
  voiceRecorder <- mkVoiceRecorder
  component "Home" \_ -> React.do
    appState /\ dispatch <- useContext storeContext
    pure
      $ case appState of
          S.NotInitialized -> empty
          S.Initialized state ->
            DOM.div_
              [ player
                  { murl: state.audioUrl
                  , status: state.appStatus
                  , onSeek:
                      case _ of
                        0.0 -> dispatch S.StopAudio
                        _ -> dispatch S.PauseAudio
                  , onReady: dispatch S.FinishLoading
                  , onFinish: dispatch S.StopAudio
                  , onRegionFinish: dispatch S.StopAudio
                  }
              , fileUpload
                  { onFileUpload: dispatch <<< S.SetAudioUrl
                  , disabled: S.selectIsNidle appState
                  }
              , controls
                  { onPlay: dispatch S.PlayAudio
                  , onStop: dispatch S.StopAudio
                  , isPlaying: S.selectIsAudioPlaying appState
                  , disabled: S.selectIsAudioControlDisabled appState
                  }
              , playbackOptions
                  { onChange: dispatch <<< S.SetPlaybackOption
                  , currentValue: state.playbackOption
                  , disabled: S.selectIsIdle appState
                  }
              , voiceRecorder
                  { onRecordingStart: pure unit
                  , onRecordingFinish: \str -> warn $ "GOT BLOB" <> str
                  , disabled: S.selectIsRecordingDisabled appState
                  }
              ]
