require 'dm-core'
require 'dm-types'
require 'dm-validations'
require 'uri'

module MicroScraper
  module Resources
    module Locatable
      # Mixin attributes
      base.class_eval do
        include Resource
        
        property :id,   Serial, :accessor => :private
        property :title, String, :required => true, :unique_index => :uindex
        property :deleted_at, ParanoidDateTime, :writer => :private, :unique_index => :uindex

        before :save, :filter_title
      end
      
      private
      def self.name_without_module
        name.split('::').last
      end
      
      public
      # Get the location of the resource's model.
      def self.location(root_dir)
        root_dir + URI.encode(name_without_module) + '/'
      end
      
      # Extra instance methods
      def full_name
        title
      end
      
      def location
        model.location + URI.encode(full_name)
      end
      
      def validate_title
        if title.to_s.index('/')
          [ false, 'Title cannot contain a slash.' ]
        else
          true
        end
      end

      # Replaces whitespace in title with dashes, eliminate other nonalphanumerics
      def filter_title
        self.title= title.gsub(/\s+/, '-')
        self.title= title.gsub(/[^a-zA-Z0-9\-]/, '')
      end
    end
  end
end
