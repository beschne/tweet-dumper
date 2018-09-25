#!/usr/bin/env ruby
#
# common-followers.sh - find common followers for givven list of accounts
#
# Copyright (C) 2018 Benno Schneider, projects@bschneider.org

require 'twitter'
require 'yaml'

config = YAML::load_file('./config.yml')

client = Twitter::REST::Client.new do |conf|
  conf.consumer_key        = config['consumer_key']
  conf.consumer_secret     = config['consumer_secret']
  conf.access_token        = config['access_token']
  conf.access_token_secret = config['access_token_secret']
end

# add subjects to check in subjects array within config.yml
subjects = config['subjects']

map = []
max_count = 1

puts "Gathering followers for"
subjects.each do |id|
  puts "  #{id}, #{client.user(id).screen_name}"
  begin
    followers = client.follower_ids(id).to_a
  rescue Twitter::Error::TooManyRequests => error
    # some of the accounts to check have a lot of followers
    # thus raising 'Rate limit exceeded', Twitter::Error::TooManyRequests
    sleep_time = error.rate_limit.reset_in + 1
    puts "  Sleeping for #{sleep_time} seconds"
    sleep sleep_time
    retry
  rescue Twitter::Error::Unauthorized
    puts "  - Account is protected"
    followers = []
  end
  followers.each do |f|
    m = map.find {|x| x[:id] == f}
    if (m.nil?)
      hash = { :id => f, :count => 1}
      map.push hash
    else
      m[:count] = m[:count] + 1
      max_count = m[:count] if max_count < m[:count]
    end
  end
end

puts "Sorting followers by match count"
map.sort_by! { |m| m[:count] }

treshold = max_count / 2

puts "Common followers by count matching (greater or equal than #{treshold}):"
map.each do |m|
  if m[:count] >= treshold then
    screen_name = client.user(m[:id]).screen_name
    since = client.user(m[:id]).created_at.strftime("%d%b%y")
    puts "#{m[:count]}x #{m[:id]}, #{screen_name}, joined #{since}"
  end
end
