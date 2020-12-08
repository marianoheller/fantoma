module Views.Initial (mkInitialView) where

import Prelude

import Components.FileUpload (mkFileUpload)
import Store (storeContext)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, useContext, (/\))
import React.Basic.Hooks as React
import Slice as S

mkInitialView :: Component Unit
mkInitialView = do
  fileUpload <- mkFileUpload
  component "Initial" \_ -> React.do
    _ /\ dispatch <- useContext storeContext
    pure
      $ DOM.div_
          [ DOM.text "Initial view"
          , fileUpload
              { onFileUpload: dispatch <<< S.SetAudioUrl
              , disabled: false
              }
          ]
