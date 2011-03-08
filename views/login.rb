module SimpleScraper
  class Application
    module Views
      class Login < Layout
        def login_url
          request.url
        end
      end
    end
  end
end
