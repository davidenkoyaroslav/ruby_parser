require 'mechanize'
require 'uri'
require 'fileutils'
require_relative 'items/cart'
require_relative 'items/item'
require_relative 'logger_manager'

module MyApplicationDavydenko
  class SimpleWebsiteParser
    attr_reader :item_collection

    def initialize(config)
      ws = config['web_scraping'] || config[:web_scraping] || {}

      @start_page = ws['start_page'] || ws[:start_page] ||
                    'https://game-shop.com.ua/ua/category/igryi-dlya-playstation-5'

      @card_sel = ws['product_card_selector']  || ws[:product_card_selector]  || 'a[href*="/product/"]'
      @img_sel  = ws['product_image_selector'] || ws[:product_image_selector] || ''

      puts "[PARSER INIT] start_page = #{@start_page}"
      puts "[PARSER INIT] card_sel   = #{@card_sel}"
      puts "[PARSER INIT] img_sel    = #{@img_sel}"

      @agent = Mechanize.new
      @agent.user_agent_alias = 'Windows Chrome'
      @agent.read_timeout = 10

      @item_collection = MyApplicationDavydenko::Cart.new

      MyApplicationDavydenko::LoggerManager.log_processed_file(
        'Initialized SimpleWebsiteParser (Game shop, name+price+image)'
      )
    end

    def start_parse
      puts "[PARSER] start_page = #{@start_page}"
      page = fetch_page(@start_page)
      return unless page

      cards = extract_product_cards(page)
      puts "[PARSER] found cards: #{cards.size}"

      return if cards.empty?

      cards.each { |card| parse_product_card(card) }
    rescue StandardError => e
      MyApplicationDavydenko::LoggerManager.log_error(
        "start_parse failed: #{e.class}: #{e.message}"
      )
    end

    # Картки товарів
    def extract_product_cards(page)
      cards = page.search(@card_sel.to_s)
      puts "[PARSER] primary selector '#{@card_sel}' found: #{cards.size}"
      cards
    end

    # Парсинг однієї картки
    def parse_product_card(card)
      name_text = card.text.to_s.strip
      price_text = extract_price_from_onclick(card)
      img_url = extract_image_url_from_card(card)

      return if name_text.empty? || name_text.include?('Подробнее') ||
                name_text.start_with?('Відгук про товар') ||
                name_text.start_with?('GameShop ')

      price = parse_price(price_text)
      puts "[PARSER] item: name=#{name_text}, price=#{price}"

      image_path = save_image(img_url, 'games')

      item = MyApplicationDavydenko::Item.new(
        name:        name_text,
        price:       price,
        description: '',          
        category:    'games',
        image_path:  image_path   
      )

      @item_collection.add_item(item)
    rescue StandardError => e
      MyApplicationDavydenko::LoggerManager.log_error(
        "Error parsing product card: #{e.class}: #{e.message}"
      )
    end

    def extract_price_from_onclick(card)
      onclick = card['onclick']
      return nil unless onclick
      onclick[/"price":\s*(\d+)/, 1]
    end

    def parse_price(text)
      return 0 unless text
      cleaned = text.to_s.gsub(/[^\d.,]/, '').tr(',', '.')
      cleaned.empty? ? 0 : cleaned.to_f
    end

    def extract_image_url_from_card(card)
      return nil if @img_sel.to_s.strip.empty?

      node = card.at(@img_sel)
      return nil unless node

      src = node['src'] || node['data-src']
      return nil unless src

      src.start_with?('http') ? src : URI.join(@start_page, src).to_s
    end

    def fetch_page(url)
      @agent.get(url)
    rescue StandardError => e
      MyApplicationDavydenko::LoggerManager.log_error(
        "Cannot load #{url}: #{e.class}: #{e.message}"
      )
      nil
    end

    def save_image(image_url, category)
      return nil unless image_url

      media_root   = File.expand_path('../media', __dir__)
      category_dir = File.join(media_root, category)
      FileUtils.mkdir_p(category_dir)

      filename = File.basename(URI.parse(image_url).path)
      filepath = File.join(category_dir, filename)

      @agent.get(image_url).save(filepath)

      File.join('media', category, filename)
    rescue StandardError => e
      MyApplicationDavydenko::LoggerManager.log_error(
        "Image save failed: #{image_url} (#{e.class}: #{e.message})"
      )
      nil
    end
  end
end
