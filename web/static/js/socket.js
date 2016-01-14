import {Socket} from "phoenix"

let socket = new Socket("/socket")

document.addEventListener('DOMContentLoaded', function() {
  $('#join-room-form').on("submit", event => {
    event.preventDefault();
    init();
  });
});

let init = function() {
  socket.connect()

  let roomName = document.getElementById('room-name').value
  let playerName = document.getElementById('player-name').value
  let channel = socket.channel("rooms:" + roomName, { player_name: playerName })

  channel.join().receive("ok", handleSuccessfulJoin)
                .receive("error", handleFailedJoin)

  $("[data-move]").on("click", function (e) {
    channel.push("new_move", { move: $(e.target).data('move') });
  });

  window.onbeforeunload = function () {
    leave(channel);
  }

  channel.on("new_move", payload => {
    $('.moves_container').append("<li>Foo</li>")
  })

  channel.on("players_changed", payload => {
    console.log("payload.players", payload.players);

    let players = payload.players.map(player => { return `<li>${player}</li>` })
    $('.players').html(players)
  })

  channel.on("winner_found", payload => {
    $('.game').append(`<p>${payload.player_name} won!</p>`)
  })
}

let handleSuccessfulJoin = function(response) {
  $('.game').show();
  $('#join-room-form').hide();
  console.log("Joined successfully", response);
}

let handleFailedJoin = function(response) {
  console.log("Unable to join", response);
}

let leave = function (channel) {
  channel.push("leave");
  $('.game').hide();
  $('#join-room-form').show();
}

export default socket
