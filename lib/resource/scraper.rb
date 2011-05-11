require 'dm-core'
require 'editable'
require 'testable'

module MicroScraper
  module Resources
    class Scraper
      include Resource
      include Editable
      include Testable
      
            class Bundle
        include Resource
        
        has n, :substitutions, :through => DataMapper::Resource
        
        traverse :substitutions, :one_to_many_scrapers, :one_to_one_scrapers
        export :substitutions, :one_to_many_scrapers, :one_to_one_scrapers
      end
      
      class OneToOneScraperLink
        include DataMapper::Resource
        
        property :source_id, Integer, :key => true, :min => 1
        property :target_id, Integer, :key => true, :min => 1

        belongs_to :source, 'OneToOneScraper', :key => true
        belongs_to :target, 'OneToOneScraper', :key => true

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

      class OneToManyScraperLink
        include DataMapper::Resource
        
        property :source_id, Integer, :key => true, :min => 1
        property :target_id, Integer, :key => true, :min => 1

        belongs_to :source, 'OneToOneScraper', :key => true
        belongs_to :target, 'OneToManyScraper', :key => true
      end

      class WebPage
        include Resource
        
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

    end
  end
end
