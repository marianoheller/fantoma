module Slice where

import Prelude
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))

-- State
data AppState
  = NotInitialized
  | Initialized InternalState

derive instance genericAppState :: Generic AppState _

instance showAppState :: Show AppState where
  show = genericShow

type InternalState
  = { audioUrl :: Maybe String
    , status :: AppStatus
    , playbackOption :: PlaybackOption
    }

data PlaybackOption
  = PlaybackVoice
  | PlaybackAudio
  | NoPlayback

derive instance genericPlaybackOption :: Generic PlaybackOption _

instance showPlaybackOption :: Show PlaybackOption where
  show = genericShow

derive instance eqPlaybackOption :: Eq PlaybackOption

data AppStatus
  = Iddle
  | Niddle Status

derive instance genericAppStatus :: Generic AppStatus _

instance showAppStatus :: Show AppStatus where
  show = genericShow

derive instance eqAppStatus :: Eq AppStatus

data Status
  = AudioPlaying
  | AudioPaused
  | VoiceRecording
  | VoicePlaying

derive instance genericStatus :: Generic Status _

instance showStatus :: Show Status where
  show = genericShow

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
  | SetPlaybackOption PlaybackOption

derive instance genericAppAction :: Generic AppAction _

instance showAppAction :: Show AppAction where
  show = genericShow

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
        SetPlaybackOption option -> state { playbackOption = option }
