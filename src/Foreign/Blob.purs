module Foreign.Blob (module Web.File.Blob, module Web.File.Url, BlobEvent, createObjectURLFromBlobs) where

import Prelude ((<<<))
import Web.File.Url (createObjectURL, revokeObjectURL)
import Effect (Effect)
import Web.File.Blob (Blob)

type BlobEvent
  = { data :: Blob }

foreign import _fromBlobs :: Array Blob -> Blob

fromBlobs :: Array Blob -> Blob
fromBlobs = _fromBlobs

createObjectURLFromBlobs :: Array Blob -> Effect String
createObjectURLFromBlobs = createObjectURL <<< fromBlobs
