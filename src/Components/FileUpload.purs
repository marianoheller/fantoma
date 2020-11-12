module Components.FileUpload (mkFileUpload) where

import Prelude
import Data.Foldable (for_)
import React.Basic.DOM as R
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, fragment, useState', (/\))
import React.Basic.Hooks as React
import Web.File.File as File
import Web.File.FileList as FileList
import Web.HTML.HTMLInputElement as HTMLInputElement

mkFileUpload :: Component {}
mkFileUpload = do
  component "FileUploadComponent" \_ -> React.do
    fileList /\ setFileList <- useState' []
    let
      handleChange t =
        for_ (HTMLInputElement.fromEventTarget t) \fileInput -> do
          maybeFiles <- HTMLInputElement.files fileInput
          for_ maybeFiles (setFileList <<< map File.name <<< FileList.items)
    pure
      $ fragment
          [ R.input
              { type: "file"
              , accept: ".mp3,audio/*"
              , onChange: handler currentTarget handleChange
              }
          , R.pre_
              [ R.text (show fileList)
              ]
          ]
