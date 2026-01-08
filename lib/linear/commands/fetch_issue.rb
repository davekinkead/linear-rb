module Linear
  module Commands
    module FetchIssue
      extend self

      def fetch_issue(issue_id, client: Client.new)
        result = client.query(Queries::ISSUE, { id: issue_id })

        issue = result.dig("data", "issue")
        if issue
          Formatters.display_issue(issue)
        else
          puts "Issue not found: #{issue_id}"
        end
      end
    end
  end
end
