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

      target_path = ASSET_ROOT + path.gsub(/^\//, '')

      result      = File.read target_path if File.exist?(target_path) && ! File.directory?(target_path)
      result
    end
  end
end
