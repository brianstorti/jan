import {Socket} from "phoenix"

let socket = new Socket("/socket")

document.addEventListener('DOMContentLoaded', function() {
  if (!document.getElementById('rooms')) return;

  socket.connect()

  let roomName = document.getElementById('room-name').value
  let channel = socket.channel("rooms:" + roomName, {})

  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  $('.button1').on("click", event => {
    channel.push("new_move", { body: "foo" })
  });

  channel.on("new_move", payload => {
    $('.moves_container').append("foo")
  })
});

export default socket
