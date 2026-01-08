module Linear
  module Commands
    module MyIssues
      extend self

      def my_issues(client: Client.new)
        result = client.query(Queries::MY_ISSUES)

        issues = result.dig("data", "viewer", "assignedIssues", "nodes") || []
        if issues.empty?
          puts "No issues assigned to you"
        else
          Formatters.display_issue_list(issues)
        end
      end
    end
  end
end
