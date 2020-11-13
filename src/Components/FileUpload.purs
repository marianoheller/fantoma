module Components.FileUpload (mkFileUpload) where

import Prelude
import Data.Foldable (for_, traverse_)
import Effect (Effect)
import React.Basic.DOM as R
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, fragment)
import Web.File.File as File
import Web.File.FileList as FileList
import Web.File.Url as Url
import Web.HTML.HTMLInputElement as HTMLInputElement

type FileUploadProps
  = { onFileUpload :: String -> Effect Unit }

mkFileUpload :: Component FileUploadProps
mkFileUpload = do
  component "FileUploadComponent" \{ onFileUpload } -> React.do
    let
      handleChange t =
        for_ (HTMLInputElement.fromEventTarget t) \fileInput -> do
          maybeFiles <- HTMLInputElement.files fileInput
          for_ maybeFiles (traverse_ (((=<<) onFileUpload) <<< Url.createObjectURL <<< File.toBlob) <<< FileList.item 0)
    pure
      $ fragment
          [ R.input
              { type: "file"
              , accept: ".mp3,audio/*"
              , onChange: handler currentTarget handleChange
              }
          ]
