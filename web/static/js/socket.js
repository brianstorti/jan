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

  let roomName = document.querySelector('.room-name').value;
  let playerName = document.querySelector('.player-name').value;
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

  document.querySelector('.game').style.display = 'block';
  document.querySelector('.name').style.display = 'none';

  elmApp.ports.chooseWeaponPort.subscribe(function (weapon) {
    channel.push("choose_weapon", { weapon: weapon});
  });

  elmApp.ports.newGamePort.subscribe(function () {
    channel.push("start_new_game");
  });

  channel.on("players_changed", payload => {
    elmApp.ports.playersPort.send(payload.players);
  });

  channel.on("result_found", payload => {
    elmApp.ports.resultFoundPort.send(payload.message);
  });

  channel.on("reset_game", payload => {
    elmApp.ports.resetGamePort.send([]);
  });
};

let handleFailedJoin = function(response) {
  document.querySelector('.error-message').style.display = 'block';
  document.querySelector('.error-message').innerHTML = response;
};

let leave = function (channel) {
  channel.push("leave");
};

export default socket;
