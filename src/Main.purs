module Main where

import Prelude
import Components.FileUpload (mkFileUpload)
import Components.Player (mkPlayer)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (log)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, useState', (/\))
import React.Basic.Hooks as React
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toElement)
import Web.HTML.Window (document)

mkApp :: Component {}
mkApp = do
  player <- mkPlayer
  fileUpload <- mkFileUpload
  component "App" \props -> React.do
    blobUrl /\ setBlobUrl <- useState' (Nothing :: Maybe String)
    pure
      $ DOM.div_
          [ (player { murl: blobUrl })
          , fileUpload { onFileUpload: setBlobUrl }
          ]

main :: Effect Unit
main = do
  mBody <- body =<< document =<< window
  case mBody of
    Nothing -> throw "Could not find body."
    Just b -> do
      app <- mkApp
      render (app {}) (toElement b)
