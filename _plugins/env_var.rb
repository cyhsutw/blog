module Jekyll
  class EnvironmentVariablesGenerator < Generator
    def generate(site)
      site.config['analytics']['google']['tracking_id'] = ENV['GOOGLE_ANALYTICS_TRACKING_ID']
    end
  end
end
