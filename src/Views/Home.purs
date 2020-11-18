module Views.Home where

import Prelude
import Components.Controls (mkControls)
import Components.FileUpload (mkFileUpload)
import Components.Player (mkPlayer)
import Effect (Effect)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component)
import Slice as S

type HomeViewProps
  = { dispatch :: S.AppAction -> Effect Unit
    , state :: S.InternalState
    }

mkHomeView :: Component HomeViewProps
mkHomeView = do
  player <- mkPlayer
  fileUpload <- mkFileUpload
  controls <- mkControls
  component "Home" \{ dispatch, state } -> React.do
    pure
      $ DOM.div_
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
