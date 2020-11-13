module Components.Player where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Nullable (notNull, null)
import Foreign.WaveSurfer as WS
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, readRefMaybe, useEffect, useRef, writeRef, (/\))
import React.Basic.Hooks as React
import Web.DOM.Element (fromNode)

type PlayerProps
  = { murl :: Maybe String }

mkPlayer :: Component PlayerProps
mkPlayer = do
  component "Player" \{ murl } -> React.do
    divRef <- useRef null
    wsRef <- useRef null
    useEffect unit do
      mElem <- ((=<<) fromNode) <$> (readRefMaybe divRef)
      case mElem of
        Nothing -> pure (pure unit)
        Just ele -> do
          ws <- WS.create { container: ele }
          writeRef wsRef $ notNull ws
          pure (WS.destroy ws)
    useEffect murl do
      mws <- readRefMaybe wsRef
      case mws /\ murl of
        Just ws /\ Just url-> do
          WS.load url ws
          pure (pure unit)
        _ -> pure (pure unit)
    pure
      $ DOM.div { ref: divRef }
