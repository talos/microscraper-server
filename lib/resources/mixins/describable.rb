include 'dm-core'

include 'lib/resources/locale'

module MicroScraper
  module Resources
    
    # Describable resources have a single description available in an unlimited number of Locales.
    module Describable
      def self.included(base)
        base.class_eval do
          include Resource
          
          has n, :descriptions
        end
      end
      
      def set_description_for(locale)
        
      end

      def get_description_for(locale)
        description_texts.find( :locale => locale )
      end
      
      def languages
        description.locales.collect { |locale| locale.language }
      end
    end
    
    class Description
      include Resource
      
      property :id, Serial
      property :text, Text

      belongs_to :locale
    end
  end
end
