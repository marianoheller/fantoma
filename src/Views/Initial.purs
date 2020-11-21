module Views.Initial (mkInitialView) where

import Prelude

import Components.FileUpload (mkFileUpload)
import Context (AppContext)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, ReactContext, component, useContext, (/\))
import React.Basic.Hooks as React
import Slice as S

mkInitialView :: ReactContext AppContext -> Component Unit
mkInitialView appContext = do
  fileUpload <- mkFileUpload
  component "Initial" \_ -> React.do
    _ /\ dispatch <- useContext appContext
    pure
      $ DOM.div_
          [ DOM.text "Initial view"
          , fileUpload
              { onFileUpload: dispatch <<< S.SetAudioUrl
              }
          ]
