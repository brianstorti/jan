module Jan where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (..)
import Signal exposing (Address)


main : Signal Html
main =
  Signal.map (view inbox.address) model


inbox : Signal.Mailbox Action
inbox =
  Signal.mailbox NoOp


-- MODEL

type alias Model =
  {
    possibleWeapons : List Weapon,
    players : List Player
  }


type alias Weapon =
  {
    name : String
  }


type alias Player =
  {
    name : String,
    weapon : Weapon
  }


actions : Signal Action
actions =
  Signal.merge inbox.signal (Signal.map TestAction testPort)


model : Signal Model
model =
  Signal.foldp update initialModel actions


createWeapon : String -> Weapon
createWeapon name =
  { name = name }


initialModel : Model
initialModel =
  {
    possibleWeapons =
      [ createWeapon "Rock",
        createWeapon "Paper",
        createWeapon "Scissors"
      ],

    players = []
  }


-- VIEW


weaponView address {name} =
  let
    iconClassName = "fa-hand-" ++ String.toLower(name) ++ "-o"
  in
    div
      [ class "medium-4 columns" ]
      [ a
          [ class "weapon-wrapper" ]
          [ i [ class ("weapon fa fa-5x " ++ iconClassName) ] [],
            p [ class "weapon-label" ] [ text name ]
          ]
      ]


header : Html
header =
  h1 [] [ text "Choose your weapon" ]


weaponsList : Model -> Html
weaponsList model =
  div
    [ class "row weapons" ]
    (List.map (weaponView address) model.possibleWeapons)


view : Address Action -> Model -> Html
view address model =
  div
    [ class "row game" ]
    [
      header, weaponsList model
    ]


-- UPDATE


type Action = NoOp | TestAction String


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    TestAction value ->
      { model | possibleWeapons = (createWeapon value) :: model.possibleWeapons }



-- PORTS

port testPort : Signal String
