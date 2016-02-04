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
    resultMessage : String,
    currentPlayer : String
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
                    (Signal.map DefineCurrentPlayer currentPlayerPort),
                    (Signal.map (\_ -> ResetGame) resetGamePort),
                    (Signal.map ShowResult resultFoundPort)]


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
    resultMessage = "",
    currentPlayer = ""
  }


-- VIEW


weaponView : Address Action -> Model -> Weapon -> Html
weaponView address model weapon =
  let
    iconClassName = "fa-hand-" ++ String.toLower(weapon.name) ++ "-o"
    disabledClass = if String.isEmpty(model.resultMessage) then "" else "-disabled"
  in
    div
      [ class "medium-4 columns" ]
      [ a
          [ class ("weapon-wrapper " ++ disabledClass), onClick chooseWeaponMailbox.address (String.toLower weapon.name)]
          [ i [ class ("weapon fa fa-5x " ++ iconClassName) ] [],
            p [ class "weapon-label" ] [ text weapon.name ]
          ]
      ]

playerWeaponView : Address Action -> Player -> Model -> Html
playerWeaponView address player model =
  let
      shouldHideWeapon =
        String.isEmpty(model.resultMessage) &&
        (String.isEmpty(player.move) || player.name /= model.currentPlayer)

      iconClassName = if shouldHideWeapon
                         then "fa-question"
                         else "fa-hand-" ++ String.toLower(player.move) ++ "-o"

      weaponDescription = if shouldHideWeapon then "..." else player.move
  in
     a
       [ class "weapon-wrapper -disabled" ]
       [ p [ class "weapon-label" ] [ text player.name ],
         i [ class ("weapon fa fa-5x " ++ iconClassName) ] [],
         p [ class "weapon-label" ] [ text weaponDescription ]
       ]



playerView : Address Action -> Model -> Player -> Html
playerView address model player =
  div
    [ class "large-4 medium-4 columns" ]
    [ div [ class "score round label"] [ text (toString player.score) ],
      div [] [ playerWeaponView address player model ]
    ]


header : Html
header =
  h1 [] [ text "Choose your weapon" ]

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
      invite,
      header,
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
