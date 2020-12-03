module Components.Player where

import Prelude
import Data.Foldable (for_, sequence_)
import Data.Maybe (Maybe(..))
import Data.Nullable (notNull, null)
import Effect (Effect)
import Foreign.WaveSurfer as WS
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, readRefMaybe, useEffect, useRef, useState', writeRef, (/\))
import React.Basic.Hooks as React
import Slice as S
import Web.DOM.Element (fromNode)

type PlayerProps
  = { murl :: Maybe String
    , status :: S.AppStatus
    , onSeek :: Number -> Effect Unit
    , onReady :: Effect Unit
    , onFinish :: Effect Unit
    , onRegionFinish :: Effect Unit
    }

mkPlayer :: Component PlayerProps
mkPlayer = do
  component "Player" \{ murl, status, onSeek, onReady, onFinish, onRegionFinish } -> React.do
    divRef <- useRef null
    wsRef <- useRef null
    minPxPerSec /\ setMinPxPerSec <- useState' 0.0
    -- on mount
    useEffect unit do
      mElem <- ((=<<) fromNode) <$> (readRefMaybe divRef)
      for_ mElem \ele -> do
        ws <- WS.create { container: ele }
        WS.onReady (sequence_ [ setMinPxPerSec $ WS.minPxPerSec ws, onReady ]) ws
        WS.onSeek onSeek ws
        WS.onFinish onFinish ws
        WS.onRegionFinish onRegionFinish ws
        writeRef wsRef $ notNull ws
      pure do
        mws <- readRefMaybe wsRef
        for_ mws \ws -> WS.destroy ws
    -- on url change
    useEffect murl do
      mws <- readRefMaybe wsRef
      case mws /\ murl of
        Just ws /\ Just url -> do
          WS.load url ws
          pure (pure unit)
        _ -> pure (pure unit)
    -- on player status change
    useEffect status do
      mws <- readRefMaybe wsRef
      case mws /\ status of
        Just ws /\ S.Nidle S.AudioPlaying -> do
          WS.playRegion ws
          pure (pure unit)
        Just ws /\ S.Idle -> do
          WS.stop ws
          pure (pure unit)
        Just ws /\ S.Nidle S.AudioPaused -> do
          WS.pause ws
          pure (pure unit)
        _ -> pure (pure unit)
    pure
      $ DOM.div { ref: divRef }
