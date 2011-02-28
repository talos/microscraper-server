#!/usr/bin/ruby

###
#   SimpleScraper Back 0.0.1
#
#   Copyright 2010, AUTHORS.txt
#   Licensed under the MIT license.
#
#   SimpleScraper.rb : Execute this file to start.
###

require 'rubygems'
require 'sinatra'
require 'lib/schema'
require 'lib/controller'
require 'lib/login'

module SimpleScraper
  module Application
    configure do
      set :raise_errors, false
      set :show_exceptions, false
      set :sessions, true
    end
    #include Controller
    #include Login
  end
end
