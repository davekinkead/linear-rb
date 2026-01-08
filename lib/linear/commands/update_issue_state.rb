module Linear
  module Commands
    module UpdateIssueState
      extend self

      def update_issue_state(issue_id, state_name, client: Client.new)
        # Get the issue details including team
        issue_result = client.query(Queries::ISSUE, { id: issue_id })
        issue = issue_result.dig("data", "issue")

        unless issue
          puts "Error: Issue not found: #{issue_id}"
          return
        end

        # Get team states - need to find team ID first
        teams_result = client.query(Queries::TEAMS)
        teams = teams_result.dig("data", "teams", "nodes") || []

        # Find the team from the issue identifier prefix (e.g., "FAT" from "FAT-85")
        team_key = issue_id.split('-').first
        team = teams.find { |t| t['key'] == team_key }

        unless team
          puts "Error: Team not found for issue #{issue_id}"
          return
        end

        # Get workflow states for the team
        states_result = client.query(Queries::WORKFLOW_STATES, { teamId: team['id'] })
        states = states_result.dig("data", "team", "states", "nodes") || []

        # Find the state by name (case-insensitive)
        target_state = states.find { |s| s['name'].downcase == state_name.downcase }

        unless target_state
          puts "Error: State '#{state_name}' not found. Available states:"
          states.each { |s| puts "  - #{s['name']}" }
          return
        end

        # Update the issue
        result = client.query(Queries::UPDATE_ISSUE, {
          issueId: issue['id'],
          stateId: target_state['id']
        })

        if result.dig("data", "issueUpdate", "success")
          puts "Updated #{issue_id} to '#{target_state['name']}'"
        else
          puts "Error: Failed to update issue state"
        end
      end
    end
  end
end
