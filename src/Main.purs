module Main where

import Prelude
import Context (AppContext, mkAppContext, mkStoreProvider)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.Hooks (Component, ReactContext, component, fragment, useContext, (/\))
import React.Basic.Hooks as React
import Slice (AppState(..))
import Views.Home (mkHomeView)
import Views.Initial (mkInitialView)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toElement)
import Web.HTML.Window (document)

mkInnerApp :: ReactContext AppContext -> Component Unit
mkInnerApp appContext = do
  initialView <- mkInitialView appContext
  homeView <- mkHomeView appContext
  component "InnerApp" \props -> React.do
    appState /\ _ <- useContext appContext
    pure
      $ fragment
          [ case appState of
              NotInitialized -> initialView unit
              Initialized _ -> homeView unit
          ]

mkApp :: Component Unit
mkApp = do
  appContext <- mkAppContext
  storeProvider <- mkStoreProvider appContext
  innerApp <- mkInnerApp appContext
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
