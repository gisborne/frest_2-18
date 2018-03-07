require 'json'

class FrestProxy
  attr_reader :io

  def initialize io:
    @io = io
  end

  def request(
      **args
  )
    @io.send args.to_json
  end
end
