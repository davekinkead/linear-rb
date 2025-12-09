module Linear
  module Commands
    extend self

    def fetch_issue(issue_id)
      client = Client.new
      result = client.query(Queries::ISSUE, { id: issue_id })

      issue = result.dig("data", "issue")
      if issue
        display_issue(issue)
      else
        puts "Issue not found: #{issue_id}"
      end
    end

    def search(query, options = {})
      client = Client.new

      filter = { title: { contains: query } }
      filter[:team] = { key: { eq: options[:team] } } if options[:team]
      filter[:state] = { name: { eq: options[:state] } } if options[:state]

      result = client.query(Queries::SEARCH_ISSUES, { filter: filter })

      issues = result.dig("data", "issues", "nodes") || []
      if issues.empty?
        puts "No issues found matching: #{query}"
      else
        display_issue_list(issues)
      end
    end

    def my_issues
      client = Client.new
      result = client.query(Queries::MY_ISSUES)

      issues = result.dig("data", "viewer", "assignedIssues", "nodes") || []
      if issues.empty?
        puts "No issues assigned to you"
      else
        display_issue_list(issues)
      end
    end

    def list_teams
      client = Client.new
      result = client.query(Queries::TEAMS)

      teams = result.dig("data", "teams", "nodes") || []
      teams.each do |team|
        puts "#{team['key'].ljust(10)} #{team['name']}"
      end
    end

    def add_comment(issue_id, body)
      client = Client.new

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

    def update_issue_state(issue_id, state_name)
      client = Client.new

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

    def update_issue_description(issue_id, description)
      client = Client.new

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

    private

    def display_issue(issue)
      puts "\n#{issue['identifier']}: #{issue['title']}"
      puts "=" * 60
      puts "Status:   #{issue['state']['name']}"
      puts "Assignee: #{issue.dig('assignee', 'name') || 'Unassigned'}"
      puts "Priority: #{priority_label(issue['priority'])}"
      puts "URL:      #{issue['url']}"
      puts "\nDescription:"
      puts issue['description'] || "(no description)"
      puts ""
    end

    def display_issue_list(issues)
      puts "\nFound #{issues.length} issue(s):\n\n"
      issues.each do |issue|
        state_badge = "[#{issue['state']['name']}]".ljust(15)
        priority_badge = priority_label(issue['priority']).ljust(8)
        assignee = issue.dig('assignee', 'name') || 'Unassigned'

        puts "#{issue['identifier'].ljust(12)} #{state_badge} #{priority_badge} #{issue['title']}"
      end
      puts ""
    end

    def priority_label(priority)
      case priority
      when 0 then "None"
      when 1 then "Urgent"
      when 2 then "High"
      when 3 then "Medium"
      when 4 then "Low"
      else "Unknown"
      end
    end
  end
end
