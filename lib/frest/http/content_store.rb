require 'securerandom'
require_relative '../shared/local_store.rb'

class ContentStore < LocalStore
  def get(
      path: [],
      content:
  )
    return get_root unless path != []
    db.get_first_value <<-SQL
        SELECT
          content
        FROM
          content
        WHERE
          id = ?
      SQL,
      path 
  end

  def put(
      path: SecureRandom.uuid,
      content: ''
  )
    db.execute <<-SQL
      INSERT INTO
        content(
          id, 
          content
        )
      VALUES(
        ?,
        ?
      )
    SQL

    return path
  end

  def get_root

  end
end
