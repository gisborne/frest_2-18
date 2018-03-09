#!ruby
require 'rack'

module FREST
  class HTTP < BaseContext
    class << self
      def start(
          context: NullContext.new
      )
        Rack::Handler::WEBrick.run ->(env) do
          req    = Rack::Request.new(env)
          path   = req.path
          params = req.params

          result = context.resolve(
            path:    path,
            context: HashContext.new(params)
          )
          return ['200', {'Content-Type' => 'text/html'}, [*result]]
        end
      end

      def resolve_locally(
        path: [],
        context: NullContext.new      )
      end
    end
  end
end
