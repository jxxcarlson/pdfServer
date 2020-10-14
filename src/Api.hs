{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeOperators     #-}

module Api where

import Data.Proxy
import Data.Text

import Database.Persist

import Models

import Servant.API



type Api =
       "doc" :> ReqBody '[JSON] Document :> Post '[JSON] (Maybe (Key Document))
  :<|> "doc" :> Capture "docId" Text  :> Get  '[JSON] (Maybe Document)

api :: Proxy Api
api = Proxy
