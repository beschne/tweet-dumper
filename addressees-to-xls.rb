#!/usr/bin/env ruby
#
# addressee-to-xls.rb - export list of tweet addressees to Excel File
#
# Copyright (C) 2018 Benno Schneider, projects@bschneider.org

require 'spreadsheet'
require 'twitter'
require 'yaml'

YAML_FILE  = 'tweets.yml'
EXCEL_FILE = 'addressees.xls'

tweets = YAML::load_file(YAML_FILE)

# find all addressees
addressees = Array.new
tweets.each do |tweet|
  if !tweet.attrs[:in_reply_to_status_id].nil?
    name = tweet.attrs[:in_reply_to_screen_name]
    id = tweet.attrs[:in_reply_to_user_id_str]
    found = addressees.find { |a| a[:name] == name}
    if !found
      puts name
      addressee = Hash.new
      addressee[:name]  = name
      addressee[:id]    = id
      addressee[:count] = 1
      addressees.push addressee
    else
      found[:count] = found[:count] + 1
    end
  end
end

# sort the list by names
addressees.sort_by! { |a| a[:name].downcase }

# write to spreadsheet
Spreadsheet.client_encoding = 'UTF-8'
book = Spreadsheet::Workbook.new
sheet = book.create_worksheet :name => 'replies'
row = sheet.row(0)
row[0] = 'screen name'
row[1] = 'user id'
row[2] = 'count'
addressees.each.with_index(1) do |a, i|
  row = sheet.row(i)
  row[0] = a[:name]
  row[1] = a[:id]
  row[2] = a[:count]
end
book.write EXCEL_FILE
