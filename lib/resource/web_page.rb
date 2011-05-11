require 'dm-core'
require 'editable'
require 'mustacheable'
require 'testable'
require 'regexp'
require 'headers'

module MicroScraper
  module Resources
    
    class WebPage
      include Resource
      include Editable
      include Mustacheable
      include Testable

      has n, :terminates, 'Regexp', :through => :web_page_terminates, :via => :regexp
      has n, :web_page_terminates
      
      property :url, String,     :required => true, :default => 'http://www.google.com/'
      has n, :posts,             :through => Resource
      has n, :headers,           :through => Resource
      has n, :cookies, 'Cookie', :through => Resource
      
      has n, :links_to_preceding_scrapers, 'WebPageLink', :child_key => [:target_id]
      has n, :links_to_succeeding_in_web_pages, 'WebPageLink', :child_key => [:source_id]
      
      has n, :succeeding_web_pages, 'WebPage', :through => :links_to_succeeding_web_pages, :via => :source
      has n, :preceding_web_pages, 'WebPage', :through => :links_to_preceding_web_pages, :via => :target
      
      view     :terminates, :posts, :headers, :cookies , :preceding_web_pages
      test     :terminates, :posts, :headers, :cookies , :preceding_web_pages
      mustache :url
      
      validates_format_of :url, :as => :url
    end

    class WebPageTerminate
      include DataMapper::Resource
      
      belongs_to :web_page, :key => true
      belongs_to :regexp, :key => true
    end
  end
end
