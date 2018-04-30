# root
FREST.defn(
  mode:        'strong',
  arg_types:   {
    source: 'timeline'
  },
  tags:        ['presenter'],
  result_type: 'html',
  match:       ->(
                 matches: {},
                   mode: nil,
                   tag: nil,
                   result_type: nil
               ) {
    mode == 'strong' &&
    [*tag].include?('presenter') &&
    result_type == 'html'
  }
) do |
context: NullContext.new,
  path: '',
  params: {},
  **c|
  result = context.resolve(
    path: path,
    args: params
  )
  'Timeline goes here'
end
