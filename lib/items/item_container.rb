# lib/items/item_container.rb
require_relative '../logger_manager'

module MyApplicationDavydenko
  module ItemContainer
    def self.included(base)
      base.extend ClassMethods
      base.include InstanceMethods
    end

    module ClassMethods
      def class_info
        "#{name} v1.0"
      end

      def created_count
        @created_count ||= 0
      end

      def increase_count
        @created_count = created_count + 1
      end
    end

    module InstanceMethods
      def add_item(item)
        @items << item
        MyApplicationDavydenko::LoggerManager.log_processed_file("Added item: #{item.name}")
      end

      def remove_item(item)
        @items.delete(item)
        MyApplicationDavydenko::LoggerManager.log_processed_file("Removed item: #{item.name}")
      end

      def delete_items
        @items.clear
        MyApplicationDavydenko::LoggerManager.log_processed_file("Deleted all items")
      end

      def method_missing(name, *args)
        return show_all_items if name == :show_all_items
        super
      end

      def show_all_items
        @items.each { |i| puts i }
      end

      def respond_to_missing?(method, include_private = false)
        method == :show_all_items || super
      end
    end
  end
end
