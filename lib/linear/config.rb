module Linear
  class Config
    class << self
      def api_key
        ENV['LINEAR_API_KEY']
      end

      def configured?
        !api_key.nil? && !api_key.empty?
      end
    end
  end
end
