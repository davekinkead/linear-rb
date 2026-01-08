module Linear
  module Commands
    module UpdateIssue
      extend self

      def update_issue(issue_id, state: nil, title: nil, description: nil, client: Client.new)
        # Validate that at least one option is provided
        unless state || title || description
          puts "Error: At least one of --state, --title, or --description must be provided"
          return
        end

        # Get the issue to get its internal ID
        issue_result = client.query(Queries::ISSUE, { id: issue_id })
        issue = issue_result.dig("data", "issue")

        unless issue
          puts "Error: Issue not found: #{issue_id}"
          return
        end

        variables = { issueId: issue['id'] }
        updates = []

        # Handle state update (need to look up state ID from name)
        if state
          # Get team from issue identifier
          team_key = issue_id.split('-').first
          teams_result = client.query(Queries::TEAMS)
          teams = teams_result.dig("data", "teams", "nodes") || []
          team = teams.find { |t| t['key'] == team_key }

          unless team
            puts "Error: Team not found for issue #{issue_id}"
            return
          end

          # Get workflow states for the team
          states_result = client.query(Queries::WORKFLOW_STATES, { teamId: team['id'] })
          states = states_result.dig("data", "team", "states", "nodes") || []
          target_state = states.find { |s| s['name'].downcase == state.downcase }

          unless target_state
            puts "Error: State '#{state}' not found. Available states:"
            states.each { |s| puts "  - #{s['name']}" }
            return
          end

          variables[:stateId] = target_state['id']
          updates << "state to '#{target_state['name']}'"
        end

        # Handle title update
        if title
          variables[:title] = title
          updates << "title"
        end

        # Handle description update
        if description
          variables[:description] = description
          updates << "description"
        end

        # Update the issue
        result = client.query(Queries::UPDATE_ISSUE, variables)

        if result.dig("data", "issueUpdate", "success")
          puts "Updated #{issue_id}: #{updates.join(', ')}"
        else
          puts "Error: Failed to update issue"
        end
      end
    end
  end
end
