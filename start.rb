# this is out of date. See the separate files which will be started directly

fork do
  require_relative 'lib/http/http.rb'
  FREST_HTTP.start(
    mounts: {'/ruby': FrestProxy.new(ruby_socket)}
  )
end

require_relative 'lib/ruby/ruby.rb'
FREST_RUBY.start(
  mounts: {'/http': FrestProxy.new(http_socket)}
)
