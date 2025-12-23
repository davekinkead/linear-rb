module Linear
  module Commands
    extend self

    def fetch_issue(issue_id, client: Client.new)
      result = client.query(Queries::ISSUE, { id: issue_id })

      issue = result.dig("data", "issue")
      if issue
        display_issue(issue)
      else
        puts "Issue not found: #{issue_id}"
      end
    end

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
        display_issue_list(issues)
      end
    end

    def my_issues(client: Client.new)
      result = client.query(Queries::MY_ISSUES)

      issues = result.dig("data", "viewer", "assignedIssues", "nodes") || []
      if issues.empty?
        puts "No issues assigned to you"
      else
        display_issue_list(issues)
      end
    end

    def list_teams(client: Client.new)
      result = client.query(Queries::TEAMS)

      teams = result.dig("data", "teams", "nodes") || []
      teams.each do |team|
        puts "#{team['key'].ljust(10)} #{team['name']}"
      end
    end

    def list_projects(client: Client.new)
      result = client.query(Queries::PROJECTS)

      projects = result.dig("data", "projects", "nodes") || []
      if projects.empty?
        puts "No projects found"
      else
        display_project_list(projects)
      end
    end

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

    def update_issue(issue_id, state: nil, title: nil, description: nil, client: Client.new)
      # 1. Validate at least one change provided
      if state.nil? && title.nil? && description.nil?
        puts "Error: At least one of --state, --title, or --description must be provided"
        return
      end

      # 2. Fetch issue to get internal UUID
      issue_result = client.query(Queries::ISSUE, { id: issue_id })
      issue = issue_result.dig("data", "issue")

      unless issue
        puts "Error: Issue not found: #{issue_id}"
        return
      end

      # 3. If state provided, resolve state ID (existing logic)
      state_id = nil
      target_state = nil
      if state
        team_key = issue_id.split('-').first
        teams_result = client.query(Queries::TEAMS)
        teams = teams_result.dig("data", "teams", "nodes") || []
        team = teams.find { |t| t['key'] == team_key }

        unless team
          puts "Error: Team not found for issue #{issue_id}"
          return
        end

        states_result = client.query(Queries::WORKFLOW_STATES, { teamId: team['id'] })
        states = states_result.dig("data", "team", "states", "nodes") || []
        target_state = states.find { |s| s['name'].downcase == state.downcase }

        unless target_state
          puts "Error: State '#{state}' not found. Available states:"
          states.each { |s| puts "  - #{s['name']}" }
          return
        end

        state_id = target_state['id']
      end

      # 4. Build mutation parameters
      params = { issueId: issue['id'] }
      params[:stateId] = state_id if state_id
      params[:title] = title if title
      params[:description] = description if description

      # 5. Execute mutation
      result = client.query(Queries::UPDATE_ISSUE, params)

      # 6. Display results
      if result.dig("data", "issueUpdate", "success")
        changes = []
        changes << "state to '#{target_state['name']}'" if state
        changes << "title" if title
        changes << "description" if description
        puts "Updated #{issue_id}: #{changes.join(', ')}"
      else
        puts "Error: Failed to update issue"
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
        assignee = (issue.dig('assignee', 'name') || 'Unassigned').ljust(15)

        puts "#{issue['identifier'].ljust(12)} #{state_badge} #{priority_badge} #{assignee} #{issue['title']}"
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

    def display_project_list(projects)
      puts "\nFound #{projects.length} project(s):\n\n"
      projects.each do |project|
        state_badge = "[#{project['state']}]".ljust(15)
        progress = project['progress'] ? "#{(project['progress'] * 100).round}%" : "0%"
        progress_badge = progress.ljust(6)
        lead = (project.dig('lead', 'name') || 'No lead').ljust(20)

        puts "#{project['name'].ljust(30)} #{state_badge} #{progress_badge} #{lead}"

        if project['description'] && !project['description'].empty?
          # Show first line of description
          first_line = project['description'].lines.first&.strip
          puts "  #{first_line[0..80]}#{'...' if first_line && first_line.length > 80}" if first_line
        end

        if project['targetDate']
          puts "  Target: #{project['targetDate']}"
        end

        puts "  URL: #{project['url']}" if project['url']
        puts ""
      end
    end
  end
end
