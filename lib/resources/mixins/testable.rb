require 'dm-core'

module MicroScraper
  module Resources
    
    # Serializable resources can be serialized into a hash of the following format:
    #   { <resource model name without namespace> : 
    #      {  <resource identifier> :
    #          { <attribute name> : <attribute_value>
    #            <relationship name> : [
    #                                   <resource identifier>
    #                                   <resource identifier>
    #                                  ]
    #           }
    #      }
    #   }
    # By default, all public accessible attributes are serialized.  Relationships must
    # be specified as follows
    # @example
    #   class Bar
    #     include DataMapper::Resource
    #     
    #     property :id, Serial
    #   end
    #
    #   class Foo
    #     include DataMapper::Resource
    #     include Serializable
    #     
    #     property :id, Serial
    #     has n, :bars
    #
    #     serialize :bars
    #   end
    
    module Serializable
      def self.included(base)
        base.class_eval do
          include Resource
          
          @serialize = Array.new
        end
      end

      # @params [*Symbol]
      def self.serialize(*relationship_names)

      end

      def serialize
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
      
      # Class methods
      def self.testable_relationships
        relationships.select do |r|
          @test.to_a.include?(r.name.to_sym)
        end
      end

      def self.test_with (*relationship_names)
        @test = @test.to_a.push(*relationship_names)
      end
      
    end
  end
end
