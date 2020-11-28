module Main where

import Prelude
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.Hooks (Component, component, fragment, useContext, (/\))
import React.Basic.Hooks as React
import Slice (AppState(..))
import Store (storeContext, mkStoreProvider)
import Views.Home (mkHomeView)
import Views.Initial (mkInitialView)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
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
  mContainer <- getElementById "root" =<< (toNonElementParentNode <$> (document =<< window))
  case mContainer of
    Nothing -> throw "Could not find body."
    Just container -> do
      app <- mkApp
      render (app unit) container
