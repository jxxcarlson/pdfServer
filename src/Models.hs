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
  docId Text
  owner Text
  content Text
  UniqueName docId
  deriving Eq Read Show
|]

instance FromJSON Document where
  parseJSON = withObject "Document" $ \ v ->
    Document <$> v .: "docId"
         <*> v .: "owner"
         <*> v .: "content"

instance ToJSON Document where
  toJSON (Document docId owner content) =
    object [ "docId" .= docId
           , "owner"  .= owner
           , "content" .= content  ]


---ooooo

-- share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
-- User
--   name Text
--   age  Int
--   UniqueName name
--   deriving Eq Read Show
-- |]

-- instance FromJSON User where
--   parseJSON = withObject "User" $ \ v ->
--     User <$> v .: "name"
--          <*> v .: "age"

-- instance ToJSON User where
--   toJSON (User name age) =
--     object [ "name" .= name
--            , "age"  .= age  ]