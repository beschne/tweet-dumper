#!/usr/bin/env ruby
#
# places-to-xls.rb - export list of tweet places with time and text to Excel
#
# Copyright (C) 2018 Benno Schneider, projects@bschneider.org

require 'spreadsheet'
require 'twitter'
require 'yaml'

YAML_FILE  = 'tweets.yml'
EXCEL_FILE = 'places.xls'

Spreadsheet.client_encoding = 'UTF-8'
book = Spreadsheet::Workbook.new
sheet = book.create_worksheet :name => 'places'
format      = Spreadsheet::Format.new vertical_align: :top
format_date = Spreadsheet::Format.new number_format: 'YYYY-MM-DD hh:mm:ss'
row = sheet.row(0)
sheet.row(0).default_format = format
row[0] = 'created'
row[1] = 'place'
row[2] = 'country'
row[3] = 'tweet'

tweets = YAML::load_file(YAML_FILE)

index = 1
tweets.each do |tweet|
  if tweet.attrs[:place] && tweet.attrs[:place][:name]
    puts "#{tweet.created_at}: #{tweet.place.full_name}"
    row = sheet.row(index)
    sheet.row(index).default_format = format
    row[0] = tweet.created_at
    row[1] = tweet.place.name
    row[2] = tweet.place.country
    row[3] = tweet.attrs[:full_text]
    row.set_format 0, format_date
    index += 1
  end
end

book.write EXCEL_FILE
