include 'dm-core'


module MicroScraper
  module Resources
    
    # Resource for languages
    class Locale
      include Resource
      
      property :language, String, :key => true
    end
  end
end
