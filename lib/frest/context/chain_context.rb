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
      **c
    )
      if method == 'OPTIONS'
        return resolve_options(
          mode:   mode,
          path:   path,
          method: method,
          **c
        )
      end

      with_chain(mode) do |ch, m|
        result = ch.resolve(
          context: self,
          mode:    m,
          path:    path,
          **c
        )

        return result if result
      end

      # no resolution
      nil
    end

    def resolve_options(
      mode:,
      path:,
      method:,
      **c
    )

      return nil unless path = after_options_path(
        mode:   mode,
        path:   path,
        method: method,
        **c
      )

      with_chain(mode) do |ch, m|
        result = ch.resolve_options(
          context: self,
          mode:    m,
          path:    path,
          method:  method,
          **c
        )

        return result if result
      end

      nil
    end


    private

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
          @chain.each do |ch|
            yield ch, m
          end
        else
          @chain.reverse.each do |ch|
            yield ch, m
          end
        end
      end
    end
  end
end
