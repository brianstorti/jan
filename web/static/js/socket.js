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
    let weapon = $(e.currentTarget).data('move')
    channel.push("new_move", { move: weapon});
    $(`.player-${playerName}`).html(weaponView(playerName, weapon));
  });

  $("#new-game").on("click", function (e) {
    channel.push("new_game");
  });

  channel.on("players_changed", payload => {
    let players = payload.players.map(playerView);
    $('.players').html(players);
  });

  channel.on("winner_found", payload => {
    $('.result-wrapper').show();
    $('.result').html(`${payload.player_name} won!`);
  });

  channel.on("draw", payload => {
    $('.result-wrapper').show();
    $('.result').html(`It's a draw!`);
  });

  channel.on("reset", payload => {
    $('.result-wrapper').hide();
    $('.weapons.weapon-wrapper').removeClass('-disabled');
  });
};

let handleSuccessfulJoin = function(response) {
  $('.game').show();
  $('.name').hide();
  console.log("Joined successfully", response);
};

let handleFailedJoin = function(response) {
  console.log("Unable to join", response);
};

let leave = function (channel) {
  channel.push("leave");
};

let playerView = function (player) {
    return `<div class="player-${player.name} large-4 medium-4 columns">` +
             weaponView(player.name, player.move) +
           '</div>';
};

let weaponView = function (playerName, weapon) {
  if (weapon) {
     return `<a data-move="${weapon}" class="weapon-wrapper -disabled">` +
               `<p class="weapon-label">${playerName}</p>` +
               `<i class="weapon fa fa-5x fa-hand-${weapon}-o"></i> ` +
               `<p class="weapon-label">${weapon}</p>` +
             '</a>';
  } else {
     return '<a data-move="scissors" class="weapon-wrapper -disabled">' +
               `<p class="weapon-label">${playerName}</p>` +
               '<i class="weapon fa fa-5x fa-question"></i> ' +
               '<p class="weapon-label">...</p>' +
             '</a>';
  }
};

export default socket;
