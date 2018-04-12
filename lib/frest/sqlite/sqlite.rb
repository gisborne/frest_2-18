require 'sqlite3'
require 'securerandom'
require 'chain_context'

module FREST
  class SQLite < BaseContext
    def resolve(
        path:,
        context: NullContext.new
    )

      result = @@db.execute <<-SQL
      SELECT
        content
      FROM
        contents
      WHERE
        id =
      SQL
    end

    def resolve_strong(
        path:,
        context: NullContext.new
    )

      @@db.execute <<-SQL
      SELECT content
      SQL
    end

    def meta(
        path:,
        context: NullContext.new
    )
    end

    private

    def self.setup
      @@db = SQLite3::Database.new "db/frest.sqlite"

      @@db.define_function('uuid') {SecureRandom.uuid}
      @@db.execute_batch <<-SQL
        CREATE TABLE IF NOT EXISTS
          types(
            id PRIMARY KEY DEFAULT (UUID()),
            name,
            abstract NOT NULL DEFAULT false
          );
        
        CREATE TABLE IF NOT EXISTS
          contents(
            id PRIMARY KEY DEFAULT (UUID()),
            content,
            type NOT NULL REFERENCES types(id),
            created_at DEFAULT (NOW()),
            result_type
          );
        
        CREATE TABLE IF NOT EXISTS
          types_inheritance (
          parent_id NOT NULL REFERENCES content (id),
          child_id  NOT NULL REFERENCES content (id),
        
          PRIMARY KEY (
            parent_id,
            child_id
          )
            ON CONFLICT
            IGNORE,
        
          CHECK (
            parent_id <> child_id
          )
        );
      SQL
    end
  end
end

FREST::SQLite.setup
