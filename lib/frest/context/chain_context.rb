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
      method: 'GET',
      **extra
    )
      return result if (
        result = resolve_options(
          mode:   mode,
          path:   path,
          method: method,
          **extra
        )
      )

      with_chain(mode) do |c, m|
        result = c.resolve(
          context: self,
          mode:    m,
          path:    path,
          **extra
        )

        return result if result
      end

      # no resolution
      nil
    end


    private

    def resolve_options(
      mode:,
      path:,
      method:,
      args:,
      **c
    )

      return nil unless path = after_options_path(
        path:   path,
        method: method,
        args:   args,
        **c
      )

      with_chain(mode) do |c, m|
        result = c.resolve_options(
          context: self,
          mode:    m,
          path:    path,
          **c
        )

        return result if result
      end

      nil
    end

    def after_options_path(
      path:,
      method:,
      args:,
      **c
    )
      if method == 'OPTIONS'
        return path
      elsif path.length > 0 && path.first == 'options'
        return path[1..-1]
      elsif args['_method'] == 'options'
        return path
      else
        return nil
      end
    end

    def with_chain(mode)
      modes = [*mode]
      modes.each do |m|
        if mode == 'strong'
          @chain.each do |c|
            yield c, m
          end
        else
          @chain.reverse.each do |c|
            yield c, m
          end
        end
      end
    end
  end
end
