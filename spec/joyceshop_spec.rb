require_relative 'spec_helper'
# encoding: utf-8

VCR.use_cassette 'JoyceShop' do
  describe 'check if joyceshop tests pass' do
    before do
      @scraper = JoyceShop::Scraper.new
    end

    describe 'fetch popular' do
      manage_cassettes 'popular items'
      it 'should check correct structure' do
        options = { keyword: 'looney' }
        items = @scraper.popular(1, options)
        check_correct_structure items
      end
    end

    describe 'fetch pants' do
      manage_cassettes 'pants items'
      it 'should check correct structure' do
        items = @scraper.pants(1)
        check_correct_structure items
      end
    end

    describe 'fetch tops' do
      manage_cassettes 'tops items'
      it 'should check correct structure' do
        items = @scraper.tops(1)
        check_correct_structure items
      end
    end

    describe 'fetch accessories' do
      manage_cassettes 'accessories'
      it 'should check correct structure' do
        options = { keyword: 'looney',
          page_limit: 12, price_boundary: [100, 900]
        }
        items = @scraper.popular('accessories', options)
        check_correct_structure items
      end
    end
  end
end
