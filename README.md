# Tweet Dumper

Dumps whole Twitter timeline including media for a given user to a YAML file
for full analysis with Microsoft Excel.

## Ruby

After cloning this repository you need to install
[Ruby](https://www.ruby-lang.org/), [rbenv](http://rbenv.org/)
and [Bundler](http://bundler.io/) and than run Bundler on the Gemfile:

    $ rbenv local 2.5.1
    $ bundle install
    $ rbenv rehash

This installs all necessary Ruby libraries.

## Scripts

* *dump-tweets.rb* - dumps all tweets from a user to a YAML file
* *export-xls.rb* - exports tweets from YAML file to an Excel
* *download-media.rb* - downloads all media from YAML file
