module Main where

import Prelude
import Components.FileUpload (mkFileUpload)
import Components.Player (mkPlayer)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, mkReducer, useReducer, (/\))
import React.Basic.Hooks as React
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toElement)
import Web.HTML.Window (document)
import Slice as S

mkApp :: Component {}
mkApp = do
  reducer' <- mkReducer S.reducer
  player <- mkPlayer
  fileUpload <- mkFileUpload
  component "App" \props -> React.do
    appState /\ dispatch <- useReducer S.initialState reducer'
    pure
      $ DOM.div_
          [ (player { murl: appState.audioUrl, status: appState.status })
          , fileUpload { onFileUpload: dispatch <<< S.SetAudioUrl }
          ]

main :: Effect Unit
main = do
  mBody <- body =<< document =<< window
  case mBody of
    Nothing -> throw "Could not find body."
    Just b -> do
      app <- mkApp
      render (app {}) (toElement b)
