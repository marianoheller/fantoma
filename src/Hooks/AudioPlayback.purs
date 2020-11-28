module Hooks.AudioPlayback where

import Prelude
import Data.Foldable (for_)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Nullable (Nullable, null)
import Effect (Effect)
import Effect.Class.Console (warn)
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

useAudioPlayback :: Hook UseAudioPlayback VoiceRecorderStuff
useAudioPlayback =
  coerceHook React.do
    audioRef <- useRef null
    state /\ dispatch <- useReducer initialLocalState reducer
    useEffect state.murl do
      initializeAudioElement audioRef dispatch
      mElem <- ((=<<) E.fromNode) <$> (readRefMaybe audioRef)
      pure
        $ for_ mElem \elem ->
            for_ state.murl \url ->
              E.setAttribute "src" url elem
    useEffect state.status do
      case state.status of
        Playing -> do
          warn $ "attempt playing  " <> (show state.murl)
          mMediaElement <- getMediaElement audioRef
          for_ mMediaElement \me -> do
            warn "playing"
            MediaElement.play me
        Stopped -> do
          mMediaElement <- getMediaElement audioRef
          warn "attempt stopping "
          for_ mMediaElement \me -> do
                warn "STOPPED"
                MediaElement.pause me
                MediaElement.setCurrentTime 0.0 me
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
      doc <- (map toDocument) <<< document =<< window
      container <- createElement "div" doc
      mBodyHEle <- body =<< document =<< window
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
  case AudioElement.toHTMLMediaElement <$> (AudioElement.fromHTMLElement =<< mElem) of
    Nothing -> pure Nothing
    Just mediaElement -> pure $ Just mediaElement
