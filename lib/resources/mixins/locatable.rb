require 'dm-core'
require 'dm-types'
require 'dm-validations'
require 'addressable/uri'
require 'addressable/template'

module MicroScraper
  module Resources

    # Locatable resources have a Serial ID, can generate a relative URI, and must have a title.
    # The URI is generated using #{DEFAULT_MODEL} and #{DEFAULT_RESOURCE}
    module Locatable
      
      # Default URI root for Locatable models & resources.
      DEFAULT_ROOT = Addressable::URI.parse('/')
      
      # Default URI template for a Locatable model.
      DEFAULT_MODEL = Addressable::Template.new('{model}/')

      # Default URI template for a Locatable resource (appended to the model)
      DEFAULT_RESOURCE = Addressable::Template.new('{-suffix|/|within}{title}')
      
      # This class holds all the necessary templates for Locatables.
      class LocatableTemplate
        # @param [Hash] opts options to create the LocatableTemplate
        # @option opts [Addressable::URI]      :root     Root URI
        # @option opts [Addressable::Template] :model    Model template (combined with Root URI)
        # @option opts [Addressable::Template] :resource Resource template (combined with Model template)
        def initialize(opts)
          @model =    Addressable::Template.new(opts[:root].to_s + opts[:model].pattern)
          @resource = Addressable::Template.new(@model.pattern + opts[:resource].pattern)
        end

        # @param [Addressable::URI] uri URI to extract from
        # @return [String] the name of the model this URI points to
        def extract_model_name(uri)
          @model.extract(uri.path)['model']
        end

        # @param (see #extract_model_name)
        # @return [String] the value of the property that this URI is within
        def extract_within(uri)
          @resource.extract(uri.path)['within']
        end

        # @param (see #extract_model_name)
        # @return [String] the title of the resource this URI points to
        def extract_title(uri)
          @resource.extract(uri.path)['title']
        end
        
        # @param [DataMapper::Model] model
        # @return [Addressable::URI] absolute path to model
        def expand_model(model)
          @model.expand(:model => DataMapper::Inflector.demodulize(model))
        end
        
        # @param [DataMapper::Model] model
        # @param [String] title
        # @param [String] within_value Optional value of property which the resource is within
        # @return [Addressable::URI] absolute path to resource
        def expand_resource(model, title, within_value = nil)
          @resource.expand(:model => DataMapper::Inflector.demodulize(model), :title => title, :within => within_value.to_a)
        end
      end

      # Modify the template used by Locatable
      # @param [MicroScraper::Resources::Locatable::LocatableTemplate] template a new template
      # @return [MicroScraper::Resources::Locatable] the module
      def self.set_template(template)
        @@template = template
        self
      end
      
      # A hash of all locatable classes, keyed by their location.
      @@locatables = Hash.new
      
      @@template = LocatableTemplate.new ({:root => DEFAULT_ROOT, :model => DEFAULT_MODEL, :resource => DEFAULT_RESOURCE })
      
      def self.included(base)
        base.class_eval do
          include DataMapper::Resource
          
          property :id,   DataMapper::Property::Serial, :accessor => :private
          property :title, DataMapper::Property::String, :required => true, :unique_index => :uindex
          property :deleted_at, DataMapper::Property::ParanoidDateTime, :writer => :private, :unique_index => :uindex
          
          # Replace whitespaces with a dash, eliminate nonalphanumerics from title.
          before :save do 
            self.title= title.gsub(/\s+/, '-')
            self.title= title.gsub(/[^a-zA-Z0-9\-]/, '')
          end

          # Keep track of our locatable models.
          @@locatables[@@template.expand_model(base)] = base

          # Obtain an absolute path to the resource's model.
          # @param (see #location)
          # @return [Addressable::URI] an absolute path to the model.
          def self.location(template = @@template)
            template.expand_model(self)
          end
        end
      end
      
      # Locate a resource within a many-to-one or one-to-one relationship along a specific attribute.
      # @param [Symbol] relationship a symbol referring to a many-to-one or one-to-one relationship
      # @param [Symbol] property a property of the resource on the other side of that relationship
      # @return [String] the current value of that relationship's property
      def self.within(relationship, property)
        @within_relationship = relationship
        @within_property = property
        
        send(relationship).get_attribute(property)
      end


      # Obtain an absolute path the resource.
      # @param [MicroScraper::Resources::Locatable::LocatableTemplate] template Optional alternate template.
      # @return [Addressable::URI] an absolute path to the resource.
      def location(template = @@template)
        if @within_relationship
          template.expand_resource(self.model, self.title, send(@within_relationship).attribute_get(@within_property))
        else
          template.expand_resource(self.model, self.title)
        end
      end
      
      # Obtain a Locatable resource model from a URI.
      # @param [Addressable::URI] uri URI for model
      # @param template (see #location)
      # @return [DataMapper::Model] a DataMapper model with the Locatable Mixin
      def self.get_model(uri, template = @@template)
        @@locatables[template.extract_model_name(uri)]
      end
      
      # Obtain a resource based off of a URI
      # @param [Addressable::URI] uri URI for resource
      # @param template (see #location)
      # @return [DataMapper::Resource] a DataMapper resource with the Locatable Mixin
      def self.get_resource(uri, template = @@template)
        model = get_model(template)
        within = template.extract_within(uri)
        title = template.extract_title(uri)
        if within
          model.first(@within_relationship => { @within_property => within }, :title => title)
        else
          model.first(:title => title)
        end
      end
    end
  end
end
