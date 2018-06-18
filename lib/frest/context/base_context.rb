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
      **_
    )
      raise NotImplementedError
    end

    def resolve_options(
      **_
    )
      raise NotImplementedError
    end

    def meta(
      path:     [],
      context:  nil
    )
      raise NotImplementedError
    end

    class << self
      def start
        #do nothing
      end
    end
  end
end
