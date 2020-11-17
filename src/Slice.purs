module Slice where

import Prelude
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))

data Status
  = Playing
  | Stopped
  | Paused

derive instance genericStatus :: Generic Status _

instance showStatus :: Show Status where
  show = genericShow

derive instance eqStatus :: Eq Status

type AppState
  = { audioUrl :: Maybe String
    , status :: Status
    }

data AppAction
  = SetAudioUrl (Maybe String)
  | Play
  | Stop
  | Pause

initialState :: AppState
initialState = { audioUrl: Nothing, status: Stopped }

reducer :: AppState -> AppAction -> AppState
reducer state action = case action of
  SetAudioUrl url -> state { audioUrl = url, status = Stopped }
  Play -> state { status = Playing }
  Stop -> state { status = Stopped }
  Pause -> state { status = Paused }
