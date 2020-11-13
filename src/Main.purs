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

url :: String
url = "https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3"

onFileUpload :: String -> Effect Unit
onFileUpload blobUrl = do
  log $ "GOT BLOB: " <> blobUrl
  pure unit

mkApp :: Component {}
mkApp = do
  player <- mkPlayer
  fileUpload <- mkFileUpload
  component "Clock" \props -> React.do
    blobUrl /\ setBlobUrl <- useState' url -- TODO: state shuold be Maybe String
    pure
      $ DOM.div_
          [ (player { url: blobUrl })
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
