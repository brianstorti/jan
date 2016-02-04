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

chooseWeaponMailbox : Signal.Mailbox String
chooseWeaponMailbox =
  Signal.mailbox ""


newGameMailbox : Signal.Mailbox ()
newGameMailbox =
  Signal.mailbox ()

-- MODEL

type alias Model =
  {
    possibleWeapons : List Weapon,
    players : List Player,
    winner : String
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
                    (Signal.map PlayersChanged playersPort),
                    (Signal.map WinnerFound winnerFoundPort)]


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

    players = [],
    winner = ""
  }


-- VIEW


weaponView : Address Action -> Weapon -> Html
weaponView address weapon =
  let
    iconClassName = "fa-hand-" ++ String.toLower(weapon.name) ++ "-o"
  in
    div
      [ class "medium-4 columns" ]
      [ a
          [ class "weapon-wrapper", onClick chooseWeaponMailbox.address (String.toLower weapon.name)]
          [ i [ class ("weapon fa fa-5x " ++ iconClassName) ] [],
            p [ class "weapon-label" ] [ text weapon.name ]
          ]
      ]

playerWeaponView : Address Action -> Player -> Html
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



playerView : Address Action -> Player -> Html
playerView address player =
  div
    [ class "large-4 medium-4 columns" ]
    [ div [ class "score round label"] [ text (toString player.score) ],
      div [] [ playerWeaponView address player ]
    ]


header : Html
header =
  h1 [] [ text "Choose your weapon" ]


weaponsList : Address Action -> Model -> Html
weaponsList address model =
  div
    [ class "row weapons" ]
    (List.map (weaponView address) model.possibleWeapons)


playersList : Address Action -> Model -> Html
playersList address model =
  div
    [ class "row players" ]
    (List.map (playerView address) model.players)


winnerView : Address Action -> Model -> Html
winnerView address model =
  if String.isEmpty(model.winner) then
     div [] []
  else
    div [ class "row result-wrapper" ]
        [ h1 [ class "result" ]
             [ text ("Winner found: " ++ model.winner) ],

          a [ class "new-game button", onClick newGameMailbox.address () ]
            [ text "New Game" ] ]


view : Address Action -> Model -> Html
view address model =
  div
    [ class "row game" ]
    [
      header,
      weaponsList address model,
      playersList address model,
      winnerView address model
    ]


-- UPDATE


type Action
      = NoOp
      | TestAction String
      | PlayersChanged (List Player)
      | WinnerFound String
      -- | ResetGame


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    TestAction value ->
      { model | possibleWeapons = (createWeapon value) :: model.possibleWeapons }

    PlayersChanged players ->
      { model | players = players }

    WinnerFound playerName ->
      { model | winner = playerName }



-- PORTS

port testPort : Signal String
port playersPort : Signal (List Player)
port winnerFoundPort : Signal String

port chooseWeaponPort : Signal String
port chooseWeaponPort =
  chooseWeaponMailbox.signal

port newGamePort : Signal ()
port newGamePort =
  newGameMailbox.signal
