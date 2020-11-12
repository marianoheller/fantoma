module Components.Player where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Nullable (notNull, null)
import Foreign.WaveSurfer as WS
import Prim.Row (class Union)
import React.Basic.DOM (Props_div)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, readRefMaybe, useEffect, useRef, writeRef)
import React.Basic.Hooks as React
import Web.DOM.Element (fromNode)

type PlayerProps r
  = { lala :: String | r }

mkPlayer :: forall attrs attrs_. Union attrs attrs_ Props_div => Component (PlayerProps attrs)
mkPlayer = do
  component "Surfer" \{ lala } -> React.do
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
    pure
      $ DOM.div { ref: divRef }
