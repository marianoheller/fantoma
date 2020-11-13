module Slice where

import Data.Maybe (Maybe(..))

data Status
  = Playing
  | Iddle

type AppState
  = { audioUrl :: Maybe String
    , status :: Status
    }

data AppAction
  = SetAudioUrl (Maybe String)
  | Play
  | Pause

initialState :: AppState
initialState = { audioUrl: Nothing, status: Iddle }

reducer :: AppState -> AppAction -> AppState
reducer state action = case action of
  SetAudioUrl url -> state { audioUrl = url }
  Play -> state { status = Playing }
  Pause -> state { status = Iddle }
