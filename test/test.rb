###
#   MicroScraper Server
#
#   Copyright 2010, AUTHORS.txt
#   Licensed under the MIT license.
#
#   test/test.rb : Tests.
###

$:<< Dir.pwd + '/..'

require 'lib/server'
require 'test/unit'
require 'rack/test'
require 'json'
require 'cgi'

#ENV['RACK_ENV'] = 'test'

set :environment, :test
set :sessions, true

module MicroScraper
  NUM_TESTS = 1
  ID_LENGTH = 10
  MAX_LIST = 100
  
  def self.random_string(length = ID_LENGTH)
    rand(32**length).to_s(32)
  end

  class Test < Test::Unit::TestCase
    include Rack::Test::Methods
    
    # def app
    #   Sinatra::Application
    # end
  end
end

