module Components.Clock (mkClock) where

import Prelude

import Hooks.CurrentTime (getTime, useCurrentTime)
import Data.JSDate as JSDate
import Math (cos, sin, tau)
import React.Basic.DOM.SVG as SVG
import React.Basic.Hooks (Component, JSX, component)
import React.Basic.Hooks as React

mkClock :: Component {}
mkClock = do
  now <- JSDate.now >>= getTime
  component "Clock" \props -> React.do
    { hours, minutes, seconds } <- useCurrentTime now
    pure
      $ SVG.svg
          { viewBox: "0 0 400 400"
          , width: "400"
          , height: "400"
          , children:
              [ SVG.circle { cx: "200", cy: "200", r: "120", fill: "#1293D8" }
              , hand 6 60.0 (hours / 12.0)
              , hand 6 90.0 (minutes / 60.0)
              , hand 3 90.0 (seconds / 60.0)
              ]
          }

hand :: Int -> Number -> Number -> JSX
hand width length turns =
  let
    t = tau * (turns - 0.25)

    x = 200.0 + length * cos t

    y = 200.0 + length * sin t
  in
    SVG.line
      { x1: "200"
      , y1: "200"
      , x2: show x
      , y2: show y
      , stroke: "white"
      , strokeWidth: show width
      , strokeLinecap: "round"
      }
