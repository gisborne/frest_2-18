#!ruby
require 'rack'

module FREST
  class HTTP < BaseContext
    require 'mustache'

    class << self
      def start(
        context:
      )
        @template = File.read('lib/frest/http/templates/base_template.mustache')

        Rack::Handler::WEBrick.run ->(env) do
          req    = Rack::Request.new(env)
          path   = path_to_array(req.path)
          params = req.params

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

          if result
            content_type = content_type_from_path(path: path)
            return [
              '200',
              {
                'Content-Type' => content_type
              },
              lay_out(
                content:      result,
                content_type: content_type
              )
            ]
          else
            return [404, nil, []]
          end
        end
      end

      def resolve_locally(
        path: [],
        context: NullContext.new)
      end


      private

      def lay_out content:, content_type:
        return [content] unless content_type == 'text/html'

        [Mustache.render(@template, content: content)]
      end

      def content_type_from_path(path:)
        return 'text/javascript' if path.length > 0 && path.last =~ /\.js$/

        'text/html'
      end

      def path_to_array path
        p = path.split('/')
        p.pop! if p.length > 0 && p.last == ''

        p
      end
    end
  end
end
