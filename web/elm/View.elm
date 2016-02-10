module View where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (..)
import Signal exposing (Address)

import Model exposing (..)
import Action exposing (..)
import Mailbox exposing (..)


weaponView : Address Action -> Model -> String -> Html
weaponView address model weapon =
  let
    iconClassName = "fa-hand-" ++ String.toLower(weapon) ++ "-o"
    shouldDisable = (not << String.isEmpty <| model.resultMessage) || List.length(model.players) < 2
    disabledClass = if shouldDisable then "-disabled" else ""
  in
    div
      [ class "medium-4 columns" ]
      [ a
          [ class ("weapon-wrapper " ++ disabledClass), onClick chooseWeaponMailbox.address (String.toLower weapon)]
          [
            i [ class ("weapon fa fa-5x " ++ iconClassName) ] [],
            p [ class "weapon-label" ] [ text weapon ]
          ]
      ]


playerWeaponView : Address Action -> Player -> Model -> Html
playerWeaponView address player model =
  let
      gameNotFinished = String.isEmpty(model.resultMessage)
      noWeaponSelected = String.isEmpty(player.weapon)
      weaponForThisPlayer = player.name /= model.currentPlayer

      shouldHideWeapon = gameNotFinished && (noWeaponSelected || weaponForThisPlayer)

      iconClassName = if shouldHideWeapon
                         then "fa-question"
                         else "fa-hand-" ++ String.toLower(player.weapon) ++ "-o"

      weaponDescription = if shouldHideWeapon then "..." else player.weapon
  in
     a
       [ class "weapon-wrapper -disabled" ]
       [
         p [ class "weapon-label" ] [ text player.name ],
         i [ class ("weapon fa fa-5x " ++ iconClassName) ] [],
         p [ class "weapon-label" ] [ text weaponDescription ]
       ]



playerView : Address Action -> Model -> Player -> Html
playerView address model player =
  div
    [ class "medium-4 columns" ]
    [
      span [ class "label"] [ text ("Score: " ++ (toString player.score)) ],
      div [] [ playerWeaponView address player model ]
    ]


header : Model -> Html
header model =
  let
    headerText = if List.length(model.players) > 1 then
                   "Choose your weapon"
                 else
                   "Waiting for a second player"
  in
    h1 [] [ text headerText ]


invite =
  div [class "invite"]
      [ img [ src "/images/arrow.png" ] []]


githubView =
  div [ class "github" ]
      [ a [ href "https://github.com/brianstorti/jan", target "blank" ]
          [ i [ class "fa fa-3x fa-github" ] [] ]
      ]


weaponsList : Address Action -> Model -> Html
weaponsList address model =
  div
    [ class "row weapons" ]
    (List.map (weaponView address model) model.possibleWeapons)


playersList : Address Action -> Model -> Html
playersList address model =
  div
    [ class "row players" ]
    (List.map (playerView address model) model.players)


resultView : Address Action -> Model -> Html
resultView address model =
  if String.isEmpty(model.resultMessage) then
     div [] []
  else
    div [ class "row" ]
        [
          h1 [ class "result" ]
             [ text model.resultMessage ],

          a [ class "button", onClick newGameMailbox.address () ]
            [ text "New Game" ]
        ]


view : Address Action -> Model -> Html
view address model =
  div
    [ class "row game" ]
    [
      invite,
      githubView,
      header model,
      weaponsList address model,
      playersList address model,
      resultView address model
    ]
