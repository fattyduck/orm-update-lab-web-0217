require_relative "../config/environment.rb"
require 'pry'
class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2])
    student.id = row[0]
    student
  end

  def self.find_by_name(name)
    find_by_name_sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?
    SQL
    results = DB[:conn].execute(find_by_name_sql, name).flatten
    student = self.new(results[1],results[2])
    student.id = results[0]
    student
  end


  def save
    if @id
      update
    else
      insert
      get_id
    end
  end

  def update
    update_sql = <<-SQL
      UPDATE students
      SET name = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(update_sql, self.name, self.id)
  end

  def insert
      insert_sql = <<-SQL
        INSERT INTO students(name, grade)
        VALUES (?,?)
      SQL
      DB[:conn].execute(insert_sql, self.name, self.grade)
  end

  def get_id
      get_id_sql = "SELECT id FROM students WHERE name = ?"
      @id = DB[:conn].execute(get_id_sql, self.name)[0][0]
  end
end
