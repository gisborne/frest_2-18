#!ruby
require 'rack'

module FREST
  class HTTP < BaseContext
    class << self
      def start(
        context:
      )
        Rack::Handler::WEBrick.run ->(env) do
          req    = Rack::Request.new(env)
          path   = req.path
          params = req.params

          result, type = get_asset(path)
          if result
            return ['200', { 'Content-Type' => type }, [result]]
          else
            result = context.resolve(
              match: {
                tag:         'presenter',
                result_type: 'html'
              },
              args:  {
                path:   path,
                params: params
              }
            )


            return ['200', { 'Content-Type' => 'text/html' }, [*result]]
          end
        end
      end

      def resolve_locally(
        path: [],
        context: NullContext.new)
      end

      def get_asset path
        if path == '/favicon.ico'
          return File.read(File.join(File.dirname(__FILE__), 'assets/favicon.ico')), 'image/ico'
        end
      end
    end
  end
end
