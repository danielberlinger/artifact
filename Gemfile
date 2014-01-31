source 'https://rubygems.org'
#ruby '1.9.3'

gem 'rails', '3.2.13'

gem "pg", :group => :production
gem 'RedCloth'
gem 'acts-as-taggable-on'
gem 'chronic_duration'
gem 'coderay'
gem 'devise'
gem 'jquery-rails'
gem 'json', '1.7.7'
gem 'mysql2', :group => :development
gem 'paper_trail', '~> 2'
gem 'rails_autolink'
#gem 'thin', :group => :production
gem 'redcarpet'
gem 'tinder'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem 'minitest', :require => false
  gem 'capybara'
  gem 'shoulda'
  gem 'shoulda-matchers', '1.4.1'
  gem 'simplecov', :require => false
  gem 'turn', :require => false
  gem 'mocha', :require => false
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'launchy'
  gem 'capybara-email'
  gem 'vcr'
  gem 'webmock', ['>= 1.8.0', '< 1.9']
end

group :test, :development, :staging do
  gem 'factory_girl_rails'
  gem 'flay', :require => false
  gem 'flog', :require => false
  gem 'rack-test', :require => 'rack/test'
  gem 'roodi', :require => false
end
