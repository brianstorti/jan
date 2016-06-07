module Msg exposing (..)

import Model exposing (..)

type Msg
      = PlayersChanged (List Player)
      | ShowResult String
      | ChooseWeapon String
      | StartNewGame
      | ResetGame String
      | DefineCurrentPlayer String
