###
#   MicroScraper Server
#
#   Copyright 2010, AUTHORS.txt
#   Licensed under the MIT license.
#
#   schema.rb : Database definitions.
###

require 'rubygems'
require 'dm-core'
require 'dm-types'
require 'dm-migrations'
require 'dm-validations'
require 'dm-timestamps'
require 'json'
require 'net/http'
require 'uri'
require 'mustache'
require 'lib/dm-helpers'
require 'lib/mustache-helpers'

# Extend default String length from 50 to 512
DataMapper::Property::String.length(512)
# Fix bug that crops up from prior line.
DataMapper::Property::String.length(65535)

module MicroScraper
  class Database
    module Schema
      class User
        include DataMapper::Resource
        
        property :id,   DataMapper::Property::Serial, :accessor => :private
        
        property :immutable_name, DataMapper::Property::String, :required => true, :unique => true, :accessor => :private
        property :title, DataMapper::Property::String, :required => true, :unique => true
        
        has n, :scrapers,   :child_key => [ :creator_id ]
        has n, :defaults,   :child_key => [ :creator_id ]
        has n, :datas,      :child_key => [ :creator_id ]
        has n, :web_pages,  :child_key => [ :creator_id ]
        
        has n, :posts,   :child_key => [ :creator_id ]
        has n, :headers, :child_key => [ :creator_id ]
        has n, :cookies, 'Cookie',  :child_key => [ :creator_id ]
        has n, :regexps, :child_key => [ :creator_id ]
        
        # Only the user can modify his/her own resource.
        def editable_by? (user)
          user == self ? true : false
        end
        
        def can_edit? (resource)
          resource.editable_by? self
        end

        def full_name
          title
        end
        
        # Default title to immutable name.
        before :valid? do
          send(:title=, immutable_name) if title.nil?
        end
        
        #def location
        # "/#{full_name}"
        #end
        
        ## TODO: DRY this out
        def associations
          model.relationships.collect do |name, relationship|
            {
              :name => name,
              :size => send(name).length,
              :model_location => relationship.target_model.location,
              # :location => location + '/' + name + '/',
              :location => relationship.target_model.location + full_name + '/',
              :collection => send(name)
            }
          end
        end
      end
      
      # A Resource owned by a creator, with editors.  Can be checked to see if it is editable by a user.
      module Resource
        def self.included(base)
          base.class_eval do
            include DataMapper::Resource
            
            property :id,   DataMapper::Property::Serial, :accessor => :private
            
            property :created_at, DataMapper::Property::DateTime, :writer => :private
            property :updated_at, DataMapper::Property::DateTime, :writer => :private

            property :title, DataMapper::Property::String, :required => true, :unique_index => :creator_name_deleted
            
            # Make sure names don't contain a slash.
            validates_with_method :title, :validate_title

            property :description, DataMapper::Property::Text
            
            belongs_to :creator, :model => 'User', :required => true
            property :creator_id, DataMapper::Property::Integer, :required => true, :writer => :private, :unique_index => :creator_name_deleted
            
            property :deleted_at, DataMapper::Property::ParanoidDateTime, :writer => :private, :unique_index => :creator_name_deleted

            has n, :editors, :model => 'User', :through => DataMapper::Resource
            property :last_editor_id, DataMapper::Property::Integer, :accessor => :private
            
            # Destroy links before destroying resource.
            before :destroy do
              model.many_to_many_relationships.each do |name, relationship|
                send(name).intermediaries.destroy
              end
            end
            
            # Check mustacheable attributes for mustacheability
            before :valid? do
              model.mustacheable_attributes.each do |attr|
                begin
                  Mustache.templateify(send(attr)).send(:tokens)
                rescue Mustache::Parser::SyntaxError
                  throw :halt
                end
              end
            end
            
            # Keep track of our last editor.
            after :save do
              if @last_editor
                last_editor_id = @last_editor.attribute_get(:id)
              end
            end
            
            def self.related_model (relationship)
              relationships[relationship.to_sym] ? relationships[relationship.to_sym].target_model : nil
            end
            
            def self.many_to_many_relationships
              relationships.select { |name, relationship| relationship.class == DataMapper::Associations::ManyToMany::Relationship }
            end
            
            def self.traversable_relationships
              many_to_many_relationships.select do |name, relationship|
                @traverse.to_a.include?(name.to_sym)
              end
            end
            
            def self.traverse (*relationships)
              @traverse = @traverse.to_a.push(*relationships)
            end
            
            def self.exportable_relationships
              many_to_many_relationships.select do |name, relationship|
                @export.to_a.include?(name.to_sym)
              end
            end

            def self.export (*relationships)
              @export = @export.to_a.push(*relationships)
            end
            
            def self.mustacheable_attributes
              @mustacheable_attributes.to_a
            end

            def self.mustacheable (*attributes)
              @mustacheable_attributes = @mustacheable_attributes.to_a.push(*attributes)
            end
          end
          
          def validate_title
            if title.index('/')
              [ false, 'Title cannot contain a slash.' ]
            else
              true
            end
          end

          def editable_by? (user)
            creator == user or editors.get(user.attribute_get(:id)) ? true : false
          end

          def modify (new_attributes, last_updated_at, editor)
            if updated_at != last_updated_at
              raise DataMapper::UpdateConflictError.new
            end
            super new_attributes, last_updated_at, editor
            @last_editor = editor
          end
          
          # TODO: does not work with CPK
          def unlink(relationship_name, link)
            relationship = model.relationships[relationship_name.to_sym]
            raise DataMapper::UnknownRelationshipError.new unless relationship.class == DataMapper::Associations::ManyToMany::Relationship
            raise DataMapper::UnknownRelationshipError.new unless relationship.target_model == link.model
            
            send(relationship_name).intermediaries.get([*[key, link.key].flatten], [*[key, link.key].flatten]).destroy
          end

          def full_name
            creator.full_name + '/' + title
          end

          # Safely change a resource's attributes
          def modify (new_attributes, last_updated_at, editor)
            new_attributes.delete_if do |name, value|
              if not attributes.keys.include? name.downcase.to_sym # Delete attributes not specified in the model
                true
              elsif private_methods.include? name + '=' # Remove private attributes.
                true
              end
            end
            self.attributes=(new_attributes)
          end
          
          # Resource location.
          def location
            #creator.location + '/' + relationships[:creator].inverse.name.to_s + '/' + attribute_get(:title)
            model.location + full_name
          end

          def immutables
            immutables = attributes.select do |name, value|
              private_methods.include?(name.to_s + '=')
            end
            immutables.collect { |name, value| {:name => name, :value => value}}
          end
          
          def mutable_attributes
            attributes.select do |name, value|
              public_methods.include?(name.to_s + '=')
            end
          end

          def mutables
            mutable_attributes.collect { |name, value| {:name => name, :value => value}}
          end

          # Determine what values could possibly be fed in for testing.
          def variables
            variables = []
            model.traversable_relationships.each do |name, relationship|
              send(name).each do |related_resource|
                variables.push(*related_resource.variables)
              end
            end
            attributes.collect do |attribute|
              begin
                variables.push(*Mustache::MicroScraper.extract_variables(attribute))
              rescue Mustache::Parser::SyntaxError
                # Ignore malformed attributes
              end
            end
            variables
          end
          
          def associations
            model.many_to_many_relationships.collect do |name, relationship|
              {
                :name => name,
                :size => send(name).length,
                :model_location => relationship.target_model.location,
                :location => location + '/' + name + '/',
                :collection => send(name).collect do |resource|
                  # Substitute link location for real location
                  {
                    :full_name => resource.full_name,
                    :location => "#{location}/#{name}/#{resource.attribute_get(:id)}",
                  }
                end
              }
            end
          end
          
          def export (options = {})
            settings = {
              :into => {}
            }.merge(options)
            
            dest = settings[:into]
            
            attributes = Hash[mutable_attributes]
            attributes.delete(:description)
            attributes.delete(:title)
            
            model.traversable_relationships.each do |name, relationship|
              send(name).each do |resource|
                resource.export(:into => dest)
              end
            end

            associations = Hash[model.exportable_relationships.collect do |name, relationship|
                                  [name, send(name).collect { |resource| resource.full_name } ]
                                end]
            export_obj = attributes.merge(associations)
            
            # Place the resource into a hash with its model-mates
            dest[model.raw_name] = {} if dest[model.raw_name].nil?
            dest[model.raw_name][full_name] = export_obj
            dest
          end

          def to_json
            export.to_json
          end
        end
      end
      
      class Default
        include Resource
        
        has n, :datas, :through => DataMapper::Resource
        has n, :scrapers, :through => DataMapper::Resource
        
        traverse :scrapers
        export :scrapers

        property :value, String
        mustacheable :value
      end
      
      class Data
        include Resource
        
        has n, :defaults, :through => DataMapper::Resource
        has n, :scrapers, :through => DataMapper::Resource

        traverse :defaults, :scrapers
        export :defaults, :scrapers
      end
      
      class Scraper
        include Resource
        
        has n, :datas, :through => DataMapper::Resource
        
        property :regexp,          Text,  :default => ''
        property :match_number, Integer,  :required => false
        
        has n, :web_pages, :through => DataMapper::Resource
        has n, :defaults,  :through => DataMapper::Resource
        
        has n, :links_to_source_scrapers, 'ScraperLink', :child_key => [:target_id]
        has n, :links_to_target_scrapers, 'ScraperLink', :child_key => [:source_id]
        
        has n, :source_scrapers, 'Scraper', :through => :links_to_source_scrapers, :via => :source
        has n, :target_scrapers, 'Scraper', :through => :links_to_target_scrapers, :via => :target
        
        traverse :source_scrapers, :web_pages
        export :source_scrapers, :web_pages
        mustacheable :regexp
        
        # Replace blank match_number with nil.
        after :match_number= do 
          send(:match_number=, nil) if match_number == ''
        end
      end

      class ScraperLink
        include DataMapper::Resource
        
        property :source_id, Integer, :key => true, :min => 1
        property :target_id, Integer, :key => true, :min => 1

        belongs_to :source, 'Scraper', :key => true
        belongs_to :target, 'Scraper', :key => true
      end
      
      class WebPage
        include Resource
        
        has n, :scrapers, :through => DataMapper::Resource
        
        has n, :terminates, 'Regexp', :through => DataMapper::Resource
        
        property :url, String,  :default => ''
        has n, :posts,          :through => DataMapper::Resource
        has n, :headers,        :through => DataMapper::Resource
        has n, :cookies, 'Cookie', :through => DataMapper::Resource
        
        traverse :terminates, :posts, :headers, :cookies
        export :terminates, :posts, :headers, :cookies
        mustacheable :url
      end

      class Regexp
        include Resource
        
        has n, :web_pages, :through => DataMapper::Resource
        
        property :regexp, String, :default => ''

        mustacheable :regexp
      end
      
      class Post
        include Resource

        has n, :web_pages, :through => DataMapper::Resource
        
        property :name,  String
        property :value, String

        mustacheable :name, :value
      end

      class Header
        include Resource

        has n, :web_pages, :through => DataMapper::Resource

        property :name,  String
        property :value, String

        mustacheable :name, :value
      end
      
      class Cookie
        include Resource
        
        storage_names[:default] = 'micro_scraper_cookie_headers'
        
        has n, :web_pages, :through => DataMapper::Resource
        
        property :name,  String
        property :value, String

        mustacheable :name, :value
      end
    end
  end
end
