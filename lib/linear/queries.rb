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

    SEARCH_ISSUES = <<~GQL
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

    UPDATE_ISSUE = <<~GQL
      mutation($issueId: String!, $stateId: String, $description: String) {
        issueUpdate(id: $issueId, input: {
          stateId: $stateId
          description: $description
        }) {
          success
          issue {
            id
            identifier
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
