require 'dm-core'

require 'lib/resources/visible'
require 'lib/resources/editable'
require 'lib/resources/mustacheable'
require 'lib/resources/testable'
require 'lib/resources/web_page'

module MicroScraper
  module Resources
    class Regexp
      include Resource
      include Editable
      include Mustacheable
      include Visible
      
      has n, :terminates_web_pages, 'WebPage', :through => :web_page_terminates
      has n, :web_page_terminates

      property :regexp,              Text,    :required => true, :default => '.*'
      property :case_insensitive,    Boolean, :required => true, :default => true
      property :multiline,           Boolean, :required => true, :default => false
      property :dot_matches_newline, Boolean, :required => true, :default => true
      
      mustache :regexp, :replacement
      
      view :web_pages
      
      # Validate regular expression format, standardize how regexp looks.
      validates_with_method :validate_regexp
      def validate_regexp
        # Remove mustache components
        regexp_no_mustache = Mustache::MicroScraper.remove_tags(regexp)
        
        # Test regular expression once mustache components are removed
        begin
          Object::Regexp.compile(regexp_no_mustache)
          true
        rescue RegexpError
          [ false, "Could not compile '#{regexp}' as regular expression" ]
        end
      end
    end
  end
end
