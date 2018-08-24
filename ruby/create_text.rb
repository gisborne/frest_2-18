# root
FREST.defn(
  mode:       'strong',
  arg_types:  {
    context:  'context',
    source:   'text'
  },
  lexical: {
    arguments: {
      source: {
        field_title: 'Text'
      }
    },
    link_to: 'Create text'
  },
  tags:        ['presenter'],
  result_type: 'text',
  match:       ->(
                 matches:     {},
                 mode:        nil,
                 tag:         nil,
                 result_type: nil
               ) {
                    mode == 'strong' &&
                    result_type == 'text'
                  }
) do |
  context:,
  path:     [],
  params:   {},
  **c|

  params['source']
end
