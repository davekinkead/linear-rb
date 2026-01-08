module Linear
  module Formatters
    extend self

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
        puts "  ID: #{project['id']}"

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
