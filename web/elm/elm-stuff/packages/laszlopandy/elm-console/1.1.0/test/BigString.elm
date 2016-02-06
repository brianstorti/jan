module Main where

import Console exposing ((>>=), putStrLn)
import String
import Task

hugeString () = String.concat <| List.repeat 10000000 "blah "

port runner : Signal (Task.Task x ())
port runner = Console.run (putStrLn "hah" >>= \_ -> putStrLn (hugeString ()))
