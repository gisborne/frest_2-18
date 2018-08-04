#!ruby
module FREST
  class HTTP < BaseContext
    # require 'rack'
    # require 'goliath'
    require 'mustache'
    require 'faye'
    require 'thin'
    # require 'permessage_deflate'

    class << self
      def start(
        context:
      )
        @template = File.read('lib/frest/http/templates/base_template.mustache')

        Faye::WebSocket.load_adapter 'thin'

        app = Rack::Builder.new do
          use Rack::CommonLogger
          use Rack::ShowExceptions
          use Faye::RackAdapter, mount: '/ws', timeout: 5 do |bayeux|
            @bayeux = bayeux
            # bayeux.add_websocket_extension(PermessageDeflate)
            bayeux.on(:subscribe) {|id, channel|
              p "subscribe #{id} #{channel}"}
            bayeux.on(:publish) {|id, channel, data|
              p "publish #{id} #{channel} #{data}"}
          end

          run ->(env) do
            if Faye::WebSocket.websocket?(env)
              ws = Faye::WebSocket.new(env)

              ws.on :message do |event|
                ws.send(event.data)
              end

              ws.on :close do |event|
                p [:close, event.code, event.reason]
                ws = nil
              end

              # Return async Rack response
              ws.rack_response

            else
              return FREST::HTTP.normal_web(
                context: context,
                env:     env
              )
            end
          end
        end

        Rack::Handler.get('thin').run app, Port: 8080


        require 'eventmachine'

        EM.run {
        client = Faye::Client.new('http://localhost:8080/ws')

          client.subscribe('/test') do |message|
            p message.inspect
          end

        }
      end

      def normal_web(
        context:,
        env:
      )
        req = Rack::Request.new(env)

        result = context.resolve(
          match:  {
            tag:         'presenter',
            result_type: 'html'
          },
          args:   fn_args(req),
          method: req.request_method
        )

        if result
          content_type = content_type(
            req
          )
          return [
            '200',
            {
              'Content-Type' => content_type,
              'Content-Security-Policy' => "default-src 'self'"
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



private

      def fn_args req
        path              = path_to_array(req.path)
        params            = req.params

        params['_method'] = 'options' if req.options?

        {
          path:   path,
          params: params
        }
      end

      def lay_out content:, content_type:
        return [content] unless content_type == 'text/html'

        [Mustache.render(@template, content: content)]
      end

      def content_type req
        path = path_to_array(req.path)
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
