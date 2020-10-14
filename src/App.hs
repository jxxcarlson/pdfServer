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

server :: ConnectionPool -> Server Api
server pool =
  docAddH :<|> docGetH
  where
    docAddH newDocument = liftIO $ docAdd newDocument
    docGetH name    = liftIO $ docGet name

    docAdd :: Document -> IO (Maybe (Key Document))
    docAdd newDocument = flip runSqlPersistMPool pool $ do
      exists <- selectFirst [DocumentName ==. (docName newDocument)] []
      case exists of
        Nothing -> Just <$> insert newDocument
        Just _ -> return Nothing

    docGet :: Text -> IO (Maybe Document)
    docGet name = flip runSqlPersistMPool pool $ do
      mDocument <- selectFirst [DocumentName ==. name] []
      return $ entityVal <$> mDocument

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
