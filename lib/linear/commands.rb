require_relative "commands/fetch_issue"
require_relative "commands/list_issues"
require_relative "commands/my_issues"
require_relative "commands/list_teams"
require_relative "commands/list_projects"
require_relative "commands/add_comment"
require_relative "commands/update_issue_state"
require_relative "commands/update_issue_description"
require_relative "commands/update_issue"
require_relative "commands/create_issue"

module Linear
  module Commands
    extend self

    # Include all command modules
    include FetchIssue
    include ListIssues
    include MyIssues
    include ListTeams
    include ListProjects
    include AddComment
    include UpdateIssueState
    include UpdateIssueDescription
    include UpdateIssue
    include CreateIssue

    # Expose formatters for backward compatibility
    def priority_label(priority)
      Formatters.priority_label(priority)
    end
    private :priority_label
  end
end
