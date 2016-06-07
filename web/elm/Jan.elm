port module Jan exposing (..)

import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (..)

import View exposing (view)
import Msg exposing (..)
import Model exposing (..)


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init =
  (initialModel, Cmd.none)

initialModel : Model
initialModel =
  (Model ["Rock", "Paper", "Scissors"] [] "" "")


update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    PlayersChanged players ->
      ({ model | players = players }, Cmd.none)

    DefineCurrentPlayer playerName ->
      ({ model | currentPlayer = playerName }, Cmd.none)

    ShowResult message ->
      ({ model | resultMessage = message }, Cmd.none)

    ResetGame _ ->
      ({ model | resultMessage = "" }, Cmd.none)

    ChooseWeapon weapon ->
      (model, chooseWeaponPort weapon)

    StartNewGame ->
      (model, newGamePort "")


port chooseWeaponPort : String -> Cmd msg
-- TODO: Remove this string parameter, we don't need it
port newGamePort : String -> Cmd msg

-- SUBSCRIPTIONS

port playersPort : (List Player -> msg) -> Sub msg
port resultFoundPort : (String -> msg) -> Sub msg
port currentPlayerPort : (String -> msg) -> Sub msg

-- TODO: Remove this string parameter, we don't need it
port resetGamePort : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ playersPort PlayersChanged
    , resultFoundPort ShowResult
    , currentPlayerPort DefineCurrentPlayer
    , resetGamePort ResetGame
    ]
