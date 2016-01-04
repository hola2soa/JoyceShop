#!/usr/bin/env ruby
require 'oga'
require 'uri'
require 'open-uri'

# scrape data
module JoyceShop
  class Scraper
    # Types
    @@VALID_TYPES = [:tops, :popular, :pants, :pants, :accessories, :latest]

    # URI
    @@BASE_URI        = 'https://www.joyce-shop.com'
    @@LATEST_URI      = "#{@@BASE_URI}/PDList.asp?brand=01&item1=&item2=&ya19=&keyword=&recommand=1412170001&ob=F"
    @@POPULAR_URI     = "#{@@BASE_URI}/PDList.asp?brand=01&item1=&item2=&ya19=&keyword=&recommand=1305080002&ob=F"
    @@TOPS_URI        = "#{@@BASE_URI}/PDList.asp?brand=01&item1=110&item2=111&ya19=&keyword=&recommand=&ob=F"
    @@PANTS_URI       = "#{@@BASE_URI}/PDList.asp?brand=01&item1=120&item2=121&ya19=&keyword=&recommand=&ob=F"
    @@ACCESSORIES_URI = "#{@@BASE_URI}/PDList.asp?brand=01&item1=140&item2=141&ya19=&keyword=&recommand=&ob=F"
    @@SEARCH_URI      = "#{@@BASE_URI}/PDList.asp?"

    # Selectors
    @@ITEM_SELECTOR      = "//div[contains(@class, 'NEW_shop_list')]/ul/li/div[contains(@class, 'NEW_shop_list_pic')]"
    @@LINK_SELECTOR      = 'a[1]/@href'
    @@IMAGE_SELECTOR     = "a/img[contains(@class, 'lazyload')]/@src"
    @@ITEM_INFO_SELECTOR = "div[contains(@class, 'NEW_shop_list_info')]"
    @@TITLE_SELECTOR     = "#{@@ITEM_INFO_SELECTOR}/div[1]"
    @@PRICE_SELECTOR     = "#{@@ITEM_INFO_SELECTOR}/span"

    # Regular
    @@TITLE_REGEX = /([．\p{Han}[a-zA-Z]]+)/

    def latest(page, options={})
      uri  = uri_with_page(@@LATEST_URI, page)
      body = fetch_data(uri)
      data = parse_html(body)
      filter(data, options)
    end

    def popular(page, options={})
      uri  = uri_with_page(@@POPULAR_URI, page)
      body = fetch_data(uri)
      data = parse_html(body)
      filter(data, options)
    end

    def tops(page, options={})
      uri  = uri_with_page(@@TOPS_URI, page)
      body = fetch_data(uri)
      data = parse_html(body)
      filter(data, options)
    end

    def pants(page, options={})
      uri  = uri_with_page(@@PANTS_URI, page)
      body = fetch_data(uri)
      data = parse_html(body)
      filter(data, options)
    end

    def accessories(page, options={})
      uri  = uri_with_page(@@ACCESSORIES_URI, page)
      body = fetch_data(uri)
      data = parse_html(body)
      filter(data, options)
    end

    def search(keyword, options={})
      uri  = uri_with_search(keyword)
      body = fetch_data(uri)
      data = parse_html(body)
      filter(data, options)
    end

    def scrape(type, page, options = {})
      abort "only supports #{@@VALID_TYPES}" unless @@VALID_TYPES.include?(type.to_sym)

      method = self.method(type)
      method.call(page, options)
    end

    private
    def uri_with_page(uri, page)
      "#{uri}&pageno=#{page}"
    end

    def uri_with_search(keyword)
      "#{@@SEARCH_URI}keyword=#{URI.escape(keyword)}"
    end

    def fetch_data(uri)
      open(uri) { |file| file.read }
    end

    # Filter
    # ------------------------------------------------------------
    def filter(data, options)
      results = data

      unless options.empty?
        results = match_price(results, options[:price_boundary]) if options[:price_boundary]
      end

      results
    end

    def match_price(data, boundary)
      lower_bound = boundary.first || 0
      upper_bound = boundary.last  || Float::INFINITY

      data.select { |item| lower_bound <= item[:price] && item[:price] <= upper_bound }
    end

    # Parser
    # ------------------------------------------------------------
    def parse_html(raw)
      Oga.parse_html(raw)
         .xpath(@@ITEM_SELECTOR)
         .map { |item| parse(item) }
    end

    def parse(item)
      {
        title:  extract_title(item),
        price:  extract_price(item),
        images: extract_images(item),
        link:   extract_link(item)
      }
    end

    def extract_title(item)
      item.xpath(@@TITLE_SELECTOR).text
          .scan(@@TITLE_REGEX)
          .flatten[0]
    end

    def extract_price(item)
      item.xpath(@@PRICE_SELECTOR).text.to_i
    end

    def extract_images(item)
      image       = item.xpath(@@IMAGE_SELECTOR).text
      image_hover = image.sub(/\.jpg/, '-h.jpg')
      ["#{@@BASE_URI}#{image}", "#{@@BASE_URI}#{image_hover}"]
    end

    def extract_link(item)
      "#{@@BASE_URI}/#{item.xpath(@@LINK_SELECTOR).text}"
    end
  end
end
