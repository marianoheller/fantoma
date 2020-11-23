module Foreign.MediaRecorder where

import Prelude
import Effect (Effect)
import Foreign.Blob (BlobEvent)
import Foreign.MediaStream (MediaStream)

foreign import data MediaRecorder :: Type

instance eqMediaRecorder :: Eq MediaRecorder where
  eq _ _ = true

foreign import newMediaRecorder :: MediaStream -> MediaRecorder

foreign import start :: Int -> MediaRecorder -> Effect Unit

foreign import stop :: MediaRecorder -> Effect Unit

foreign import state :: MediaRecorder -> String

foreign import requestData :: MediaRecorder -> Effect Unit

foreign import onDataAvailable :: forall a. (BlobEvent -> Effect a) -> MediaRecorder -> Effect Unit
