module Components.Player where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Nullable (notNull, null)
import Effect.Class.Console (log)
import Foreign.WaveSurfer as WS
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, readRefMaybe, useEffect, useRef, writeRef)
import React.Basic.Hooks as React
import Web.DOM.Element (fromNode)

type PlayerProps
  = { url :: String }

mkPlayer :: Component PlayerProps
mkPlayer = do
  component "Surfer" \{ url } -> React.do
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
    useEffect url do
      mws <- readRefMaybe wsRef
      log $ "URL -> " <> url
      case mws of
        Nothing -> pure (pure unit)
        Just ws -> do
          WS.load url ws
          pure (pure unit)
    pure
      $ DOM.div { ref: divRef }
