module Components.VoiceRecorder (mkVoiceRecorder) where

import Prelude
import Data.Array (reverse, (:))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Foreign.Blob (Blob, BlobEvent, createObjectURLFromBlobs)
import Foreign.MediaRecorder (MediaRecorder)
import Foreign.MediaRecorder as MR
import Foreign.MediaStream as MS
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, mkReducer, useReducer, (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)

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
    }

initialLocalState :: LocalState
initialLocalState = { status: Idle, chunks: [], mmr: Nothing }

reducer :: LocalState -> LocalAction -> LocalState
reducer s a = case a of
  OnData ev -> s { chunks = ev.data : s.chunks }
  StartRecording -> s { status = Recording, chunks = [] }
  StopRecording -> s { status = Stopping }
  SetIdle -> s { status = Idle }
  ClearMMR -> s { mmr = Nothing }
  SetMediaRecorder mmr -> s { mmr = mmr }

type VoiceRecorderProps
  = { onRecordingFinish :: String -> Effect Unit
    , onRecordingStart :: Effect Unit
    }

mkVoiceRecorder :: Component VoiceRecorderProps
mkVoiceRecorder = do
  reducer' <- mkReducer reducer
  component "VoiceRecorder" \{ onRecordingFinish, onRecordingStart } -> React.do
    state /\ dispatch <- useReducer initialLocalState reducer'
    useAff state.status do
      case state.status /\ state.mmr of
        Recording /\ _ -> do
          mr <- MR.newMediaRecorder <$> (MS.getUserMedia MS.audioOnly)
          liftEffect $ MR.onDataAvailable (dispatch <<< OnData) mr
          liftEffect $ MR.start 100 mr
          liftEffect $ dispatch $ SetMediaRecorder $ Just mr
          liftEffect onRecordingStart
        Stopping /\ Just mr -> do
          liftEffect $ MR.stop mr
          liftEffect $ dispatch SetIdle
        Idle /\ Just mr -> do
          url <- liftEffect <<< createObjectURLFromBlobs <<< reverse $ state.chunks
          liftEffect $ dispatch ClearMMR
          liftEffect $ onRecordingFinish url
        _ -> pure unit
    let
      action /\ text = case state.status of
        Idle -> StartRecording /\ "Record"
        Recording -> StopRecording /\ "Stop"
        Stopping -> StopRecording /\ "Stop"
    pure
      $ DOM.div_
          [ DOM.button
              { onClick: handler currentTarget (\_ -> dispatch action)
              , children: [ DOM.text text ]
              , disabled: state.status /= Idle && state.status /= Recording
              }
          ]
