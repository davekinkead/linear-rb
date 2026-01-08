module Linear
  module Queries
    WORKFLOW_STATES = <<~GQL
      query($teamId: String!) {
        team(id: $teamId) {
          states {
            nodes {
              id
              name
              type
            }
          }
        }
      }
    GQL
  end
end
