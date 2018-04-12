# root
FREST.defn(
  'mode'        => 'strong',
  'arg_types'   => {
    'source' => 'timeline'
  },
  'tags'        => ['presenter'],
  'result_type' => 'html',
  'matches'     => ->(
    mode: nil,
      tag: nil,
      result_type: nil,
      source: {}
  ) {
    mode == 'strong' &&
      tag == 'presenter' &&
      result_type == 'html' &&
      source.has_key?('path')
  }
) do |
**c|
  'Timeline goes here'
end
