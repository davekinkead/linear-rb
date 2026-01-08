module Linear
  module Queries
    PROJECTS = <<~GQL
      query {
        projects {
          nodes {
            id
            name
            description
            state
            progress
            startDate
            targetDate
            url
            lead {
              name
              email
            }
          }
        }
      }
    GQL
  end
end
