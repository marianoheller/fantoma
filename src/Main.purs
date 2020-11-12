module Main where

import Prelude
import Components.FileUpload (mkFileUpload)
import Components.Player (mkPlayer)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toElement)
import Web.HTML.Window (document)
import React.Basic.Hooks (Component, component)
import React.Basic.DOM as DOM

url :: String
url = "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3"

mkApp :: Component {}
mkApp = do
  player <- mkPlayer
  fileUpload <- mkFileUpload
  component "Clock" \props -> React.do
    pure
      $ DOM.div_
          [ (player { url })
          , fileUpload {}
          ]

main :: Effect Unit
main = do
  mBody <- body =<< document =<< window
  case mBody of
    Nothing -> throw "Could not find body."
    Just b -> do
      app <- mkApp
      render (app {}) (toElement b)
