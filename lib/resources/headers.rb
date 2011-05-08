require 'dm-core'

require 'lib/resources/visible'
require 'lib/resources/editable'
require 'lib/resources/mustacheable'
require 'lib/resources/web_page'

module MicroScraper
  module Resources
    module GenericHeader
      def self.included(base)
        base.class_eval do 
          include Resource
          include Visible
          include Editable
          include Mustacheable
          
          has n, :web_pages, :through => DataMapper::Resource
          
          property :name,  String
          property :value, String

          mustache :name, :value
        end
      end
    end
    
    class Post
      include GenericHeader
    end

    class Header
      include GenericHeader
    end

    class Cookie
      include GenericHeader
    end
  end
end
