module Components.PlaybackOptions (mkPlaybackOptions) where

import Prelude
import Data.Foldable (for_)
import Effect (Effect)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, fragment)
import Slice as S
import Web.HTML.HTMLInputElement as HTMLInputElement

type PlaybackOptionsProps
  = { currentValue :: S.PlaybackOption
    , onChange :: S.PlaybackOption -> Effect Unit
    , disabled :: Boolean
    }

mkPlaybackOptions :: Component PlaybackOptionsProps
mkPlaybackOptions = do
  component "PlaybackOptions" \{ currentValue, onChange, disabled } -> React.do
    let
      vals = [ S.PlaybackVoice, S.PlaybackAudio ]

      handleChange v t =
        for_ (HTMLInputElement.fromEventTarget t) \input -> do
          isChecked <- HTMLInputElement.checked input
          onChange (if isChecked then v else S.NoPlayback)
    pure
      $ fragment
      $ ( \v ->
            DOM.label
              { children:
                  [ DOM.input
                      { type: "checkbox"
                      , name: show v
                      , checked: v == currentValue
                      , onClick: handler currentTarget $ handleChange v
                      , disabled
                      }
                  , DOM.text $ show v
                  ]
              }
        )
      <$> vals
