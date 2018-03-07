#!ruby
require 'rack'
require 'nanomsg'
require_relative '../shared/local_store.rb'

module FREST_HTTP

  module_function

  def start **_
    @store = LocalStore.new name: 'http'

    sock = NanoMsg::PairSocket.new
    sock.bind('ipc:///tmp/frest.ipc')

    @ruby = FrestProxy.new(io: sock)

    fork do
      loop do
        sock.recv do |msg|
          path, args, respond_to = split_msg msg

          result = resolve_locally path: path, **args
          @ruby.respond path: path, **result
        end
      end
      end

    Rack::Handler::WEBrick.run ->(env) do

      ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
    end
  end

  private

  def split_msg j
    p = j.delete 'path'
    if p
      path = p.split '/'
    else
      path = []
    end

    respond_to = j.delete 'respond_to'

    return p, j, respond_to
  end

  def resolve_locally path:, **args

  end
end

# if __FILE__ == $0
#
# end

=begin
TODO
  On connection, allocate an ID and return a blank page with javascript that opens a websocket.
  The javascript allows the socket to replace part of the page by id.

  On startup,
=end
