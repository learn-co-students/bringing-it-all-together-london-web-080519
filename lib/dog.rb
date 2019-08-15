require 'pry'
class Dog
    def initialize(hash)
        @id = hash[:id]
        @name = hash[:name]
        @breed = hash[:breed]
    end

    attr_accessor :id, :name, :breed

    def self.create_table
        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
    end

    def self.new_from_db(row)
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        response = DB[:conn].execute(sql, id).first
        dog = Dog.new_from_db(response)
    end
    
    def self.find_or_create_by(hash)
        sql = "SELECT * FROM dogs WHERE name = ?"
        response = DB[:conn].execute(sql, hash[:name])
        found = response.find{|item| item.include? hash[:breed]}
        
        if response
            if found
                dog = Dog.new_from_db(found)
            else
                dog = self.create(hash)
            end
        else
            dog = self.create(hash)
        end
        # binding.pry
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        response = DB[:conn].execute(sql, name).flatten
        dog = Dog.new_from_db(response)
    end

    def update
        sql = "UPDATE dogs SET  name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end