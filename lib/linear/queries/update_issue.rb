module Linear
  module Queries
    UPDATE_ISSUE = <<~GQL
      mutation($issueId: String!, $stateId: String, $title: String, $description: String) {
        issueUpdate(id: $issueId, input: {
          stateId: $stateId
          title: $title
          description: $description
        }) {
          success
          issue {
            id
            identifier
            title
            state {
              name
            }
            description
          }
        }
      }
    GQL
  end
end
