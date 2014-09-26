source "https://rubygems.org"

gem "json", :platforms => [ :ruby_18, :jruby ]
gem "rake"
gem "bson", :git => "https://github.com/mongodb/bson-ruby.git"

group :development, :test do
  gem "rspec"
  gem "rake-compiler"
  gem "cucumber"

  if ENV["CI"]
    gem "coveralls", :require => false
  else
    gem "pry"
    gem "guard-rspec"
    gem "rb-inotify", :require => false # Linux
    gem "rb-fsevent", :require => false # OS X
    gem "rb-fchange", :require => false # Windows
    gem "terminal-notifier-guard"
    gem "ruby-prof", :platforms => :mri
    gem "github-markup" # pip install docutils
  end
end
