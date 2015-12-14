# JoyceShop Scraper
[![Build Status](https://travis-ci.org/hola2soa/JoyceShop.svg)](https://travis-ci.org/hola2soa/JoyceShop)
JoyceShop is an ecommerce website selling women clothing but does not have an api.
This repo allows scrapping of the site to extract the title and price
of items sold.  
The api allows page as parameter.

## Usage
Install JoyceShop Scraper using this command:
```sh
$ gem install joyceshop
```

Use it in your library:
```ruby
require 'joyceshop'
scraper = JoyceShop::Scraper.new
results = JoyceShop.latest(1)
```
