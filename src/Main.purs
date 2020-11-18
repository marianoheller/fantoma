module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.Hooks (Component, component, mkReducer, useReducer, (/\))
import React.Basic.Hooks as React
import Slice (AppState(..))
import Slice as S
import Views.Home (mkHomeView)
import Views.Initial (mkInitialView)
import Web.HTML (window)
import Web.HTML.HTMLDocument (body)
import Web.HTML.HTMLElement (toElement)
import Web.HTML.Window (document)

mkApp :: Component {}
mkApp = do
  reducer' <- mkReducer S.reducer
  initialView <- mkInitialView
  homeView <- mkHomeView
  component "App" \props -> React.do
    appState /\ dispatch <- useReducer S.initialState reducer'
    pure $ case appState of
      NotInitialized -> initialView { dispatch }
      (Initialized state) -> homeView { dispatch, state }

main :: Effect Unit
main = do
  mBody <- body =<< document =<< window
  case mBody of
    Nothing -> throw "Could not find body."
    Just b -> do
      app <- mkApp
      render (app {}) (toElement b)
