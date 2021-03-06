###
#   MicroScraper Server
#
#   Copyright 2010, AUTHORS.txt
#   Licensed under the MIT license.
#
###

gem 'dm-core', '~>1.1.0'

require 'dm-core'
Dir[File.dirname(__FILE__) + '/resources/*.rb'].each { |file| require file}

# Extend default String length from 50 to 512
DataMapper::Property::String.length(512)
# Fix bug that crops up from prior line.
DataMapper::Property::String.length(65535)

module MicroScraper
  #DataMapper::Model.raise_on_save_failure = true
  class Resources
    def initialize(options = {})
      @settings = {
        :file => '/db/microscraper.db',
        :directory => '/'
      }.merge(options)
      
      #DataMapper::Logger.new($stdout, :debug)
      DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://' + Dir.pwd + @settings[:file])
      DataMapper.finalize
      
      begin
        DataMapper.auto_upgrade!
      rescue Exception => e
        DataMapper.auto_migrate!
      end
    end
    
    def user_model
      get_model('User')
    end

    def get_model (name)
      DataMapper::Model.descendants.find do |model|
        if model.respond_to? :raw_name
          model.raw_name.to_sym == name.to_sym
        end
      end
    end
    
    class ResourceError < RuntimeError
      def initialize(*resources)
        @errors = {}
        resources.each do |resource|
          @errors[resource.class.to_s] = resource.errors.to_a
        end
        super @errors.inspect
      end
    end
  end
end
