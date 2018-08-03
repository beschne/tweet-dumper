#!/usr/bin/env ruby
#
# dump-tweets.rb - dumps whole Twitter timeline for a given user
#
# Copyright (C) 2018 Benno Schneider, projects@bschneider.org
#
# https://stackoverflow.com/questions/30417203/using-ruby-and-twitter-can-i-gather-all-of-a-users-timeline

require 'twitter'
require 'yaml'

YAML_FILE  = 'tweets.yml'

config = YAML::load_file('./config.yml')

client = Twitter::REST::Client.new do |conf|
  conf.consumer_key        = config['consumer_key']
  conf.consumer_secret     = config['consumer_secret']
  conf.access_token        = config['access_token']
  conf.access_token_secret = config['access_token_secret']
end

count = 0
max_id = nil
options = {count: 200, include_rts: true}

File.open(YAML_FILE, 'w') do |f|
  f.puts '---' # this is going to be an array
  while(count < config['max_no_tweets'])
    # each loop gets 200 tweet
    options[:max_id] = max_id unless max_id.nil?
    begin
      tweets = client.user_timeline(config['user'], options)
    rescue Twitter::Error::TooManyRequests => error
      sleep_time = error.rate_limit.reset_in + 1
      puts "sleeping for #{sleep_time} seconds ..."
      sleep sleep_time
      retry
    end
    # dump tweets to file
    f.puts YAML.dump(tweets)[4..-1]
    tweets.each do |tweet|
      if tweet.is_a?(Twitter::Tweet)
        count += 1
        count_str = "%4d" % count
        puts count_str + ' ' + tweet.created_at.to_s + ': ' + tweet.text.slice(0..60)
      end
      # set max_id to get the next 200 tweet
      max_id = tweet.id if max_id.nil?
      max_id = [max_id, tweet.id].min - 1
    end
    # flush buffers to file in case we interrupt
    f.flush
  end
end
