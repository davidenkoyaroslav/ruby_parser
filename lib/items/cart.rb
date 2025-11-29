require 'json'
require 'csv'
require 'yaml'
require_relative 'item_container'
require_relative 'item'

module MyApplicationDavydenko
  class Cart
    include ItemContainer
    include Enumerable

    attr_reader :items

    def initialize
      @items = []
      self.class.increase_count
    end

    def each(&block)
      @items.each(&block)
    end

    def generate_test_items(count = 3)
      count.times do
        add_item(MyApplicationDavydenko::Item.new(
          name: "Test",
          price: 10,
          description: "Sample",
          category: "General",
          image_path: "none"
        ))
      end
    end


    def save_to_file(path)
      File.write(path, @items.map(&:to_s).join("\n"))
    end

    def save_to_json(path)
      data = @items.map(&:to_h)
      File.write(path, JSON.pretty_generate(data))
    end

    def save_to_csv(path)
      return if @items.empty?

      CSV.open(path, 'w') do |csv|
        csv << @items.first.to_h.keys
        @items.each { |i| csv << i.to_h.values }
      end
    end

    def save_to_yml(dir)
      Dir.mkdir(dir) unless Dir.exist?(dir)
      @items.each_with_index do |item, idx|
        File.write("#{dir}/item_#{idx + 1}.yml", item.to_h.to_yaml)
      end
    end



    def save_to_sqlite(db)
      return if @items.empty?

      db.execute <<~SQL
        CREATE TABLE IF NOT EXISTS items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          price REAL,
          description TEXT,
          category TEXT,
          image_path TEXT
        );
      SQL

      @items.each do |item|
        db.execute(
          "INSERT INTO items (name, price, description, category, image_path)
           VALUES (?, ?, ?, ?, ?)",
          [
            item.name,
            item.price,
            item.description,
            item.category,
            item.image_path
          ]
        )
      end
    end

  end
end

