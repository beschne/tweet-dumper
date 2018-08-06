#!/usr/bin/env ruby
#
# export-xls.rb - export tweets to Excel File
#
# Copyright (C) 2018 Benno Schneider, projects@bschneider.org

require 'spreadsheet'
require 'twitter'
require 'yaml'
require 'sanitize'

YAML_FILE  = 'tweets.yml'
EXCEL_FILE = 'tweets.xls'

tweets = YAML::load_file(YAML_FILE)

Spreadsheet.client_encoding = 'UTF-8'
book = Spreadsheet::Workbook.new
sheet = book.create_worksheet :name => 'tweets'

format        = Spreadsheet::Format.new vertical_align: :top
format_date   = Spreadsheet::Format.new number_format: 'YYYY-MM-DD hh:mm:ss'
format_center = Spreadsheet::Format.new horizontal_align: :center

row = sheet.row(0)
sheet.row(0).default_format = format
row[0] = 'id'
row[1] = 'created'
row[2] = 'tweet'
row[3] = 'rt'
row[4] = 'fav'
row[5] = 'tweet'
row[6] = 'user'
row[7] = 'screen name'
row[8] = 'lang'
row[9] = 'client'
row.set_format 1, format_date
row.set_format 3, format_center
row.set_format 4, format_center
row.set_format 5, format_center

tweets.each.with_index(1) do |tweet, i|
  puts "#{i} #{tweet.attrs[:id_str]}"
  row = sheet.row(i)
  sheet.row(i).default_format = format
  # Excel functions are not yet supported by Spreadsheet gem
  # row[0] = "=HYPERLINK(\"#{tweet.uri}\"; \"#{tweet.id.to_s}\")"
  row[0] = tweet.attrs[:id_str]
  row[1] = tweet.created_at
  # current v6.2.0 Twitter gem does not support full_text correctly
  # https://github.com/sferik/twitter/issues/880
  row[2] = tweet.attrs[:full_text]
  row[3] = tweet.retweet_count
  row[4] = tweet.favorite_count
  row[5] = !tweet.retweeted_status.nil? ? 'retweet'
           : (tweet.in_reply_to_status_id.nil? ? 'tweet' : 'reply')
  row[6] = tweet.attrs[:user][:name]
  row[7] = tweet.attrs[:user][:screen_name]
  row[8] = tweet.lang
  row[9] = Sanitize.clean(tweet.source)
  row.set_format 1, format_date
  row.set_format 3, format_center
  row.set_format 4, format_center
  row.set_format 5, format_center
end

book.write EXCEL_FILE
