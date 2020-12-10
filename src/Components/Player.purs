module Components.Player where

import Prelude hiding (max)
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Nullable (notNull, null)
import Data.Tuple (Tuple)
import Effect (Effect)
import Foreign.WaveSurfer as WS
import Math (max)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (stopPropagation)
import React.Basic.Events (EventFn, SyntheticEvent, handler, unsafeEventFn)
import React.Basic.Hooks (Component, component, readRefMaybe, useEffect, useRef, useState, writeRef, (/\))
import React.Basic.Hooks as React
import Slice as S
import Unsafe.Coerce (unsafeCoerce)
import Web.DOM.Element (fromNode)
import Web.UIEvent.WheelEvent (WheelEvent, deltaY)

targetWheelEvent :: EventFn SyntheticEvent WheelEvent
targetWheelEvent = unsafeEventFn \e -> unsafeCoerce e

calcZoom :: Number -> Tuple Number Number -> Tuple Number Number
calcZoom delta (currenPx /\ minPx) =
  let
    calced = currenPx + delta

    px = max calced minPx
  in
    (px /\ minPx)

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
    (pxPerSec /\ minPxPerSec) /\ setPxPerSec <- useState (0.0 /\ 0.0)
    -- on mount
    useEffect unit do
      mElem <- ((=<<) fromNode) <$> (readRefMaybe divRef)
      for_ mElem \ele -> do
        ws <- WS.create { container: ele }
        WS.onReady
          ( do
              let
                minPx = WS.minPxPerSec ws
              setPxPerSec (\_ -> minPx /\ minPx)
              onReady
          )
          ws
        WS.onSeek onSeek ws
        WS.onFinish onFinish ws
        WS.onRegionFinish onRegionFinish ws
        writeRef wsRef $ notNull ws
      pure do
        mws <- readRefMaybe wsRef
        for_ mws \ws -> WS.destroy ws
    -- zoom disabled, just using it to set "default zoom"
    useEffect minPxPerSec do
      mws <- readRefMaybe wsRef
      for_ mws (WS.zoom minPxPerSec)
      pure $ pure unit
    -- on url change
    useEffect murl do
      mws <- readRefMaybe wsRef
      case mws /\ murl of
        Just ws /\ Just url -> do
          WS.load url ws
          WS.clearRegions ws
          pure (pure unit)
        _ -> pure (pure unit)
    -- on player status change
    useEffect status do
      mws <- readRefMaybe wsRef
      case mws /\ status of
        Just ws /\ S.Nidle S.AudioPlaying -> do
          WS.setCursorColor "rgba(0,0,0,1)" ws
          WS.playRegion ws
          pure (pure unit)
        Just ws /\ S.Idle -> do
          WS.stop ws
          WS.setCursorColor "rgba(0,0,0,0)" ws
          pure (pure unit)
        _ -> pure (pure unit)
    pure
      $ DOM.div
          { ref: divRef
          , onWheel: handler (stopPropagation >>> targetWheelEvent) $ deltaY >>> calcZoom >>> setPxPerSec
          }
