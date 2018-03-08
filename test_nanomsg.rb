require 'nanomsg'

fork do
  sock = NanoMsg::PairSocket.new
  sock.bind 'ipc:///tmp/test.sock'

  loop do
    sock.send 'foo'
    sleep 1
  end
end

sock = NanoMsg::PairSocket.new
sock.connect 'ipc:///tmp/test.sock'
loop do
  x = sock.recv
  p x

end
