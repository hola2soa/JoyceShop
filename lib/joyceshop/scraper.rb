#!/usr/bin/env ruby
require 'oga'
require 'open-uri'

# scrape data
module JoyceShop
  class Scraper
    # URI
    @@BASE_URI    = 'https://www.joyce-shop.com'
    @@LATEST_URI  = "#{@@BASE_URI}/PDList.asp?brand=01&item1=&item2=&ya19=&keyword=&recommand=1412170001&ob=F"
    @@POPULAR_URI = "#{@@BASE_URI}/PDList.asp?brand=01&item1=&item2=&ya19=&keyword=&recommand=1305080002&ob=F"
    @@TOPS_URI    = "#{@@BASE_URI}/PDList.asp?brand=01&item1=110&item2=111&ya19=&keyword=&recommand=&ob=F"
    @@PANTS_URI   = "#{@@BASE_URI}/PDList.asp?brand=01&item1=120&item2=121&ya19=&keyword=&recommand=&ob=F"

    # Selectors
    @@ITEM_SELECTOR      = "//div[contains(@class, 'NEW_shop_list')]/ul/li/div[contains(@class, 'NEW_shop_list_pic')]"
    @@LINK_SELECTOR      = 'a'
    @@IMAGE_SELECTOR     = "a/img[contains(@class, 'lazyload')]"
    @@ITEM_INFO_SELECTOR = "div[contains(@class, 'NEW_shop_list_info')]"
    @@TITLE_SELECTOR     = "#{@@ITEM_INFO_SELECTOR}/div[1]"
    @@PRICE_SELECTOR     = "#{@@ITEM_INFO_SELECTOR}/span"

    # Regular
    @@TITLE_REGEX = /([．\p{Han}[a-zA-Z]]+)/

    def latest(page)
      uri  = uri_with_page(@@LATEST_URI, page)
      body = fetch_data(uri)
      filter(body)
    end

    def popular(page)
      uri  = uri_with_page(@@POPULAR_URI, page)
      body = fetch_data(uri)
      filter(body)
    end

    def tops(page)
      uri  = uri_with_page(@@TOPS_URI, page)
      body = fetch_data(uri)
      filter(body)
    end

    def pants(page)
      uri  = uri_with_page(@@PANTS_URI, page)
      body = fetch_data(uri)
      filter(body)
    end

    private
    def uri_with_page(uri, page)
      "#{uri}&pageno=#{page}"
    end

    def fetch_data(uri)
      open(uri) {|file| file.read}
    end

    def filter(raw)
      Oga.parse_html(raw)
         .xpath(@@ITEM_SELECTOR)
         .map { |item| parse(item) }
    end

    def parse(item)
      {
        title: extract_title(item),
        price: extract_price(item),
        images: extract_images(item),
        link: extract_link(item)
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
      image       = item.xpath(@@IMAGE_SELECTOR).attribute(:src).first.value
      image_hover = image.sub(/\.jpg/, '-h.jpg')
      ["#{@@BASE_URI}#{image}", "#{@@BASE_URI}#{image_hover}"]
    end

    def extract_link(item)
      "#{@@BASE_URI}/#{item.xpath(@@LINK_SELECTOR).attribute(:href).first.value}"
    end
  end
end
