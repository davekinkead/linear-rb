module Linear
  module Queries
    CREATE_COMMENT = <<~GQL
      mutation($issueId: String!, $body: String!) {
        commentCreate(input: {
          issueId: $issueId
          body: $body
        }) {
          success
          comment {
            id
            body
          }
        }
      }
    GQL
  end
end
