module Linear
  module Queries
    TEAMS = <<~GQL
      query {
        teams {
          nodes {
            id
            key
            name
          }
        }
      }
    GQL
  end
end
