module Slice where

import Prelude
import Data.Foldable (or)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Lens (Lens', Prism', lens', preview, prism')
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))

-- State
data AppState
  = NotInitialized
  | Initialized InternalState

derive instance eqAppState :: Eq AppState

derive instance genericAppState :: Generic AppState _

instance showAppState :: Show AppState where
  show = genericShow

type InternalState
  = { audioUrl :: Maybe String
    , appStatus :: AppStatus
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
  = Idle
  | Nidle Status

derive instance genericAppStatus :: Generic AppStatus _

instance showAppStatus :: Show AppStatus where
  show = genericShow

derive instance eqAppStatus :: Eq AppStatus

data Status
  = AudioPlaying
  | VoiceRecording
  | VoicePlaying
  | Loading

derive instance genericStatus :: Generic Status _

instance showStatus :: Show Status where
  show = genericShow

derive instance eqStatus :: Eq Status

initialState :: AppState
initialState = NotInitialized

initialInternalState :: InternalState
initialInternalState =
  { audioUrl: Nothing
  , appStatus: Idle
  , playbackOption: NoPlayback
  }

-- Actions
data AppAction
  = SetAudioUrl (Maybe String)
  | FinishLoading
  | PlayAudio
  | StopAudio
  | StartRecording
  | StopRecording
  | PlayVoice
  | StopVoice
  | SetPlaybackOption PlaybackOption

derive instance genericAppAction :: Generic AppAction _

instance showAppAction :: Show AppAction where
  show = genericShow

-- Reducer
reducer :: AppState -> AppAction -> AppState
reducer (NotInitialized) action = case action of
  SetAudioUrl (Just url) -> Initialized $ initialInternalState { audioUrl = Just url, appStatus = Nidle Loading }
  _ -> NotInitialized

reducer (Initialized state) action =
  Initialized
    $ case action of
        SetAudioUrl url -> state { audioUrl = url, appStatus = Nidle Loading }
        FinishLoading -> state { appStatus = Idle }
        PlayAudio -> state { appStatus = Nidle AudioPlaying }
        StopAudio -> state { appStatus = Idle }
        PlayVoice -> state { appStatus = Nidle VoicePlaying }
        StopVoice -> case preview _PlaybackOption $ state of
          Just PlaybackAudio -> state { appStatus = Nidle AudioPlaying }
          _ -> state { appStatus = Idle }
        StartRecording -> state { appStatus = Nidle VoiceRecording }
        StopRecording -> case preview _PlaybackOption $ state of
          Just PlaybackVoice -> state { appStatus = Nidle VoicePlaying }
          _ -> state { appStatus = Idle }
        SetPlaybackOption option -> state { playbackOption = option }

-- Optics
_InternalState :: Prism' AppState InternalState
_InternalState =
  prism' Initialized
    $ case _ of
        NotInitialized -> Nothing
        Initialized a -> Just a

_AppStatus :: forall r. Lens' { appStatus :: AppStatus | r } AppStatus
_AppStatus = lens' \record -> Tuple record.appStatus (\s -> record { appStatus = s })

_Status :: Prism' AppStatus Status
_Status =
  prism' Nidle
    $ case _ of
        Idle -> Nothing
        Nidle a -> Just a

_PlaybackOption :: forall r. Lens' { playbackOption :: PlaybackOption | r } PlaybackOption
_PlaybackOption = lens' \record -> Tuple record.playbackOption (\s -> record { playbackOption = s })

-- Selectors
getStatus :: AppState -> Maybe Status
getStatus = preview (_InternalState <<< _AppStatus <<< _Status)

selectIsIdle :: AppState -> Boolean
selectIsIdle = (eq (Just Idle)) <<< preview (_InternalState <<< _AppStatus)

selectIsNidle :: AppState -> Boolean
selectIsNidle = not <<< selectIsIdle

selectIsLoading :: AppState -> Boolean
selectIsLoading = (eq (Just Loading)) <<< getStatus

selectIsAudioPlaying :: AppState -> Boolean
selectIsAudioPlaying = (eq (Just AudioPlaying)) <<< getStatus

selectIsVoicePlaying :: AppState -> Boolean
selectIsVoicePlaying = (eq (Just VoicePlaying)) <<< getStatus

selectIsVoiceRecording :: AppState -> Boolean
selectIsVoiceRecording = (eq (Just VoiceRecording)) <<< getStatus

selectIsAudioControlEnabled :: AppState -> Boolean
selectIsAudioControlEnabled = or <<< flap [ selectIsAudioPlaying, selectIsIdle ]

selectIsAudioControlDisabled :: AppState -> Boolean
selectIsAudioControlDisabled = not <<< selectIsAudioControlEnabled

selectIsRecordingEnabled :: AppState -> Boolean
selectIsRecordingEnabled = or <<< flap [ selectIsVoicePlaying, selectIsVoiceRecording, selectIsIdle ]

selectIsRecordingDisabled :: AppState -> Boolean
selectIsRecordingDisabled = not <<< selectIsRecordingEnabled
