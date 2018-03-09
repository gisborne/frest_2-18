module FREST
  class NullContext
    def resolve(
        path:,
        context: self
    )
      return nil
    end

    def resolve_strong(
      path: [],
      context: self
    )
      return nil
    end

    def resolve_weak(
      path: [],
      context: self
    )
      return nil
    end
  end
end
