module Context where

import Prelude
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class.Console (error)
import React.Basic.Hooks (Component, JSX, ReactContext, component, createContext, mkReducer, provider, useReducer)
import React.Basic.Hooks as React
import Slice as S

type AppContext
  = (S.AppState /\ (S.AppAction -> Effect Unit))

mkAppContext :: Effect (ReactContext AppContext)
mkAppContext = createContext (S.initialState /\ (\_ -> error "Context not initialized"))

mkStoreProvider :: ReactContext AppContext -> Component (Array JSX)
mkStoreProvider appContext = do
  reducer' <- mkReducer S.reducer
  component "StoreProvider" \content -> React.do
    value <- useReducer S.initialState reducer'
    pure
      $ provider appContext value content
