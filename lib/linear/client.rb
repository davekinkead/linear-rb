require 'json'
require 'shellwords'

module Linear
  class Client
    BASE_URL = "https://api.linear.app/graphql"

    def initialize(api_key = nil)
      @api_key = api_key || ENV['LINEAR_API_KEY']
      raise "No API key configured. Set LINEAR_API_KEY environment variable" unless @api_key
    end

    def query(graphql_query, variables = {})
      payload = { query: graphql_query, variables: variables }.to_json
      escaped_payload = Shellwords.escape(payload)

      result = `curl -s -X POST #{BASE_URL} \
        -H "Content-Type: application/json" \
        -H "Authorization: #{@api_key}" \
        -d #{escaped_payload}`

      parsed = JSON.parse(result)

      if parsed["errors"]
        raise "GraphQL Error: #{parsed["errors"].map { |e| e["message"] }.join(", ")}"
      end

      parsed
    end
  end
end
