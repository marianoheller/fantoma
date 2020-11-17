module Components.Player where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Nullable (notNull, null)
import Effect (Effect)
import Foreign.WaveSurfer as WS
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, readRefMaybe, useEffect, useRef, writeRef, (/\))
import React.Basic.Hooks as React
import Slice as S
import Web.DOM.Element (fromNode)

type PlayerProps
  = { murl :: Maybe String
    , status :: S.Status
    , onSeek :: Number -> Effect Unit
    }

mkPlayer :: Component PlayerProps
mkPlayer = do
  component "Player" \{ murl, status, onSeek } -> React.do
    divRef <- useRef null
    wsRef <- useRef null
    useEffect unit do
      mElem <- ((=<<) fromNode) <$> (readRefMaybe divRef)
      case mElem of
        Nothing -> pure (pure unit)
        Just ele -> do
          ws <- WS.create { container: ele }
          _ <- WS.onSeek onSeek ws
          writeRef wsRef $ notNull ws
          pure (WS.destroy ws)
    useEffect murl do
      mws <- readRefMaybe wsRef
      case mws /\ murl of
        Just ws /\ Just url -> do
          WS.load url ws
          pure (pure unit)
        _ -> pure (pure unit)
    useEffect status do
      mws <- readRefMaybe wsRef
      case mws /\ status of
        Just ws /\ S.Playing -> do
          WS.playRegion ws
          pure (pure unit)
        Just ws /\ S.Stopped -> do
          WS.stop ws
          pure (pure unit)
        Just ws /\ S.Paused -> do
          WS.pause ws
          pure (pure unit)
        _ -> pure (pure unit)
    pure
      $ DOM.div { ref: divRef }
