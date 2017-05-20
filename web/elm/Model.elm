module Model exposing (..)

type alias Model =
  {
    possibleWeapons : List String,
    players : List Player,
    resultMessage : String,
    currentPlayer : String
  }


type alias Player =
  {
    name : String,
    weapon : String,
    score: Int
  }
