module Views.Initial (mkInitialView) where

import Prelude

import Components.FileUpload (mkFileUpload)
import Effect (Effect)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component)
import Slice as S

type InitialViewProps = {
  dispatch :: S.AppAction -> Effect Unit
}

mkInitialView :: Component InitialViewProps
mkInitialView = do
  fileUpload <- mkFileUpload
  component "Initial" \{ dispatch } -> React.do
    pure
      $ DOM.div_
          [ DOM.text "LOAD FILE"
          , fileUpload
              { onFileUpload: dispatch <<< S.SetAudioUrl
              }
          ]
