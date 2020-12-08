module Components.Controls (mkControls) where

import Prelude
import Effect (Effect)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, fragment, (/\))

type ControlsProps
  = { onPlay :: Effect Unit
    , onStop :: Effect Unit
    , isPlaying :: Boolean
    , disabled :: Boolean
    }

mkControls :: Component ControlsProps
mkControls = do
  component "Controls" \{ onPlay, onStop, isPlaying, disabled } -> React.do
    let
      label /\ action = case isPlaying of
        true -> "Stop" /\ onStop
        false -> "Play" /\ onPlay
    pure
      $ fragment
          [ DOM.button
              { onClick: handler currentTarget (\_ -> action)
              , children: [ DOM.text label ]
              , disabled
              }
          ]
