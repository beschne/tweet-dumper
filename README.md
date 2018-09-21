# Tweet Dumper

Package to dump whole Twitter timeline including media for a given user
for full analysis and to monitor this users statistics.

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
* *download-media.rb* - downloads all media from YAML file
* *export-to-xls.rb* - exports tweets from YAML file to an Excel file
* *addressees-to-xls.rb* - export all addressees' names and ids to an Excel file
* *places-to-xls.rb* - export places with time and text to an Excel file
* *monitor.rb* - monitors Twitter account statistics to a CSV file, even protected ones
* *common_followers.rb* - find common followers of a set of accounts

## Remarks

To use *monitor.rb* as a daemon start it with *nohup*:

    $ nohup ./monitor.rb > monitor.out 2> monitor.err < /dev/null &
