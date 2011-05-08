require 'dm-core'
require 'visible'
require 'scraper'
require 'parsers'
require 'web_page'
require 'headers'
require 'regexp'

module MicroScraper
  module Resources

    # @author talos
    class User
      include Resource
      include Visible
      
      property :immutable_name, String, :required => true, :unique => true, :accessor => :private
      
      has n, :one_to_one_parsers,   :child_key => [ :creator_id ]
      has n, :one_to_many_parsers,   :child_key => [ :creator_id ]
      has n, :scrapers,      :child_key => [ :creator_id ]
      has n, :web_pages,  :child_key => [ :creator_id ]
      
      has n, :posts,   :child_key => [ :creator_id ]
      has n, :headers, :child_key => [ :creator_id ]
      has n, :cookies, 'Cookie',  :child_key => [ :creator_id ]
      has n, :regexps, :child_key => [ :creator_id ]
      
      def can_edit? (editable)
        editable.editable_by? self
      end
      
      # Default title to immutable name.
      before :valid? do
        send(:title=, immutable_name) if title.nil?
      end
      
      ## TODO: DRY this out
      # def associations
      #   model.relationships.collect do |r|
      #     {
      #       :name => r.name,
      #       :size => send(r.name).length,
      #       :model_location => r.target_model.location,
      #       :location => r.target_model.location + URI.encode(full_name) + '/',
      #       :collection => send(r.name)
      #     }
      #   end
      # end
    end
  end
end
