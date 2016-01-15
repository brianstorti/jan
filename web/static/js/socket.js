import {Socket} from "phoenix";

let socket = new Socket("/socket");

document.addEventListener('DOMContentLoaded', function() {
  $('#join-room-form').on("submit", event => {
    event.preventDefault();
    init();
  });
});

let init = function() {
  socket.connect();

  let roomName = document.getElementById('room-name').value;
  let playerName = document.getElementById('player-name').value;
  let channel = socket.channel("rooms:" + roomName, { player_name: playerName });

  channel.join().receive("ok", handleSuccessfulJoin)
                .receive("error", handleFailedJoin);

  window.onbeforeunload = function () {
    leave(channel);
  };

  $("[data-move]").on("click", function (e) {
    channel.push("new_move", { move: $(e.target).data('move') });
  });

  channel.on("players_changed", payload => {
    let players = payload.players.map(playerView);
    $('.players').html(players);
  });

  channel.on("winner_found", payload => {
    $('.game').append(`<p>${payload.player_name} won!</p>`);
  });
};

let handleSuccessfulJoin = function(response) {
  $('.game').show();
  $('#join-room-form').hide();
  console.log("Joined successfully", response);
};

let handleFailedJoin = function(response) {
  console.log("Unable to join", response);
};

let leave = function (channel) {
  channel.push("leave");
};

let playerView = function (player) {
  return `<div class="${player.name}">` +
           '<div class="columns small-5">' +
             `<span>${player.name}</span>` +
             weaponView(player.move) +
           '</div>' +
         '</div>';
}

let weaponView = function (weapon) {
  if (weapon) {
    return `<span>${weapon}</span>`;
  } else {
    return `<span>?</span>`;
  }
}

export default socket;
