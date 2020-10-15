{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeOperators     #-}

module App where

import           Control.Monad.IO.Class (liftIO)
import           Control.Monad.Logger (runStderrLoggingT)
import           Database.Persist.Sqlite ( ConnectionPool, createSqlitePool
                                         , runSqlPool, runSqlPersistMPool
                                         , runMigration, selectFirst, (==.)
                                         , insert, entityVal)
import           Data.String.Conversions (cs)
import           Data.Text (Text)
import           Network.Wai.Handler.Warp as Warp

import           Servant

import           Api
import           Models

import           System.IO (putStrLn)
import           Data.Text (unpack)
import           Process

writeDocument :: Document -> IO()
writeDocument doc = 
  let
    fileName = "texFiles/" ++ (unpack $ documentDocId doc) ++ ".tex"
    contents = unpack $ documentContent doc
  in
    writeFile fileName contents


server :: ConnectionPool -> Server Api
server pool =
  documentAddH :<|> documentGetH
  where
    documentAddH newDocument = liftIO $ documentAdd newDocument
    documentGetH docId    = liftIO $ documentGet docId

    documentAdd :: Document -> IO (Maybe (Key Document))
    documentAdd newDocument = flip runSqlPersistMPool pool $ do
      liftIO $ writeDocument newDocument
      liftIO $ publishPdf (unpack $ documentDocId newDocument)
      exists <- selectFirst [DocumentDocId ==. (documentDocId newDocument)] []
      case exists of
        Nothing -> Just <$> insert newDocument
        Just _ -> pure Nothing

    documentGet :: Text -> IO (Maybe Document)
    documentGet docId = flip runSqlPersistMPool pool $ do
      mDocument <- selectFirst [DocumentDocId ==. docId] []
      pure $ entityVal <$> mDocument

app :: ConnectionPool -> Application
app pool = serve api $ server pool

mkApp :: FilePath -> IO Application
mkApp sqliteFile = do
  pool <- runStderrLoggingT $ do
    createSqlitePool (cs sqliteFile) 5

  runSqlPool (runMigration migrateAll) pool
  return $ app pool

run :: FilePath -> IO ()
run sqliteFile =
  Warp.run 3000 =<< mkApp sqliteFile
