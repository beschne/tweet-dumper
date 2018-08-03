#!/usr/bin/env ruby
#
# download-media.rb - downloads all media from YAML file
#
# Copyright (C) 2018 Benno Schneider, projects@bschneider.org

require 'twitter'
require 'yaml'
require 'uri'
require 'open-uri'

YAML_FILE = 'tweets.yml'
MEDIA_DIR = './media'

def download_media url, filename
  path = MEDIA_DIR + '/' + filename
  if File.exists? path
    puts "#{path} already exists (#{url})"
  else
    puts "Downloading #{url} to #{path}"
    Dir.mkdir MEDIA_DIR unless File.directory? MEDIA_DIR
    File.open(path, 'w') do |f|
      IO.copy_stream(open(url), f)
    end
  end
end

def create_filename(prefix, url)
  return prefix + ' ' + File.basename(URI.parse(url).path)
end

def download_photo(prefix, media)
  url = media.media_url
  filename = create_filename prefix, url
  download_media url, filename
end

def download_videos(prefix, media)
  download_photo prefix, media # get thumbs picture of download_video
  media.video_info.variants.each do |v|
    url = v.url
    filename = create_filename prefix, url
    download_media url, filename
  end
end

tweets = YAML::load_file(YAML_FILE)

tweets.each do |tweet|
  tweet.media.each do |media|
    prefix = tweet.created_at.strftime('%Y-%m-%d %Hh%M')
    case media.type
    when 'photo'
      download_photo prefix, media
    when 'video'
      download_photo prefix, media
      download_videos prefix, media
    when 'animated_gif'
      download_photo prefix, media
      download_videos prefix, media
    else
      puts "unknown type #{media.type}"
    end
  end
end
