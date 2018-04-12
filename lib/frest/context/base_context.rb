module FREST
  class BaseContext
    DEFAULT_MODES = ['strong', 'weak']

    def initialize *a, **b
      # do nothing
    end

    def + c
      ChainContext.new(self, c)
    end

    def resolve(
        path: [],
        context: nil
    )
      raise NotImplementedError
    end

    def meta(
        path: [],
        context: nil
    )
      raise NotImplementedError
    end

    def resolve_locally
      raise NotImplementedError
    end

    class << self
      def start
        #do nothing
      end
    end
  end
end
