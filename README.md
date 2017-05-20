# Jan

A [rock paper scissors](https://en.wikipedia.org/wiki/Rock-paper-scissors) game written in [`Elixir`](http://elixir-lang.org/) and [`Elm`](http://elm-lang.org).

### [Try it](https://jkp.herokuapp.com).

![demo](/docs/demo.gif)


> Disclaimer: This is the first *thing* I try to build with `Elm` and `Elixir`, so the code is certainly not exemplary. Feedbacks are appreciated.

#### Running it locally

`Jan` is a normal `Phoenix` application, so the steps to run it are pretty standard, assuming you have `Elixir` and `Elm` installed:

```
$ mix deps.get && npm install && mix phoenix.server
```

It should be running at [`http://localhost:4000`](http://localhost:4000).

To run the tests:

```
$ mix test
```

#### Looking at the code

If you interested in the `Elm` part, you should take a look at [`Jan.elm`](/web/elm/Jan.elm) and [`socket.js`](/web/static/js/socket.js).  
For the `Elixir` code, probably the [`RoomChannel`](/web/channels/room_channel.ex) and the [`GameServer`](/lib/jan/game_server.ex) modules.
