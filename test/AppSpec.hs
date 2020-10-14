{-# LANGUAGE OverloadedStrings #-}

module AppSpec where

import           Api
import           App

import           Control.Exception (throwIO, ErrorCall(..))
import           Control.Monad.Trans.Except

import           Data.Text

import           Models

import           Network.HTTP.Client
import           Network.Wai.Handler.Warp

import           Servant.API
import           Servant.Client

import           Test.Hspec
import           Test.Mockery.Directory

docAdd :: Document -> ClientM (Maybe (Key Document))
docGet :: Text -> ClientM (Maybe Document)
docAdd :<|> docGet = client api

spec :: Spec
spec = do
  around withApp $ do
    describe "/doc GET" $ do
      it "returns Nothing for non-existing docs" $ \ port -> do
        try port (docGet "foo") `shouldReturn` Nothing

    describe "/doc POST" $ do
      it "allows to add a doc" $ \ port -> do
        let doc = Document "Alice" 1
        id <- try port (docAdd doc)
        try port (docGet "Alice") `shouldReturn` Just doc

      it "allows to add two docs" $ \ port -> do
        let a = Document "Alice" 1
        let b = Document "Bob" 2
        id <- try port (docAdd a)
        id <- try port (docAdd b)
        try port (docGet "Bob") `shouldReturn` Just b

      it "returns Nothing when adding the same doc twice" $ \ port -> do
        let a = Document "Alice" 1
        id <- try port (docAdd a)
        try port (docAdd a) `shouldReturn` Nothing

withApp :: (Int -> IO a) -> IO a
withApp action =
  inTempDirectory $ do
    app <- mkApp "sqlite.db"
    testWithApplication (return app) action

try :: Int -> ClientM a -> IO a
try port action = do
  manager <- newManager defaultManagerSettings
  let baseUrl = BaseUrl Http "localhost" port ""
  result <- runClientM action (ClientEnv manager baseUrl)
  case result of
    Left err -> throwIO $ ErrorCall $ show err
    Right a -> return a
