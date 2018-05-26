%w{
  context
  http
  ruby
  sqlite
  static_context
}.each do |x|
  $LOAD_PATH << File.expand_path("../lib/frest/#{x}", __FILE__)
end
require 'base_context'
require 'ruby'
require 'sqlite'
require 'hash_context'
require 'http'
require 'static_context'

# c = FREST::Ruby.new + FREST::SQLite.new
c = FREST::StaticContext.new + FREST::Ruby.new + FREST::SQLite.new

FREST::HTTP.start context: c
