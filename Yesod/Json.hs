{-# LANGUAGE TypeSynonymInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module Yesod.Json
    ( -- * Convert from a JSON value
      defaultLayoutJson
    , jsonToRepJson
      -- * Compatibility wrapper for old API
    , Json
    , jsonScalar
    , jsonList
    , jsonMap
    ) where

import Yesod.Handler (GHandler)
import Yesod.Content
    ( ToContent (toContent), RepHtmlJson (RepHtmlJson), RepHtml (RepHtml)
    , RepJson (RepJson), Content (ContentBuilder)
    )
import Yesod.Core (defaultLayout, Yesod)
import Yesod.Widget (GWidget)
import qualified Data.Aeson as J
import Data.Aeson.Encode (fromValue)
import Data.Text (pack)
import Control.Arrow (first)
import Data.Map (fromList)
import qualified Data.Vector as V

instance ToContent J.Value where
    toContent = flip ContentBuilder Nothing . fromValue

-- | Provide both an HTML and JSON representation for a piece of data, using
-- the default layout for the HTML output ('defaultLayout').
defaultLayoutJson :: Yesod master
                  => GWidget sub master ()
                  -> J.Value
                  -> GHandler sub master RepHtmlJson
defaultLayoutJson w json = do
    RepHtml html' <- defaultLayout w
    return $ RepHtmlJson html' $ toContent json

-- | Wraps the 'Content' generated by 'jsonToContent' in a 'RepJson'.
jsonToRepJson :: J.Value -> GHandler sub master RepJson
jsonToRepJson = return . RepJson . toContent

type Json = J.Value

jsonScalar :: String -> Json
jsonScalar = J.String . pack

jsonList :: [Json] -> Json
jsonList = J.Array . V.fromList

jsonMap :: [(String, Json)] -> Json
jsonMap = J.Object . fromList . map (first pack)
