require 'sqlite3'
require 'securerandom'

class LocalStore
  attr_accessor :db

  def initialize(
      name:,
      location: "db/#{name}.frest.sqlite"
  )
    @db = SQLite3::Database.new(location)
    setup
  end

  private

  def setup
    db.define_function('uuid') {SecureRandom.uuid}
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS
        types(
          id PRIMARY KEY DEFAULT (UUID()),
          name,
          abstract NOT NULL DEFAULT false
        );
      
      CREATE TABLE IF NOT EXISTS
        content(
          id PRIMARY KEY DEFAULT (UUID()),
          content,
          type NOT NULL REFERENCES types(id),
          created_at DEFAULT (NOW()),
          result_type
        );
      
      CREATE TABLE IF NOT EXISTS
        types_inheritance(
          parent_id NOT NULL REFERENCES content(id),
          child_id NOT NULL REFERENCES content(id)
      
          PRIMARY KEY(
            parent_id,
            child_id
          )
      
          ON CONFLICT
            IGNORE
      
          CHECK
            parent_id <> child_id
        );
    SQL
  end
end
