module Mailbox where

import Action exposing (..)

inbox : Signal.Mailbox Action
inbox =
  Signal.mailbox NoOp


chooseWeaponMailbox : Signal.Mailbox String
chooseWeaponMailbox =
  Signal.mailbox ""


newGameMailbox : Signal.Mailbox ()
newGameMailbox =
  Signal.mailbox ()
