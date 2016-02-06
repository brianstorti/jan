module Console.Runner where

import Dict
import Json.Decode exposing ((:=))
import Json.Decode as JSD
import Json.Encode as JSE
import List exposing ((::))
import List
import Result
import Signal exposing (Signal, foldp)
import String
import Task exposing (Task)
import Trampoline

import Console.Core as Core
import Console.Core exposing (IO(..), IOF(..))
import Console.NativeCom as NativeCom
import Console.NativeCom as NC
import Console.NativeCom exposing (IRequest, IResponse)

type alias IOState  = { buffer : String }

start : IOState
start = { buffer = "" }

run : IO () -> Signal (Task x ())
run io =
  let init               = (\_ -> io, start, [NC.Init])
      f resp (io, st, _) = step resp io st
      third (_, _, z)    = z
  in NativeCom.sendRequests (Signal.map third <| foldp f init NativeCom.responses)

putS : String -> IRequest
putS = NC.Put

exit : Int -> IRequest
exit = NC.Exit

getS : IRequest
getS = NC.Get

writeF : { file : String, content : String } -> IRequest
writeF = NC.WriteFile

-- | Extract all of the requests that can be run now
extractRequests : IO a -> State IOState (List IRequest, () -> IO a)
extractRequests io =
  case io of
    Pure x -> pure ([exit 0], \_ -> Pure x)
    Impure iof -> case iof of
      PutS s k     -> mapSt (mapFst (\rs -> putS s :: rs)) <| pure ([], k)
      WriteF obj k -> mapSt (mapFst (\rs -> writeF obj :: rs)) <| pure ([], k)
      Exit n       -> pure ([exit n], \_ -> io)
      GetC k       ->
        get >>= \st ->
        case String.uncons st.buffer of
          Nothing -> pure ([getS], \_ -> io)
          Just (c, rest) ->
            put ({ buffer = rest }) >>= \_ ->
            extractRequests (k c)

flattenReqs : List IRequest -> List IRequest
flattenReqs rs =
  let loop rs acc n =
    if n >= 100
    then Trampoline.Continue (\_ -> loop rs acc 0)
    else
      case rs of
        []  -> Trampoline.Done <| List.reverse acc
        [r] -> loop [] (r::acc) (n+1)
        r1 :: r2 :: rs' ->
        case (r1, r2) of
          (NC.Exit n, _)      -> loop [] (r1::acc) (n+1)
          (NC.Put s1, NC.Put s2) -> loop (putS (s1++s2) :: rs') acc (n+1)
          _                -> loop (r2::rs') (r1::acc) (n+1)
    in Trampoline.trampoline <| loop rs [] 0

-- | We send a batch job of requests, all requests until IO blocks
step : IResponse ->
       (() -> IO a) ->
       IOState ->
       (() -> IO a, IOState, List IRequest)
step resp io st =
  let newST = case resp of
        Nothing -> st
        Just s  -> { buffer = String.append st.buffer s }
      (newST', (rs, k)) = extractRequests (io ()) newST
  in (k, newST', rs)

-- | State monad
type alias State s a = s -> (s, a)

pure : a -> State s a
pure x = \s -> (s, x)

mapSt : (a -> b) -> State s a -> State s b
mapSt f sf = sf >>= (pure << f)

(>>=) : State s a -> (a -> State s b) -> State s b
(>>=) f k = \s -> let (s', y) = f s
                in k y s'

get : State s s
get = \s -> (s, s)

put : s -> State s ()
put s = \_ -> (s, ())

mapFst : (a -> b) -> (a,c) -> (b,c)
mapFst f (x,y) = (f x, y)
