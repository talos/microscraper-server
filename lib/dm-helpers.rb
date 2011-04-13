require 'rubygems'
require 'dm-core'
require 'uri'

module DataMapper
  module Model
    def raw_name
      #DataMapper::Inflector.underscore(name.split('::').last)
      name.split('::').last
    end
    
    # TODO THIS IS ASSUMING EVERYTHING LIVES IN THE '/' DIRECTORY
    def location
      #'/editor/' + self.raw_name + '/'
      # @settings[:directory] + self.raw_name + '/'
      '/' + URI.encode(self.raw_name) + '/'
    end
  end

  # module Resource
  #   def relationships
  #     one_to_manys = model.relationships.select do |name, relationship|
  #       relationship.class == DataMapper::Associations::OneToMany::Relationship
  #     end

  #     one_to_manys.collect do |name, relationship|
  #       {
  #         :relationship => relationship,
  #         :links => send(name).collect do |resource|
            
  #         end
  #       }
  #     end
  #   end
    
  #   def is_resource?
  #     respond_to? :full_name
  #   end

  #   def is_link?
  #     key.length == 2 and model.relationships.size == 2
  #   end

  #   # TODO LINK SPECIFIC
  #   def source
  #     send(model.relationships.to_a[0][0])
  #   end

  #   def target
  #     send(model.relationships.to_a[1][0])
  #   end

  #   def location
  #     # this is a resource
  #     if is_resource?
  #       model.location + full_name
  #       # this is a link
  #     elsif is_link?
  #       # Track down the many-to-many relationship that uses this link.
  #       relationship = source.model.relationships.find do |name, relationship|
  #         if relationship.respond_to? :through
  #           relationship.through.target_model == model
  #         end
  #       end
  #       # The location of one of the linked resources, plus the key of the second.
  #       if relationship
  #         source.location + '/' + relationship[0].to_s + '/' + target.key.to_s
  #       end
  #     end
  #   end

  #   def follow(from_resource)
  #     if is_resource?
  #       return self
  #     elsif is_link?
        
  #     end
  #   end
  # end
end
# require 'lib/database'; db = MicroScraper::Database.new; user = db.user_model.first; scraper = user.scrapers.first; scraper.web_pages.intermediaries.first.location
