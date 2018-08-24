require 'context_shared'

module FREST
  class Ruby < BaseContext
    include ContextShared

    def initialize
      @fns_src = 'ruby'
    end

    def resolve(
      **args
    )
      fn = resolve_internal(**args)
      if fn && fn.length > 0
        return fn.first.call(
          context: context,
          **args
        )
      end
    end


    def resolve_options(
      **args
    )
      fn = resolve_internal(**args)

      if fn && fn.length > 0
        fn.map do
          # what to return here?
          # how to indicate result type, both of the group, and of the elements?
        end
      end
    end



    private

    def resolve_internal(
      match: {},
      modes: DEFAULT_MODES,
      context: NullContext.new,
      path: [],
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

        return fn
      end

      nil
    end

    def load_from_path(
      path:,
      mode: nil,
      **_
    )
      return nil if path.length == 0 || (path.length == 1 && path.first == '')

      fn_path = relative_path(path)
      fn_name = fn_path.last

      if fn_name =~ /\.rb$/
        actual_path = File.join(File.dirname(__FILE__), "../../../ruby/#{fn_path.join('/')}")
      else
        actual_path = File.join(File.dirname(__FILE__), "../../../ruby/#{fn_path.join('/')}.rb")
      end

      thread          = Thread.current
      thread[:new_fn] = nil

      begin
        load actual_path
        fn = thread[:new_fn]
          # @fn_cache[fn_name] = fn
      rescue LoadError
      end

      return fn if fn && (!mode || fn.meta[:mode] == mode)
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
            path: prev_path + [f],
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

    def relative_path(path)
      if path.first == ''
        path[1..-1]
      else
        path
      end
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
