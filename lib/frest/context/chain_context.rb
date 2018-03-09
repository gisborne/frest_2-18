require 'base_context'
require 'null_context'

module FREST
  class ChainContext < BaseContext
    def initialize(*contexts)
      @chain = contexts
    end

    def resolve(
        path: [],
        context: NullContext.new
    )
      return (
        resolve_strong(
          path: path
        ) ||
        context.resolve(
            path: path
        ) ||
        resolve_weak(
            path: path
        )
      )
    end

    def resolve_strong(
        path: []
    )
      @chain.each do |c|
        result = c.resolve_strong(
            path: path
        )
        return result if result
        nil
      end

      return nil
    end

    def resolve_weak(
        path: []
    )
      @chain.reverse_each do |c|
        return result = c.resolve_weak(
            path:    path,
            context: context
        ) if result
      end

      return nil
    end
  end
end
