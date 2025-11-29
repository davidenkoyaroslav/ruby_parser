# lib/items/item.rb
require_relative '../logger_manager'

module MyApplicationDavydenko
  class Item
    include Comparable

    attr_accessor :name, :price, :description, :category, :image_path

    def initialize(params = {})
      @name        = params[:name]        || "No name"
      @price       = params[:price]       || 0
      @description = params[:description] || "No description"
      @category    = params[:category]    || "General"
      @image_path  = params[:image_path]  || "no_image.jpg"

      MyApplicationDavydenko::LoggerManager.log_processed_file("Initialized Item: #{@name}")

      yield(self) if block_given?
    end

    def update
      yield(self) if block_given?
    end

    def to_s
      instance_variables.map { |var| "#{var}=#{instance_variable_get(var)}" }.join(", ")
    end

    def to_h
      instance_variables.map { |var| [var.to_s.delete("@").to_sym, instance_variable_get(var)] }.to_h
    end

    def inspect
      "#<Item #{to_h}>"
    end

    def <=>(other)
      price <=> other.price
    end

    alias_method :info, :to_s

    # Простий "фейковий" генератор без Faker
    def self.generate_fake
      new(
        name: "Test_#{rand(1000)}",
        price: rand(10..100),
        description: "Generated sample item",
        category: "General",
        image_path: "none"
      )
    end
  end
end
