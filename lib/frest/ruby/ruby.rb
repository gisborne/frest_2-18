require 'context_shared'

module FREST
  class Ruby < BaseContext
    include ContextShared

    def initialize
      @fns_src = 'ruby'
    end

    def resolve(
      mode:,
      path: nil,
      **extra
    )
      if path
        fn = [
          *load_from_path(
            mode: mode,
            path: path,
            **extra
          )
        ]
      else
        fn = matching_fns(
          mode: mode,
          **extra
        )
      end

      if fn
        fn.first.call(**extra)
      else
        nil
      end

    end

    private

    def load_from_path(
      mode:,
      path:,
      **_
    )
      fn_name     = fix_path(path).first
      actual_path = File.join(File.dirname(__FILE__), "../../../ruby/#{fn_name}.rb")

      thread          = Thread.current
      thread[:new_fn] = nil

      begin
        load actual_path
        fn = thread[:new_fn]
          # @fn_cache[fn_name] = fn
      rescue LoadError
      end

      return fn if fn.meta[:mode] == mode
      nil
    end

    def matching_fns(
      **args
    )
      all_fns.select do |fn|
        fn.matches(
          **args
        )
      end
    end
  end

  def all_fns(
    src: @fns_src
  )
    result = []
    src.each_child do |f|
      if File.directory? f
        result << all_fns(
          src: f
        )
      else
        result << f
      end
    end

    result.flatten
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
    @fn   = block
  end

  def matches(**args)
    if m = @meta[:match]
      begin
        return m.call(**args)
      rescue
        nil
      end
    end
  end

  def call **args
    @fn.call **args
  end
end
