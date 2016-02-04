import {Socket} from "phoenix";

let socket = new Socket("/socket");

document.addEventListener('DOMContentLoaded', function() {
  $('.player-name').off("keypress").on("keypress", e => {
    if (e.keyCode == 13) {
      init();
    }
  });
});

let init = function() {
  socket.connect();

  let roomName = $('.room-name').val();
  let playerName = $('.player-name').val();
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

  $('.game').show();
  $('.name').hide();

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
    console.log("reset");
    elmApp.ports.resetGamePort.send([]);
  });
};

let handleFailedJoin = function(response) {
  $('.error-message').html(response);
  $('.error-message').show();
};

let leave = function (channel) {
  channel.push("leave");
};

export default socket;
