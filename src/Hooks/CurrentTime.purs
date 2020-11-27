module Hooks.CurrentTime where

import Prelude

import Data.JSDate (JSDate)
import Data.JSDate as JSDate
import Data.Newtype (class Newtype)
import Effect (Effect)
import Effect.Timer (clearInterval, setInterval)
import React.Basic.Hooks (Hook, UseEffect, UseState, coerceHook, useEffectOnce, useState', (/\))
import React.Basic.Hooks as React

type Time
  = { hours :: Number, minutes :: Number, seconds :: Number }

newtype UseCurrentTime hooks
  = UseCurrentTime (UseEffect Unit (UseState Time hooks))

derive instance ntUseCurrentTime :: Newtype (UseCurrentTime hooks) _

useCurrentTime :: Time -> Hook UseCurrentTime Time
useCurrentTime initialTime =
  coerceHook React.do
    currentTime /\ setCurrentTime <- useState' initialTime
    useEffectOnce do
      intervalId <- setInterval 1000 (JSDate.now >>= getTime >>= setCurrentTime)
      pure (clearInterval intervalId)
    pure currentTime

getTime :: JSDate -> Effect Time
getTime date = ado
  hours <- JSDate.getHours date
  minutes <- JSDate.getMinutes date
  seconds <- JSDate.getSeconds date
  in { hours, minutes, seconds }