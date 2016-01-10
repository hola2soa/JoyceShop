# encoding: utf-8
require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require 'vcr'
require 'webmock/minitest'
require './lib/joyceshop'

def check_correct_structure(items)
  item  = items.first

  items.must_be_instance_of Array
  items.wont_be_empty

  item.must_be_instance_of Hash
  item[:title].wont_be_nil
  item[:title].must_be_instance_of String
  item[:price].wont_be_nil
  item[:price].must_be_instance_of Fixnum
  item[:images].wont_be_nil
  item[:images].must_be_instance_of Array
  item[:link].wont_be_nil
  item[:link].must_be_instance_of String
end

def manage_cassettes(cassette)
  before do
    VCR.insert_cassette cassette
  end
  after do
    VCR.eject_cassette
  end
end

VCR.configure do |config|
  config.cassette_library_dir = './spec/fixtures/vcr_cassettes'
  config.allow_http_connections_when_no_cassette = true
  config.hook_into :webmock
end
