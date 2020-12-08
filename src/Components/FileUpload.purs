module Components.FileUpload (mkFileUpload) where

import Prelude
import Data.Foldable (for_, traverse_)
import Data.Maybe (Maybe(..))
import Data.Nullable (null)
import Effect (Effect)
import React.Basic.DOM as DOM
import React.Basic.DOM.Events (currentTarget)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, fragment, readRefMaybe, useRef)
import React.Basic.Hooks as React
import Web.File.File as File
import Web.File.FileList as FileList
import Web.File.Url as Url
import Web.HTML.HTMLElement (click, fromNode)
import Web.HTML.HTMLInputElement as HTMLInputElement

type FileUploadProps
  = { onFileUpload :: Maybe String -> Effect Unit
    , disabled :: Boolean
    }

mkFileUpload :: Component FileUploadProps
mkFileUpload = do
  component "FileUploadComponent" \{ onFileUpload, disabled } -> React.do
    inputRef <- useRef null
    let
      _onFileUpload = onFileUpload <<< Just

      handleChange t =
        for_ (HTMLInputElement.fromEventTarget t) \fileInput -> do
          maybeFiles <- HTMLInputElement.files fileInput
          for_ maybeFiles (traverse_ (((=<<) _onFileUpload) <<< Url.createObjectURL <<< File.toBlob) <<< FileList.item 0)

      handleButtonClick _ = do
        mNode <- readRefMaybe inputRef
        for_ (fromNode =<< mNode) click
    pure
      $ fragment
          [ DOM.input
              { type: "file"
              , accept: ".mp3,audio/*"
              , onChange: handler currentTarget handleChange
              , ref: inputRef
              , style: DOM.css { display: "none" }
              }
          , DOM.button
              { onClick: handler currentTarget handleButtonClick
              , children: [ DOM.text "Load file" ]
              , disabled
              }
          ]
