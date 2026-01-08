module Linear
  module Commands
    module AddComment
      extend self

      def add_comment(issue_id, body, client: Client.new)
        # First get the issue to get its internal ID
        issue_result = client.query(Queries::ISSUE, { id: issue_id })
        issue = issue_result.dig("data", "issue")

        unless issue
          puts "Error: Issue not found: #{issue_id}"
          return
        end

        result = client.query(Queries::CREATE_COMMENT, {
          issueId: issue['id'],
          body: body
        })

        if result.dig("data", "commentCreate", "success")
          puts "Comment added to #{issue_id}"
        else
          puts "Error: Failed to add comment"
        end
      end
    end
  end
end
