#!ruby
require 'nanomsg'
require_relative '../shared/local_store.rb'

module FREST_RUBY
  @store = LocalStore.new name: 'ruby'

  module_function

  def start **args
    @ruby = FrestProxy.new(io: NanoMsg::PairSocket.new.bind('ipc:///tmp/frest.ipc'))
  end
end

if __FILE__==$0
  FREST_RUBY.start
end
