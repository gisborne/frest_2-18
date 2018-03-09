module ContextShared
  def fix_path path
    return path if path.is_a? Array
    result = path.split('/')
    result.shift if result.length > 1
    result
  end
end
