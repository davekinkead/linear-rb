module Linear
  module Commands
    module CreateIssue
      extend self

      def create_issue(options, client: Client.new)
        # Get team ID from team key
        teams_result = client.query(Queries::TEAMS)
        teams = teams_result.dig("data", "teams", "nodes") || []
        team = teams.find { |t| t['key'].upcase == options[:team].upcase }

        unless team
          puts "Error: Team '#{options[:team]}' not found. Available teams:"
          teams.each { |t| puts "  #{t['key']} - #{t['name']}" }
          return
        end

        variables = {
          teamId: team['id'],
          title: options[:title]
        }

        # Add optional description
        variables[:description] = options[:description] if options[:description]

        # Add optional project
        variables[:projectId] = options[:project] if options[:project]

        # Handle priority (convert string to integer if needed)
        if options[:priority]
          variables[:priority] = options[:priority].to_i
        end

        # Handle state (need to look up state ID from name)
        if options[:state]
          states_result = client.query(Queries::WORKFLOW_STATES, { teamId: team['id'] })
          states = states_result.dig("data", "team", "states", "nodes") || []
          target_state = states.find { |s| s['name'].downcase == options[:state].downcase }

          if target_state
            variables[:stateId] = target_state['id']
          else
            puts "Warning: State '#{options[:state]}' not found, using default"
          end
        end

        # Handle assignee (need to look up user ID from email)
        if options[:assignee]
          # Would need a new USER_BY_EMAIL query
          puts "Warning: Assignee lookup not yet implemented"
        end

        # Create the issue
        result = client.query(Queries::CREATE_ISSUE, variables)

        if result.dig("data", "issueCreate", "success")
          issue = result.dig("data", "issueCreate", "issue")
          puts "Created issue: #{issue['identifier']}"
          puts "Title: #{issue['title']}"
          puts "URL: #{issue['url']}"
        else
          puts "Error: Failed to create issue"
        end
      end
    end
  end
end
