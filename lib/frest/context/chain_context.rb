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
      [*mode].each do |m|
        @chain.each do |c|
          result = c.resolve(
            context: self,
            mode:    m,
            path:    path,
            **extra
          )

          return result if result
        end
      end

      # no resolution
      nil
    end
  end
end
