module Linear
  module Queries
    ISSUE = <<~GQL
      query($id: String!) {
        issue(id: $id) {
          id
          identifier
          title
          description
          state {
            name
            type
          }
          assignee {
            name
            email
          }
          priority
          createdAt
          updatedAt
          url
        }
      }
    GQL
  end
end
