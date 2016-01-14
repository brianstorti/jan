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

  $('.button1').on("click", event => {
    channel.push("new_move", { body: "foo" })
  });

  $('.leave').on('click', e => {
    leave(channel);
  })

  window.onbeforeunload = function () {
    leave(channel);
  }

  channel.on("new_move", payload => {
    $('.moves_container').append("<li>Foo</li>")
  })

  channel.on("new_player_joined", payload => {
    let players = payload.players.map(player => { return `<li>${player}</li>` })
    $('.players').html(players)
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
