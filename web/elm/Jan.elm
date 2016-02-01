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
    move : String,
    score: Int
  }


actions : Signal Action
actions =
  Signal.mergeMany [inbox.signal,
                    (Signal.map TestAction testPort),
                    (Signal.map PlayersChanged playersPort)]


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

playerWeaponView address player =
  let
      iconClassName = if String.isEmpty(player.move)
                         then "fa-question"
                         else "fa-hand-" ++ String.toLower(player.move) ++ "-o"
  in
     a
       [ class "weapon-wrapper -disabled" ]
       [ p [ class "weapon-label" ] [ text player.name ],
         i [ class ("weapon fa fa-5x " ++ iconClassName) ] [],
         p [ class "weapon-label" ] [ text player.move ]
       ]



playerView address player =
  div
    [ class "large-4 medium-4 columns" ]
    [ div [ class "score round label"] [ text (toString player.score) ],
      div [] [ playerWeaponView address player ]
    ]


header : Html
header =
  h1 [] [ text "Choose your weapon" ]


weaponsList : Model -> Html
weaponsList model =
  div
    [ class "row weapons" ]
    (List.map (weaponView address) model.possibleWeapons)


playersList : Model -> Html
playersList model =
  div
    [ class "row players" ]
    (List.map (playerView address) model.players)


view : Address Action -> Model -> Html
view address model =
  div
    [ class "row game" ]
    [
      header,
      weaponsList model,
      playersList model
    ]


-- UPDATE


type Action = NoOp | TestAction String | PlayersChanged (List Player)


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    TestAction value ->
      { model | possibleWeapons = (createWeapon value) :: model.possibleWeapons }

    PlayersChanged players ->
      { model | players = players }



-- PORTS

port testPort : Signal String
port playersPort : Signal (List Player)
