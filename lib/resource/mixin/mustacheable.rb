require 'dm-core'
require 'dm-validations'
require 'mustache'

module MicroScraper
  module Resources

    # Mustacheable resources can declare that certain properties will be
    # compiled using mustache using 'mustache': 
    # @example 
    #   include Mustacheable
    #   property :foo, String
    #   property :bar, String
    #   mustache :foo, :bar
    #
    module Mustacheable
      def self.included(base)
        base.class_eval do
          include Resource
          
          validates_with_method :comb_mustache
          
          @mustache = Array.new
        end
        
        def self.mustache (*attributes)
          @mustache.to_a.push(*attributes)
        end
        
        # DM Validation to make sure all attributes set to use Mustache can be compiled in it.
        def comb_mustache
          model.mustache.each do |attr|
            begin
              Mustache.templateify(send(attr)).send(:tokens)
            rescue Mustache::Parser::SyntaxError
              # TODO localization
              return [ false, "'#{attr}' is not a valid Mustache template." ]
            end
          end
          true
        end

        # @return [Array<String>] of tag names that could be substituted in this resource's mustacheable properties.
        def property_tags
          property_tags = Array.new
          @mustache.collect do |name|
            template_helper = TemplateHelper.new(attribute_get(name))
            property_tags << *template_helper.extract_tags
          end
          property_tags.uniq
        end
        
        # Helper class to perform extra operations on a Mustache template
        class TemplateHelper
          # @param [String]
          def initialize(string)
            @string = string
            @template = Mustache.templateify(string)
          end
          
          # @return [String] the template without its tags.
          def without_tags
            @string.gsub(/\{\{[^\{\}]*\}\}/, '')
          end

          # @return [Array<String>] an array of the template's tag strings.
          def extract_tags
            process_tokens(*@template.tokens)
          end
          
          private
          def process_tokens *tokens
            tags = []
            first = tokens.shift
            second = tokens[0]
            if first == :mustache and second == :fetch
              tokens.shift
              tags.push(tokens.flatten.first)
            else
              tokens.each { |token| tags.push(*process_tokens(*token)) }
            end
            tags.uniq
          end
        end
      end
    end
  end
end

# (related_resources.push(self)).each do |resource|
#             resource.model.mustacheable_attributes.collect do |attr_name|
#               begin
#                 variables.push(*Mustache::MicroScraper.extract_variables(resource.send(attr_name)))
#               rescue Mustache::Parser::SyntaxError
#                 # Ignore malformed attributes
#               end
#             end
#           end
#           variables.uniq # eliminate duplicate variables
#         end
