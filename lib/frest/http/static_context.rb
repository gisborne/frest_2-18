require 'context_shared'

module FREST
  class StaticContext < BaseContext
    ASSET_ROOT = Pathname.new 'lib/frest/http/assets'

    def resolve(
      args: {},
      **extra
    )
      # Doesn't work as the default value (?)
      path        = args[:path]
      return nil unless path

      target_path = ASSET_ROOT + cleaned_path(path).join('/')

      result      = File.read target_path if File.exist?(target_path) && ! File.directory?(target_path)
      result
    end

    def resolve_options(
      **_
    )
      nil
    end


    private

    def cleaned_path path
      if path.length == 0
        path
      elsif path.first == ''
        path[1..-1]
      else
        path
      end
    end
  end
end
