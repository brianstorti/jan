module Main where

import Console exposing (IO, (>>>), (>>=), forever, getLine, pure, exit, putStrLn)
import Task

import List
import Maybe
import String

echo : IO ()
echo = forever (getLine >>= putStrLn)

loop : IO ()
loop = getLine >>= \s ->
       if s == "exit"
       then pure ()
       else putStrLn s >>> loop
       
hello : IO ()
hello = putStrLn "Hello, Console!" >>>
        putStrLn "I'll echo your input until you say \"exit\":" >>>
        loop >>>
        putStrLn "That's all, folks!" >>>
        exit 0

port runner : Signal (Task.Task x ())
port runner = Console.run hello
