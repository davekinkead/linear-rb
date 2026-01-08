module Linear
  module Queries
    CREATE_ISSUE = <<~GQL
      mutation($teamId: String!, $title: String!, $description: String, $priority: Int, $stateId: String, $assigneeId: String, $projectId: String) {
        issueCreate(input: {
          teamId: $teamId
          title: $title
          description: $description
          priority: $priority
          stateId: $stateId
          assigneeId: $assigneeId
          projectId: $projectId
        }) {
          success
          issue {
            id
            identifier
            title
            url
          }
        }
      }
    GQL
  end
end
