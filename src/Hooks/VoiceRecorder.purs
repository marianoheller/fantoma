module Hooks.VoiceRecorder where

import Prelude
import Data.Array (reverse, (:))
import Data.Foldable (for_)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Unsafe (unsafePerformEffect)
import Foreign.Blob (Blob, BlobEvent, createObjectURLFromBlobs)
import Foreign.MediaRecorder (MediaRecorder)
import Foreign.MediaRecorder as MR
import Foreign.MediaStream as MS
import React.Basic.Hooks (Hook, Reducer, UseReducer, coerceHook, mkReducer, useReducer, (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (UseAff, useAff)

data LocalAction
  = StartRecording
  | StopRecording
  | SetIdle
  | ClearMMR
  | OnData BlobEvent
  | SetMediaRecorder (Maybe MediaRecorder)

data LocalStatus
  = Recording
  | Stopping
  | Idle

derive instance eqLocalStatus :: Eq LocalStatus

type LocalState
  = { status :: LocalStatus
    , chunks :: Array Blob
    , mmr :: Maybe MediaRecorder
    , murl :: Maybe String
    }

initialLocalState :: LocalState
initialLocalState = { status: Idle, chunks: [], mmr: Nothing, murl: Nothing }

reducer :: Reducer LocalState LocalAction
reducer =
  unsafePerformEffect
    $ mkReducer \s a -> case a of
        OnData ev -> s { chunks = ev.data : s.chunks }
        StartRecording -> s { status = Recording, chunks = [] }
        StopRecording -> s { status = Stopping }
        SetIdle -> s { status = Idle }
        ClearMMR -> s { mmr = Nothing }
        SetMediaRecorder mmr -> s { mmr = mmr }

type VoiceRecorderStuff
  = { mUrl :: Maybe String
    , start :: Effect Unit
    , stop :: Effect Unit
    , isRecording :: Boolean
    }

newtype UseVoiceRecorder hooks
  = UseVoiceRecorder (UseAff LocalStatus Unit (UseReducer LocalState LocalAction hooks))

derive instance ntUseVoiceRecorder :: Newtype (UseVoiceRecorder hooks) _

useVoiceRecorder :: Hook UseVoiceRecorder VoiceRecorderStuff
useVoiceRecorder =
  coerceHook React.do
    state /\ dispatch <- useReducer initialLocalState reducer
    useAff state.status do
      case state.status /\ state.mmr of
        Recording /\ _ -> do
          mr <- MR.newMediaRecorder <$> (MS.getUserMedia MS.audioOnly)
          liftEffect $ MR.onDataAvailable (dispatch <<< OnData) mr
          liftEffect $ MR.start 100 mr
          liftEffect $ dispatch $ SetMediaRecorder $ Just mr
        Stopping /\ Just mr -> do
          liftEffect $ MR.stop mr
          liftEffect $ dispatch SetIdle
        Idle /\ Just mr -> do
          url <- liftEffect <<< createObjectURLFromBlobs <<< reverse $ state.chunks
          liftEffect $ dispatch ClearMMR
        _ -> pure unit
    pure
      { mUrl: state.murl
      , start: dispatch StartRecording
      , stop: dispatch StopRecording
      , isRecording: state.status == Recording
      }
