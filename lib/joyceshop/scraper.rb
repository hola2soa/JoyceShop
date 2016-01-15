#!/usr/bin/env ruby
require 'oga'
require 'uri'
require 'open-uri'

# scrape data
module JoyceShop
  # extract_data class uses xpath selectors to get attribs
  class Scraper
    BASE_URL        = 'https://www.joyce-shop.com'
    BASE_SCRAPE_URL = "#{BASE_URL}/PDList.asp?"

    LATEST_URI      = "#{BASE_SCRAPE_URL}brand=01&item1=&item2=&ya19=&recommand=1412170001&ob=F"
    POPULAR_URI     = "#{BASE_SCRAPE_URL}brand=01&item1=&item2=&ya19=&recommand=1305080002&ob=F"
    TOPS_URI        = "#{BASE_SCRAPE_URL}brand=01&item1=110&item2=111&ya19=&recommand=&ob=F"
    PANTS_URI       = "#{BASE_SCRAPE_URL}brand=01&item1=120&item2=121&ya19=&recommand=&ob=F"
    ACCESSORIES_URI = "#{BASE_SCRAPE_URL}brand=01&item1=140&item2=141&ya19=&recommand=&ob=F"

    # xml selectors that will be used to scrape data
    ITEM_SELECTOR   = "//div[contains(@class, 'NEW_shop_list')]/ul/li/div[contains(@class, 'NEW_shop_list_pic')]"
    ITEM_INFO_SELECTOR = "div[contains(@class, 'NEW_shop_list_info')]"
    TITLE_SELECTOR  = "#{ITEM_INFO_SELECTOR}/div[1]"
    IMAGE_SELECTOR  = "a/img[contains(@class, 'lazyload')]/@src"
    PRICE_SELECTOR  = "#{ITEM_INFO_SELECTOR}/span"
    LINK_SELECTOR   = "a[1]/@href"

    # Regular
    TITLE_REGEX = /([．\p{Han}[a-zA-Z]]+)/

    def latest(page, options = {})
      uri  = uri_with_options(build_uri(LATEST_URI, options), page)
      process_request(uri, options)
    end

    def popular(page, options = {})
      uri  = uri_with_options(build_uri(POPULAR_URI, options), page)
      process_request(uri, options)
    end

    def tops(page, options = {})
      uri  = uri_with_options(build_uri(TOPS_URI, options), page)
      process_request(uri, options)
    end

    def pants(page, options = {})
      uri  = uri_with_options(build_uri(PANTS_URI, options), page)
      process_request(uri, options)
    end

    def accessories(page, options = {})
      uri  = uri_with_options(build_uri(ACCESSORIES_URI, options), page)
      process_request(uri, options)
    end

    def search(page, options = {})
      uri  = uri_with_options(build_uri(BASE_SCRAPE_URL, options), page)
      process_request(uri, options)
    end

    def scrape(type, options = {})
      records = []
      valid_args = [:tops, :popular, :pants, :pants,
        :accessories, :latest, :search]
      abort 'invalid parameter - scrape type' unless valid_args.include?(type.to_sym)
      scrape_what(type, options)
    end

    private

    def process_request(uri, options)
      body = open_uri(uri)
      data = extract_data(body)
      filter(data, options)
    end

    # filter by price if the options are not empty
    def filter(data, options)
      results = data
      unless options.empty?
        results = match_price(results, options[:price_boundary]) if options[:price_boundary]
      end
      results
    end

    # do the actual extraction of prices from the result set
    def match_price(data, boundary)
      lower_bound = boundary.first || 0
      upper_bound = boundary.last  || Float::INFINITY

      data.select { |item| lower_bound <= item[:price] && item[:price] <= upper_bound }
    end

    def build_uri(uri, options = {})
      opts = { uri: uri }
      unless options.empty?
        opts[:keyword] = options[:keyword] if options[:keyword]
      end
      opts
    end

    def uri_with_options(options = {}, page)
      uri = ''
      unless options.empty?
        keyword = options[:keyword] || nil
        uri << "#{options[:uri]}&pageno=#{page}" if options[:uri]
        uri << "br=X&keyword=#{URI.escape(keyword)}" if options[:keyword]
      end
      uri
    end

    # try open the URL, fail on error
    def open_uri(uri)
      open(uri) {|file| file.read}
    rescue StandardError
      'error opening site url'
    end

    # iterate over every element of item using xpath
    def extract_data(raw)
      Oga.parse_html(raw)
         .xpath(ITEM_SELECTOR)
         .map { |item| parse(item) }
    end

    # call methods to extract the data using xpath
    def parse(item)
      {
        title:  extract_title(item),
        price:  extract_price(item),
        images: extract_images(item),
        link:   extract_link(item)
      }
    end

    # Iconv is neccessary here otherwise text is unreadable
    def extract_title(item)
      item.xpath(TITLE_SELECTOR).text
          .scan(TITLE_REGEX)
          .flatten[0]
    end

    # get rid of the NT and convert to integer
    def extract_price(item)
      item.xpath(PRICE_SELECTOR).text.sub(/NT. /, '').to_i
    end

    # extract two images and return array or urls
    def extract_images(item)
      image       = item.xpath(IMAGE_SELECTOR).text
      image_hover = image.sub(/\.jpg/, '-h.jpg')
      image_hover = image.sub(/\.png/, '-h.png') unless image_hover != image
      ["#{BASE_URL}#{image}", "#{BASE_URL}#{image_hover}"]
    end

    # get the link to the item
    def extract_link(item)
      "#{BASE_URL}/#{item.xpath(LINK_SELECTOR).text}"
    end

    def scrape_what(type, options)
      records = []
      pl = options[:page_limit].to_i
      page_limit = pl != 0 ? pl : 5

      1.upto(page_limit) do |page|
        method = self.method(type)
        records.push(method.call(page, options))
      end
      records.reject { |c| c.empty? }.flatten(1).uniq
    end
  end
end
