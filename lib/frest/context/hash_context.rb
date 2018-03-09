require 'context_shared'

module FREST
  class HashContext < BaseContext
    include ContextShared

    def initialize(h)
      @hash = h
    end

    def resolve(
      path: [],
      context: NullContext.new
    )
      p = fix_path(path)
      @hash[p.first] ||
          context.resolve(path: path, context: context)
    end
  end
end
