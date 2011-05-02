###
#   MicroScraper Server
#
#   Copyright 2010, AUTHORS.txt
#   Licensed under the MIT license.
#
#   schema.rb : Database definitions.
###

gem 'json', '~>1.4.6'

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
        
        # Replaces whitespace in title with dashes, eliminate other nonalphanumerics
        before :save, :filter_title
        def filter_title
          self.title= title.gsub(/\s+/, '-')
          self.title= title.gsub(/[^a-zA-Z0-9\-]/, '')
        end

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
          model.relationships.collect do |r|
            {
              :name => r.name,
              :size => send(r.name).length,
              :model_location => r.target_model.location,
              :location => r.target_model.location + URI.encode(full_name) + '/',
              :collection => send(r.name)
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
            
            property :description, DataMapper::Property::Text
            
            belongs_to :creator, :model => 'User', :required => true
            property :creator_id, DataMapper::Property::Integer, :required => true, :writer => :private, :unique_index => :creator_name_deleted
            
            property :deleted_at, DataMapper::Property::ParanoidDateTime, :writer => :private, :unique_index => :creator_name_deleted

            has n, :editors, :model => 'User', :through => DataMapper::Resource
            property :last_editor_id, DataMapper::Property::Integer, :accessor => :private

            validates_with_method :check_mustacheability
            
            # Destroy links before destroying resource.
            before :destroy do
              model.many_to_many_relationships.each do |r|
                send(r.name).intermediaries.destroy
              end
            end
            
            # Keep track of our last editor.
            after :save do
              if @last_editor
                last_editor_id = @last_editor.attribute_get(:id)
              end
            end
            
            # Check mustacheable attributes for mustacheability
            def check_mustacheability
              model.mustacheable_attributes.each do |attr|
                begin
                  Mustache.templateify(send(attr)).send(:tokens)
                rescue Mustache::Parser::SyntaxError
                  return [ false, "'#{attr}' is not a valid Mustache template." ]
                end
              end
              true
            end

            # Replaces whitespace in title with dashes, eliminate other nonalphanumerics
            before :save, :filter_title
            def filter_title
              self.title= title.gsub(/\s+/, '-')
              self.title= title.gsub(/[^a-zA-Z0-9\-]/, '')
            end

            def self.related_model (relationship)
              relationships[relationship.to_sym] ? relationships[relationship.to_sym].target_model : nil
            end
            
            def self.many_to_many_relationships
              relationships.select { |r| r.class == DataMapper::Associations::ManyToMany::Relationship }
            end
            
            def self.traversable_relationships
              many_to_many_relationships.select do |r|
                @traverse.to_a.include?(r.name.to_sym)
              end
            end
            
            def self.traverse (*relationships)
              @traverse = @traverse.to_a.push(*relationships)
            end
            
            def self.exportable_relationships
              many_to_many_relationships.select do |r|
                @export.to_a.include?(r.name.to_sym)
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
            if title.to_s.index('/')
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
          
          def self.split_full_name(full_name)
            full_name.split('/')
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
            model.location + URI.encode(full_name)
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
            sorted_mutable_attributes = mutable_attributes.sort { |a, b|
              a.to_s <=> b.to_s
            }.collect { |name, value| {:name => name, :value => value}}
          end

          # Determine what values could possibly be fed in for testing.
          def variables
            variables = []

            (related_resources.push(self)).each do |resource|
              resource.model.mustacheable_attributes.collect do |attr_name|
                begin
                  variables.push(*Mustache::MicroScraper.extract_variables(resource.send(attr_name)))
                rescue Mustache::Parser::SyntaxError
                  # Ignore malformed attributes
                end
              end
            end
            variables.uniq # eliminate duplicate variables
          end
          
          def associations
            model.many_to_many_relationships.collect do |r|
              {
                :name => r.name,
                :size => send(r.name).length,
                :model_location => r.target_model.location,
                :location => location + '/' + URI.encode(r.name.to_s) + '/',
                :collection => send(r.name).collect do |resource|
                  # Substitute link location for real location
                  {
                    :full_name => resource.full_name,
                    :location => location + '/' + URI.encode(r.name.to_s) + '/' + resource.attribute_get(:id).to_s,
                    :resource => resource
                  }
                end
              }
            end
          end
          
          def related_resources(prior = [])
            resources = []
            # scan the traversable relationships
            model.traversable_relationships.each do |r|
              send(r.name).each do |related_resource|
                # make sure not to loop back
                if related_resource != self and not prior.include? related_resource
                  resources << related_resource
                  resources.push(*related_resource.related_resources(resources))
                end
              end
            end
            
            resources
          end
          
          def export
            resources = related_resources.push(self)
            dest = {}
            
            resources.each do |resource|
              attributes = Hash[resource.mutable_attributes]
              attributes.delete(:description)
              attributes.delete(:title)
              
              associations =
                Hash[resource.model.exportable_relationships.collect do |r|
                       [r.name, resource.send(r.name).collect { |related_resource| related_resource.full_name } ]
                     end]
              export_obj = attributes.merge(associations)

              # Place the resource into a hash with its model-mates
              dest[resource.model.raw_name] = {} if dest[resource.model.raw_name].nil?
              dest[resource.model.raw_name][resource.full_name] = export_obj
            end
            
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
        
        #traverse :scrapers
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
        
        has n, :regexps,   :through => DataMapper::Resource
        has n, :web_pages, :through => DataMapper::Resource
        
        has n, :links_to_source_scrapers, 'ScraperLink', :child_key => [:target_id]
        has n, :links_to_target_scrapers, 'ScraperLink', :child_key => [:source_id]
        
        has n, :source_scrapers, 'Scraper', :through => :links_to_source_scrapers, :via => :source
        has n, :target_scrapers, 'Scraper', :through => :links_to_target_scrapers, :via => :target
        
        traverse :source_scrapers, :web_pages, :regexps
        export   :source_scrapers, :web_pages, :regexps
      end
      
      class ScraperLink
        include DataMapper::Resource
        
        property :source_id, Integer, :key => true, :min => 1
        property :target_id, Integer, :key => true, :min => 1

        belongs_to :source, 'Scraper', :key => true
        belongs_to :target, 'Scraper', :key => true

        # prevent self-reference
        validates_with_method :prevent_self_reference
        def prevent_self_reference
          if source_id == target_id
            [ false, 'Scraper cannot link to itself.' ]
          else
            true
          end
        end
      end
      
      class WebPage
        include Resource
        
        has n, :scrapers, :through => DataMapper::Resource
        
        has n, :terminates, 'Regexp', :through => :terminate_links, :via => :regexp
        has n, :terminate_links
        
        property :url, String,  :default => 'http://www.google.com/'
        has n, :posts,          :through => DataMapper::Resource
        has n, :headers,        :through => DataMapper::Resource
        has n, :cookies, 'Cookie', :through => DataMapper::Resource
        
        has n, :links_to_login_web_pages, 'WebPageLink', :child_key => [:target_id]
        has n, :links_to_logged_in_web_pages, 'WebPageLink', :child_key => [:source_id]
        
        has n, :login_web_pages, 'WebPage', :through => :links_to_login_web_pages, :via => :source
        has n, :logged_in_web_pages, 'WebPage', :through => :links_to_logged_in_web_pages, :via => :target
        
        traverse :terminates, :posts, :headers, :cookies , :login_web_pages
        export   :terminates, :posts, :headers, :cookies , :login_web_pages
        mustacheable :url

        validates_format_of :url, :as => :url
      end
      
      class WebPageLink
        include DataMapper::Resource
        
        property :source_id, Integer, :key => true, :min => 1
        property :target_id, Integer, :key => true, :min => 1

        belongs_to :source, 'WebPage', :key => true
        belongs_to :target, 'WebPage', :key => true       

        # prevent self-reference
        validates_with_method :prevent_self_reference
        def prevent_self_reference
          if source_id == target_id
            [ false, 'Scraper cannot link to itself.' ]
          else
            true
          end
        end
      end
      
      class TerminateLink
        include DataMapper::Resource
        
        belongs_to :web_page, :key => true
        belongs_to :regexp, :key => true
      end

      class Regexp
        include Resource
        
        has n, :web_pages, :through => :terminate_links
        has n, :terminate_links

        has n, :scrapers,  :through => DataMapper::Resource
        
        property :regexp,       Text,    :required => true, :default => ''
        property :match_number, Integer, :required => false
        property :substitution,   Text,    :required => true, :default => '$0'
        property :case_insensitive, Boolean, :required => true, :default => true
        property :multiline,        Boolean, :required => true, :default => false
        property :dot_matches_newline, Boolean, :required => true, :default => true
        
        mustacheable :regexp, :substitution
        
        # Replace blank match_number with nil.
        after :match_number= do 
          send(:match_number=, nil) if match_number == ''
        end
        
        # Validate regular expression format, standardize how regexp looks.
        validates_with_method :validate_regexp
        def validate_regexp
          # Remove mustache components
          regexp_no_mustache = Mustache::MicroScraper.remove_tags(regexp)
          
          # Test regular expression once mustache components are removed
          begin
            Object::Regexp.compile(regexp_no_mustache)
            true
          rescue RegexpError
            [ false, "Could not compile '#{regexp}' as regular expression" ]
          end
        end
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
