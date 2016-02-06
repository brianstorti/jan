module Main where

import Console exposing (IO, (>>>), writeFile, putStrLn)
import Task

console : IO ()
console = writeFile { file = "Test.txt", content = "Hello, Test!\n" } >>>
          putStrLn "Printed to file: Test.txt"

port runner : Signal (Task.Task x ())
port runner = Console.run console
