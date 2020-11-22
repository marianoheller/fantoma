module Foreign.MediaStream
  ( getUserMedia
  , audioOnly
  , MediaStreamConstraints
  , MediaStream
  ) where

import Prelude ((<<<))
import Data.Newtype (class Newtype, wrap)
import Control.Promise (Promise, toAffE)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import data MediaStream :: Type

foreign import _getUserMedia ::
  MediaStreamConstraints ->
  Effect (Promise MediaStream)

getUserMedia :: MediaStreamConstraints -> Aff MediaStream
getUserMedia = toAffE <<< _getUserMedia

newtype MediaStreamConstraints
  = MediaStreamConstraints
  { video :: Boolean
  , audio :: Boolean
  }

derive instance newtypeMediaStreamContstraints :: Newtype MediaStreamConstraints _

audioOnly :: MediaStreamConstraints
audioOnly = wrap { audio: true, video: false }
