module Jan where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (..)
import Signal exposing (Address)

import View exposing (view)
import Action exposing (..)
import Model exposing (..)
import Mailbox exposing (..)


main : Signal Html
main =
  Signal.map (view inbox.address) model


actions : Signal Action
actions =
  Signal.mergeMany [inbox.signal,
                    (Signal.map PlayersChanged playersPort),
                    (Signal.map DefineCurrentPlayer currentPlayerPort),
                    (Signal.map (\_ -> ResetGame) resetGamePort),
                    (Signal.map ShowResult resultFoundPort)]


model : Signal Model
model =
  Signal.foldp update initialModel actions


initialModel : Model
initialModel =
  {
    possibleWeapons = ["Rock", "Paper", "Scissors"],
    players = [],
    resultMessage = "",
    currentPlayer = ""
  }


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    PlayersChanged players ->
      { model | players = players }

    DefineCurrentPlayer playerName ->
      { model | currentPlayer = playerName }

    ShowResult message ->
      { model | resultMessage = message }

    ResetGame ->
      { model| resultMessage = "" }


port playersPort : Signal (List Player)
port resultFoundPort : Signal String
port currentPlayerPort : Signal String
port resetGamePort : Signal ()


port chooseWeaponPort : Signal String
port chooseWeaponPort =
  chooseWeaponMailbox.signal


port newGamePort : Signal ()
port newGamePort =
  newGameMailbox.signal
