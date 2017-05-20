module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (..)

import Model exposing (..)
import Msg exposing (..)


weaponView : Model -> String -> Html Msg
weaponView model weapon =
  let
    iconClassName = "fa-hand-" ++ String.toLower(weapon) ++ "-o"
    shouldDisable = (not << String.isEmpty <| model.resultMessage) || List.length(model.players) < 2
    disabledClass = if shouldDisable then "-disabled" else ""
  in
    div
      [ class "medium-4 columns" ]
      [ a
          [ class ("weapon-wrapper " ++ disabledClass), onClick (ChooseWeapon (String.toLower weapon))]
          [
            i [ class ("weapon fa fa-5x " ++ iconClassName) ] [],
            p [ class "weapon-label" ] [ text weapon ]
          ]
      ]


playerWeaponView : Player -> Model -> Html Msg
playerWeaponView player model =
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



playerView : Model -> Player -> Html Msg
playerView model player =
  div
    [ class "medium-4 columns" ]
    [
      span [ class "label"] [ text ("Score: " ++ (toString player.score)) ],
      div [] [ playerWeaponView player model ]
    ]


header : Model -> Html Msg
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


weaponsList : Model -> Html Msg
weaponsList model =
  div
    [ class "row weapons" ]
    (List.map (weaponView model) model.possibleWeapons)


playersList : Model -> Html Msg
playersList model =
  div
    [ class "row players" ]
    (List.map (playerView model) model.players)


resultView : Model -> Html Msg
resultView model =
  if String.isEmpty(model.resultMessage) then
     div [] []
  else
    div [ class "row" ]
        [
          h1 [ class "result" ]
             [ text model.resultMessage ],

          a [ class "button", onClick StartNewGame ]
            [ text "New Game" ]
        ]


view : Model -> Html Msg
view model =
  div
    [ class "row game" ]
    [
      invite,
      githubView,
      header model,
      weaponsList model,
      playersList model,
      resultView model
    ]
