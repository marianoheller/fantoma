module Store where

import Prelude
import Data.Tuple.Nested (type (/\), (/\))
import Effect (Effect)
import Effect.Class.Console (error)
import Effect.Unsafe (unsafePerformEffect)
import React.Basic.Hooks (Component, JSX, ReactContext, component, createContext, mkReducer, provider, useReducer)
import React.Basic.Hooks as React
import Slice as S

type AppContext
  = (S.AppState /\ (S.AppAction -> Effect Unit))

storeContext :: ReactContext AppContext
storeContext = unsafePerformEffect $ createContext (S.initialState /\ (\_ -> error "Dispatching with storeContext not initialized"))

mkStoreProvider :: Component (Array JSX)
mkStoreProvider = do
  reducer' <- mkReducer S.reducer
  component "StoreProvider" \content -> React.do
    value <- useReducer S.initialState reducer'
    pure
      $ provider storeContext value content
