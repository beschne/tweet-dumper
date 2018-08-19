#!/usr/bin/env ruby
#
# monitor.rb - Monitor Twitter user statistic changes to CSV file.
#              Works for protected accounts as well.
#
# Copyright (C) 2018 Benno Schneider, projects@bschneider.org

require 'yaml'
require 'twitter'

MONITOR_FILE  = 'monitor.csv'

config = YAML::load_file('./config.yml')

client = Twitter::REST::Client.new do |conf|
  conf.consumer_key        = config['consumer_key']
  conf.consumer_secret     = config['consumer_secret']
  conf.access_token        = config['access_token']
  conf.access_token_secret = config['access_token_secret']
end

options = {}

loop do
  user = client.user(config['user'], options)
  time_str = Time.now.strftime("%d-%m-%Y %H:%M")
  print "#{time_str}: #{user.screen_name}, count: #{user.statuses_count}, "
  print "favs: #{user.favorites_count}, "
  print "friend: #{user.friends_count}, "
  print "followers: #{user.followers_count}"
  puts
  File.open(MONITOR_FILE, 'a') do |f|
    f.print "#{time_str}, "
    f.print "#{user.id.to_s}, #{user.screen_name}, "
    f.print "#{user.statuses_count}, "
    f.print "#{user.favorites_count}, "
    f.print "#{user.listed_count}, "
    f.print "#{user.friends_count}, "
    f.print "#{user.followers_count}"
    f.puts
  end
  delay = ((50 + rand(20)) * 60) + rand(120)
  puts "Sleeping #{delay / 60} minutes.."
  sleep delay
end
