module Views.Home where

import Prelude
import Components.Controls (mkControls)
import Components.FileUpload (mkFileUpload)
import Components.Player (mkPlayer)
import Store (storeContext)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, empty, useContext, (/\))
import React.Basic.Hooks as React
import Slice (AppState(..))
import Slice as S

mkHomeView :: Component Unit
mkHomeView = do
  player <- mkPlayer
  fileUpload <- mkFileUpload
  controls <- mkControls
  component "Home" \_ -> React.do
    appState /\ dispatch <- useContext storeContext
    pure
      $ case appState of
          NotInitialized -> empty
          Initialized state ->
            DOM.div_
              [ player
                  { murl: state.audioUrl
                  , status: state.status
                  , onSeek:
                      case _ of
                        0.0 -> dispatch S.StopAudio
                        _ -> dispatch S.PauseAudio
                  , onFinish: dispatch S.StopAudio
                  , onRegionFinish: dispatch S.StopAudio
                  }
              , fileUpload
                  { onFileUpload: dispatch <<< S.SetAudioUrl
                  }
              , controls
                  { onPlay: dispatch S.PlayAudio
                  , onStop: dispatch S.StopAudio
                  }
              ]
