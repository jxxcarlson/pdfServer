{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module Models where

import Data.Aeson
import Data.Text

import Database.Persist.TH

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Document
  id Text
  owner Text
  content Text
  UniqueName id
  deriving Eq Read Show
|]

instance FromJSON Document where
  parseJSON = withObject "Document" $ \ v ->
    Document <$> v .: "id"
         <*> v .: "owner"
         <*> v .: "content"

instance ToJSON User where
  toJSON (Document id owner content) =
    object [ "id" .= id
           , "owner"  .= age
           , "content" .= content  ]
