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


-- VIEW


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
      header model,
      weaponsList address model,
      playersList address model,
      resultView address model
    ]


-- UPDATE


type Action
      = NoOp
      | PlayersChanged (List Player)
      | ShowResult String
      | ResetGame
      | DefineCurrentPlayer String


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



-- PORTS

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
