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
    resultMessage : String
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
                    (Signal.map PlayersChanged playersPort),
                    (Signal.map (\_ -> ResetGame) resetGamePort),
                    (Signal.map ResultFound resultFoundPort)]


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
    resultMessage = ""
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


resultView : Address Action -> Model -> Html
resultView address model =
  if String.isEmpty(model.resultMessage) then
     div [] []
  else
    div [ class "row result-wrapper" ]
        [ h1 [ class "result" ]
             [ text model.resultMessage ],

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
      resultView address model
    ]


-- UPDATE


type Action
      = NoOp
      | PlayersChanged (List Player)
      | ResultFound String
      | ResetGame


update : Action -> Model -> Model
update action model =
  case action of
    NoOp ->
      model

    PlayersChanged players ->
      { model | players = players }

    ResultFound message ->
      { model | resultMessage = message }

    ResetGame ->
      { model| resultMessage = "" }



-- PORTS

port playersPort : Signal (List Player)
port resultFoundPort : Signal String
port resetGamePort : Signal ()

port chooseWeaponPort : Signal String
port chooseWeaponPort =
  chooseWeaponMailbox.signal

port newGamePort : Signal ()
port newGamePort =
  newGameMailbox.signal
