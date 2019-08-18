class Dog
    attr_accessor :name, :breed, :id

    def initialize (id: nil , name:, breed: )
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            breed TEXT);"
        DB[:conn].execute(sql)
    end 

    def self.drop_table
        sql = "DROP TABLE dogs;"
        DB[:conn].execute(sql)
    end

    def save
        sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end
    
    def self.create(name: , breed:)
        dog = Dog.new(id: nil, name: name, breed: breed)
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

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ?"
        response = DB[:conn].execute(sql, name)
        found = response.find{|item| item.include? breed}

        if response
            if found
                dog = Dog.new_from_db(found)
            else
                dog = self.create(name: name, breed: breed)
            end 

        else
            dog = self.create(name: name, breed:breed)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        response = DB[:conn].execute(sql, name).first
        dog = Dog.new_from_db(response)
    end

    def update
        sql = "UPDATE dogs SET  name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end

