module Slice where

import Prelude
import Data.Maybe (Maybe(..))

-- State
data AppState
  = NotInitialized
  | Initialized InternalState

type InternalState
  = { audioUrl :: Maybe String
    , status :: AppStatus
    , playbackOption :: PlaybackOption
    }

data PlaybackOption
  = PlaybackVoice
  | PlaybackAudio
  | NoPlayback

data AppStatus
  = Iddle
  | Niddle Status

derive instance eqAppStatus :: Eq AppStatus

data Status
  = AudioPlaying
  | AudioPaused
  | VoiceRecording
  | VoicePlaying

derive instance eqStatus :: Eq Status

initialState :: AppState
initialState = NotInitialized

initialInternalState :: InternalState
initialInternalState =
  { audioUrl: Nothing
  , status: Iddle
  , playbackOption: NoPlayback
  }

-- Actions
data AppAction
  = SetAudioUrl (Maybe String)
  | PlayAudio
  | StopAudio
  | PauseAudio

-- Reducer
reducer :: AppState -> AppAction -> AppState
reducer (NotInitialized) action = case action of
  SetAudioUrl (Just url) -> Initialized $ initialInternalState { audioUrl = Just url }
  _ -> NotInitialized

reducer (Initialized state) action =
  Initialized
    $ case action of
        SetAudioUrl url -> state { audioUrl = url, status = Iddle }
        PlayAudio -> state { status = Niddle AudioPlaying }
        StopAudio -> state { status = Iddle }
        PauseAudio -> state { status = Niddle AudioPaused }
