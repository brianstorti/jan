module Action where

import Model exposing (..)

type Action
      = NoOp
      | PlayersChanged (List Player)
      | ShowResult String
      | ResetGame
      | DefineCurrentPlayer String
