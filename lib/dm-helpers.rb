require 'rubygems'
require 'dm-core'

module DataMapper
  # module MicroScraper
  #   class Options
  #     OPTIONS = [:description, :traverse, :export]
  #     OPTIONS.each { |option| attr_reader option }
  #     def initialize(options = {})
  #       if options[:micro_scraper]
  #         options[:micro_scraper].each do |option, value|
  #           instance_variable_set('@' + option.to_s, value) if OPTIONS.include?(option.to_sym)
  #         end
  #       end
  #     end
  #   end
  # end

  # module Associations
  #   class Relationship
  #     include DataMapper::Hook
      
  #     OPTIONS << :micro_scraper
  #     attr_reader :micro_scraper
      
  #     send :public, :initialize
  #     before :initialize do |name, child_model, parent_model, options|
  #       @micro_scraper = MicroScraper::Options.new(options)
  #     end
  #     send :private, :initialize
  #   end
  # end

  # class Property
  #   include DataMapper::Hook
    
  #   OPTIONS << :micro_scraper
  #   attr_reader :micro_scraper
    
  #   send :public, :initialize
  #   before :initialize do |model, name, options, *args|
  #     @micro_scraper = MicroScraper::Options.new(options)
  #   end
  #   send :private, :initialize
  # end
  
  module Model
    def raw_name
      DataMapper::Inflector.underscore(name.split('::').last)
    end
    
    # TODO THIS IS ASSUMING EVERYTHING LIVES IN THE '/' DIRECTORY
    def location
      #'/editor/' + self.raw_name + '/'
      # @settings[:directory] + self.raw_name + '/'
      '/' + self.raw_name + '/'
    end
  end
end
