require 'context_shared'

module FREST
  class Ruby < BaseContext
    include ContextShared

    def initialize
      @fns_src = 'ruby'
    end

    def resolve(
      match: {},
      modes: DEFAULT_MODES,
      context: NullContext.new,
      path: nil,
      args: {},
      **extra
    )
      [*modes].each do |mode|
        if match && ! match.empty?
          fn = matching_fns(
            mode: mode,
            **match
          )
        else
          if path
            fn = [
              *load_from_path(
                mode: mode,
                path: path,
                **extra
              )
            ]
          end
        end

        if fn && fn.length > 0
          return fn.first.call(
            context: context,
            **args
          )
        end
      end

      nil
    end

    private

    def load_from_path(
      mode: nil,
      path:,
      **_
    )
      fn_name = fix_path(path).first
      if fn_name =~ /\.rb$/
        actual_path = File.join(File.dirname(__FILE__), "../../../ruby/#{fn_name}")
      else
        actual_path = File.join(File.dirname(__FILE__), "../../../ruby/#{fn_name}.rb")
      end

      thread          = Thread.current
      thread[:new_fn] = nil

      begin
        load actual_path
        fn = thread[:new_fn]
          # @fn_cache[fn_name] = fn
      rescue LoadError
      end

      return fn if !mode || fn.meta[:mode] == mode
      nil
    end

    def matching_fns(
      src: @fns_src,
      prev_path: [],
      **args
    )
      result = []
      Dir.each_child(src) do |f|
        if File.directory? f
          result += all_fns(
            prev_path: prev_path + f,
            src:       f
          ).to_a
        else
          loaded = load_from_path(
            path: prev_path.join('/') + f,
            **args
          )
          if loaded&.matches?(
            **args
          )
            result << loaded
          end
        end
      end

      result.flatten
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
    @fn   = block
  end

  def matches?(
    **matches
  )
    if m = @meta[:match]
      begin
        return m.call(**matches)
      rescue
        nil
      end
    end
  end

  def call **args
    @fn.call **args
  end
end
