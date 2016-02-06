import {Socket} from "phoenix";

let socket = new Socket("/socket");

document.addEventListener('DOMContentLoaded', function() {
  let playerName = document.getElementsByClassName('player-name')[0];
  if (!playerName) return;

  playerName.addEventListener("keypress", e => {
    if (e.keyCode == 13) {
      init();
    }
  });
});

let init = function() {
  socket.connect();

  let roomName = document.getElementsByClassName('room-name')[0].value;
  let playerName = document.getElementsByClassName('player-name')[0].value;
  let channel = socket.channel("rooms:" + roomName, { player_name: playerName });

  channel.join().receive("error", handleFailedJoin)
                .receive("ok", response => { handleSuccessfulJoin(response, channel, playerName); });

  window.onbeforeunload = function () {
    leave(channel);
  };

};

let handleSuccessfulJoin = function(response, channel, playerName) {
  let elmApp = Elm.fullscreen(Elm.Jan, { playersPort: [],
                                         resultFoundPort: "",
                                         currentPlayerPort: "",
                                         resetGamePort: []});

  elmApp.ports.currentPlayerPort.send(playerName);

  document.getElementsByClassName('game')[0].style.display = 'block';
  document.getElementsByClassName('name')[0].style.display = 'none';

  elmApp.ports.chooseWeaponPort.subscribe(function (weapon) {
    channel.push("new_move", { move: weapon});
  });

  elmApp.ports.newGamePort.subscribe(function () {
    channel.push("new_game");
  });

  channel.on("players_changed", payload => {
    elmApp.ports.playersPort.send(payload.players);
  });

  channel.on("result_found", payload => {
    elmApp.ports.resultFoundPort.send(payload.message);
  });

  channel.on("reset", payload => {
    elmApp.ports.resetGamePort.send([]);
  });
};

let handleFailedJoin = function(response) {
  document.getElementsByClassName('error-message')[0].style.display = 'block';
  document.getElementsByClassName('error-message')[0].innerHTML = response;
};

let leave = function (channel) {
  channel.push("leave");
};

export default socket;
