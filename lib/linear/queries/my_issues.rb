module Linear
  module Queries
    MY_ISSUES = <<~GQL
      query {
        viewer {
          assignedIssues {
            nodes {
              id
              identifier
              title
              state {
                name
                type
              }
              priority
              url
            }
          }
        }
      }
    GQL
  end
end
