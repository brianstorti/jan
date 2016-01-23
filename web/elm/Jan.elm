module Jan where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (..)
import StartApp.Simple as StartApp

main =
  StartApp.start {
    model = model,
    view = view,
    update = update
  }


-- MODEL


newWeapon name = { name = name }


model =
  {
    possibleWeapons =
      [ newWeapon "Rock",
        newWeapon "Paper",
        newWeapon "Scissors"
      ]
  }


-- VIEW


weaponView address weapon =
  let
    iconClassName = "fa-hand-" ++ String.toLower(weapon.name) ++ "-o"
  in
  div
    [ class "medium-4 columns" ]
    [ a
        [ class "weapon-wrapper" ]
        [ i [ class ("weapon fa fa-5x " ++ iconClassName) ] [],
          p [ class "weapon-label" ] [ text weapon.name ]
        ]
    ]


header =
  h1 [] [ text "Choose your weapon" ]


weaponsList =
  div
    [ class "row weapons" ]
    (List.map (weaponView address) model.possibleWeapons)


view address model =
  div
    [ class "row game" ]
    [ header, weaponsList ]


-- UPDATE


type Action = NoOp


update action model =
  case action of
    NoOp -> model
