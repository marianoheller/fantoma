module Main where

import Prelude
import Store (storeContext, mkStoreProvider)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.Hooks (Component, component, fragment, useContext, (/\))
import React.Basic.Hooks as React
import Slice (AppState(..))
import Views.Home (mkHomeView)
import Views.Initial (mkInitialView)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toElement)
import Web.HTML.Window (document)

mkInnerApp :: Component Unit
mkInnerApp = do
  initialView <- mkInitialView
  homeView <- mkHomeView
  component "InnerApp" \props -> React.do
    appState /\ _ <- useContext storeContext
    pure
      $ fragment
          [ case appState of
              NotInitialized -> initialView unit
              Initialized _ -> homeView unit
          ]

mkApp :: Component Unit
mkApp = do
  storeProvider <- mkStoreProvider
  innerApp <- mkInnerApp
  component "App" \props -> React.do
    pure $ storeProvider [ innerApp unit ]

main :: Effect Unit
main = do
  mBody <- body =<< document =<< window
  case mBody of
    Nothing -> throw "Could not find body."
    Just b -> do
      app <- mkApp
      render (app unit) (toElement b)
