module Main where

import Prelude
import Components.Spinner (mkSpinner)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import React.Basic.Hooks (Component, component, fragment, useContext, (/\))
import React.Basic.Hooks as React
import Slice (AppState(..), selectIsLoading)
import Store (storeContext, mkStoreProvider)
import Views.Home (mkHomeView)
import Views.Initial (mkInitialView)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

mkApp :: Component Unit
mkApp = do
  initialView <- mkInitialView
  homeView <- mkHomeView
  spinner <- mkSpinner
  component "App" \props -> React.do
    appState /\ _ <- useContext storeContext
    pure
      $ fragment
          [ case appState of
              NotInitialized -> initialView unit
              Initialized _ -> homeView unit
          , spinner { isLoading: selectIsLoading appState }
          ]

mkWrappedApp :: Component Unit
mkWrappedApp = do
  storeProvider <- mkStoreProvider
  app <- mkApp
  component "WrappedApp" \props -> React.do
    pure $ storeProvider [ app unit ]

main :: Effect Unit
main = do
  mContainer <- getElementById "root" =<< (toNonElementParentNode <$> (document =<< window))
  case mContainer of
    Nothing -> throw "Could not find body."
    Just container -> do
      app <- mkWrappedApp
      render (app unit) container
