require 'base_context'
require 'null_context'

module FREST
  class ChainContext < BaseContext
    def initialize(*contexts)
      @chain = contexts
    end

    def head
      @chain.head rescue NullContext.new
    end

    def tail
      @chain.tail rescue NullContext.new
    end

    def resolve(
      mode: DEFAULT_MODES,
      path: [],
      **extra
    )
      return result if (
        result = resolve_options(
          mode: mode,
          path: path,
          **extra)
      )

      if [*mode].include? 'strong'
        @chain.each do |c|
          result = c.resolve(
            context: self,
            mode:    'strong',
            path:    path,
            **extra
          )

          return result if result
        end
      end

      if [*mode].include? 'weak'
        @chain.reverse.each do |c|
          result = c.resolve(
            context: self,
            mode:    'weak',
            path:    path,
            **extra
          )

          return result if result
        end
      end

      # no resolution
      nil
    end


    private

    def resolve_options(
      mode:,
      path:,
      **c
    )
      return nil unless path = after_options_path(
        path: path,
        **c
      )


    end

    def after_options_path(
      path: path,
      args: args,
      **c
    )
      if path.length > 0 && path.first == 'options'
        return path[1..-1]
      elsif args['_method'] == 'options'
        return path
      else
        return nil
      end
    end
  end
end
