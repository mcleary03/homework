require 'sqlite3'
require 'singleton'

class PlaywrightDBConnection < SQLite3::Database
  include Singleton

  def initailize
    super('playwright.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Playwright
  attr_accessor :name, :plays

  def self.all
    data = PlaywrightDBConnection.instance.execute("SELECT * FROM playwright")
    data.map { |datum| PlaywrightDBConnection.new(datum) }
  end

  def self.find_by_name(name)
    PlaywrightDBConnection.instance.execute("SELECT * FROM playwright WHERE name = #{name}")
  end

  def new(options)
    @id = options['id']
    @name = options['name']
    @plays = options['plays']
  end

  def create
    raise "#{self} already in database" if @id
    PlaywrightDBConnection.instance.execute(<<-SQL, @name, @plays)
      INSERT INTO
        playwright (name, plays)
      VALUES
        (?, ?, ?)
    SQL
    @id = PlaywrightDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    PlaywrightDBConnection.instance.execute(<<-SQL, @name, @plays, @id)
      UPDATE
        name = ?, plays = ?
      WHERE
        id = ?
    SQL
  end

  def get_plays
    PlaywrightDBConnection.instance.execute("SELECT * FROM playwright WHERE name = #{name}")
  end
end
