module Hooks.AudioPlayback where

import Prelude
import Data.Foldable (for_, sequence_, traverse_)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Nullable (Nullable, null)
import Effect (Effect)
import Effect.Unsafe (unsafePerformEffect)
import React.Basic.DOM (render)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Hook, Reducer, Ref, UseEffect, UseReducer, UseRef, coerceHook, mkReducer, readRefMaybe, useEffect, useReducer, useRef, (/\))
import React.Basic.Hooks as React
import Web.DOM (Node)
import Web.DOM.Document (createElement)
import Web.DOM.Element as E
import Web.DOM.Node (appendChild)
import Web.HTML (window)
import Web.HTML.HTMLAudioElement as AudioElement
import Web.HTML.HTMLDocument (body, toDocument)
import Web.HTML.HTMLElement as HE
import Web.HTML.HTMLMediaElement (HTMLMediaElement)
import Web.HTML.HTMLMediaElement as MediaElement
import Web.HTML.Window (document)

data LocalAction
  = StartPlaying
  | StopPlaying
  | SetMUrl (Maybe String)

data LocalStatus
  = Playing
  | Stopped

derive instance eqLocalStatus :: Eq LocalStatus

derive instance genericLocalStatus :: Generic LocalStatus _

instance showLocalStatus :: Show LocalStatus where
  show = genericShow

type LocalState
  = { status :: LocalStatus
    , murl :: Maybe String
    }

initialLocalState :: LocalState
initialLocalState = { status: Stopped, murl: Nothing }

reducer :: Reducer LocalState LocalAction
reducer =
  unsafePerformEffect
    $ mkReducer \s a -> case a of
        StartPlaying -> s { status = Playing }
        StopPlaying -> s { status = Stopped }
        SetMUrl murl -> s { murl = murl }

type OnAudioStop
  = Effect Unit

type VoiceRecorderStuff
  = { mUrl :: Maybe String
    , start :: Effect Unit
    , stop :: Effect Unit
    , isPlaying :: Boolean
    , setMUrl :: Maybe String -> Effect Unit
    }

newtype UseAudioPlayback hooks
  = UseAudioPlayback (UseEffect LocalStatus (UseEffect (Maybe String) (UseReducer LocalState LocalAction (UseRef (Nullable Node) hooks))))

derive instance ntUseAudioPlayback :: Newtype (UseAudioPlayback hooks) _

useAudioPlayback :: OnAudioStop -> Hook UseAudioPlayback VoiceRecorderStuff
useAudioPlayback onAudioStop =
  coerceHook React.do
    audioRef <- useRef null
    state /\ dispatch <- useReducer initialLocalState reducer
    useEffect state.murl do
      initializeAudioElement audioRef dispatch
      mElem <- ((=<<) E.fromNode) <$> (readRefMaybe audioRef) -- better way to do this? (Bind g => Functor f => (a -> g b) -> f (g a) -> f (g b))
      for_ mElem \elem -> do
        for_ state.murl \url -> do
          E.setAttribute "src" url elem
      pure $ pure unit
    useEffect state.status do
      case state.status of
        Playing -> (traverse_ MediaElement.play) =<< getMediaElement audioRef
        Stopped -> ((traverse_ stop) =<< getMediaElement audioRef) <> onAudioStop
      pure $ pure unit
    pure
      { mUrl: state.murl
      , setMUrl: dispatch <<< SetMUrl
      , start: dispatch StartPlaying
      , stop: dispatch StopPlaying
      , isPlaying: state.status == Playing
      }

initializeAudioElement :: Ref (Nullable Node) -> (LocalAction -> Effect Unit) -> Effect Unit
initializeAudioElement audioRef dispatch = do
  mAudioNodeInitialized <- readRefMaybe audioRef
  case mAudioNodeInitialized of
    Just _ -> pure unit
    Nothing -> do
      doc <- document =<< window
      container <- createElement "div" (toDocument doc)
      mBodyHEle <- body doc
      mElemNode <- readRefMaybe audioRef
      for_ mBodyHEle \bodyHEle -> do
        _ <- appendChild (E.toNode container) (HE.toNode bodyHEle)
        render
          ( DOM.audio
              { ref: audioRef
              , preload: "auto"
              , onEnded: handler currentTarget (\_ -> dispatch StopPlaying)
              }
          )
          container

getMediaElement :: Ref (Nullable Node) -> Effect (Maybe HTMLMediaElement)
getMediaElement audioRef = do
  mElem <- ((=<<) HE.fromNode) <$> (readRefMaybe audioRef)
  pure $ AudioElement.toHTMLMediaElement <$> (AudioElement.fromHTMLElement =<< mElem)

stop :: HTMLMediaElement -> Effect Unit
stop = sequence_ <<< flap [ MediaElement.pause, MediaElement.setCurrentTime 0.0 ]
