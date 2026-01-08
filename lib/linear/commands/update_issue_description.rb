module Linear
  module Commands
    module UpdateIssueDescription
      extend self

      def update_issue_description(issue_id, description, client: Client.new)
        # Get the issue to get its internal ID
        issue_result = client.query(Queries::ISSUE, { id: issue_id })
        issue = issue_result.dig("data", "issue")

        unless issue
          puts "Error: Issue not found: #{issue_id}"
          return
        end

        # Update the issue description
        result = client.query(Queries::UPDATE_ISSUE, {
          issueId: issue['id'],
          description: description
        })

        if result.dig("data", "issueUpdate", "success")
          puts "Updated #{issue_id} description"
        else
          puts "Error: Failed to update issue description"
        end
      end
    end
  end
end
