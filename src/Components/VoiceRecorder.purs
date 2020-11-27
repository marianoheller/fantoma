module Components.VoiceRecorder (mkVoiceRecorder) where

import Prelude
import Data.Array ((:))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Foreign.Blob (Blob, BlobEvent)
import Foreign.MediaRecorder (MediaRecorder)
import Hooks.VoiceRecorder (useVoiceRecorder)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, (/\))
import React.Basic.Hooks as React

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
mkVoiceRecorder =
  component "VoiceRecorder" \_ -> React.do
    { mUrl, isRecording, start, stop } <- useVoiceRecorder
    let
      action /\ label = case isRecording of
        true -> stop /\ "Stop"
        false -> start /\ "Record"
    pure
      $ DOM.div_
          [ DOM.button
              { onClick: handler currentTarget (\_ -> action)
              , children: [ DOM.text label ]
              }
          ]
