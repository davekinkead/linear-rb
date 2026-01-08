module Linear
  module Commands
    module ListIssues
      extend self

      def list_issues(options = {}, client: Client.new)
        filter = {}
        filter[:title] = { contains: options[:query] } if options[:query]
        filter[:project] = { id: { eq: options[:project] } } if options[:project]
        filter[:state] = { name: { eqIgnoreCase: options[:state] } } if options[:state]
        filter[:team] = { key: { eq: options[:team] } } if options[:team]

        result = client.query(Queries::LIST_ISSUES, { filter: filter })

        issues = result.dig("data", "issues", "nodes") || []
        if issues.empty?
          puts "No issues found"
        else
          Formatters.display_issue_list(issues)
        end
      end
    end
  end
end
