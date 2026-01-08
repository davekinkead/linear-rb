module Linear
  module Queries
    LIST_ISSUES = <<~GQL
      query($filter: IssueFilter!) {
        issues(filter: $filter) {
          nodes {
            id
            identifier
            title
            state {
              name
              type
            }
            assignee {
              name
            }
            priority
            url
          }
        }
      }
    GQL
  end
end
