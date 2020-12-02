module Components.Spinner (mkSpinner) where

import Prelude
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, empty)

type SpinnerProps
  = { isLoading :: Boolean }

mkSpinner :: Component SpinnerProps
mkSpinner = do
  component "Spinner" \{ isLoading } -> React.do
    pure
      $ case isLoading of
          false -> empty
          true ->
            DOM.div
              { children: [ DOM.text "Loading..." ]
              , style:
                  DOM.css
                    { backgroundColor: "rgba(0, 0, 0, 0.5)"
                    , zIndex: "10"
                    , position: "fixed"
                    , top: "0"
                    , bottom: "0"
                    , left: "0"
                    , right: "0"
                    , display: "flex"
                    , justifyContent: "center"
                    , alignItems: "center"
                    }
              }
