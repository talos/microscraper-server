module MicroScraper
  module Resources
    module Visible
      # Instance methods
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

      # Class methods
      def self.visible_relationships
        relationships.select do |r|
          @visible.to_a.include?(r.name.to_sym)
        end
      end
      
      def self.visible (*relationship_names)
        @visible = @visible.to_a.push(*relationship_names)
      end
    end
  end
end
