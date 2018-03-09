require 'context_shared'

module FREST
  class Ruby < BaseContext
    include ContextShared

    def resolve_strong(
        path: [],
        context: nil
    )
      p = fix_path path
      f = get_fn p
      if f
        if f.meta[:strong]
          return f.call **(context || {})
        else
          return nil
        end
      end
    end

    def resolve_weak(
        path: [],
        context: nil
    )
      p = fix_path path
      f = get_fn path
      if f
        if f.meta[:weak]
          return f.call **(context || {})
        else
          return nil
        end
      end
    end

    private

    def get_fn path
      actual_path = File.join(File.dirname(__FILE__), "../../../ruby/#{path.first}.rb")

      thread          = Thread.current
      thread[:new_fn] = nil

      load actual_path rescue nil

      thread[:new_fn]
    end
  end

  module_function

  def defn **args, &block
    Thread.current[:new_fn] = RubyFn.new **args, &block
  end
end

class RubyFn
  attr_accessor :meta

  def initialize **meta, &block
    @meta = meta
    @fn  = block
  end

  def call **args
    @fn.call **args
  end
end
