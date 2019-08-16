class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", @id)
        new_name = row[1]
        new_breed = row[2]
        new_dog = Dog.new(id: @id, name: new_name, breed: new_breed)

    end

    def self.create(attributes)
        new_dog = Dog.new(attributes)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        new_id = row[0]
        new_name = row[1]
        new_breed = row[2]
        new_dog = Dog.new(id: new_id, name: new_name, breed: new_breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id)[0]
        self.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        dog_data = dog[0]
        
        if !dog.empty?
            sql = <<-SQL
                UPDATE dogs SET name = ?, breed = ? WHERE id = ?
            SQL

            DB[:conn].execute(sql, dog_data[0], dog_data[1], dog_data[2])
            new_dog = self.new_from_db(dog_data)

            # get_id = DB[:conn].execute("SELECT id FROM dogs WHERE id = ?", new_dog.id)[0]
            # new_dog.id = get_id
            # new_dog

        else
            new_dog = self.create(name: name, breed: breed)
            #@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            #row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", @id)[0]

            #new_dog.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

        row = DB[:conn].execute(sql, name)[0]

        new_dog = new_from_db(row)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end