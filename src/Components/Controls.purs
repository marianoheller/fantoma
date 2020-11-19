module Components.Controls (mkControls) where

import Prelude
import Effect (Effect)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, fragment)

type ControlsProps
  = { onPlay :: Effect Unit
    , onStop :: Effect Unit
    }

mkControls :: Component ControlsProps
mkControls = do
  component "Controls" \{ onPlay, onStop } -> React.do
    pure
      $ fragment
          [ DOM.button
              { onClick: handler currentTarget (\_ -> onPlay)
              , children: [ DOM.text "Play" ]
              }
          , DOM.button
              { onClick: handler currentTarget (\_ -> onStop)
              , children: [ DOM.text "Stop" ]
              }
          ]
