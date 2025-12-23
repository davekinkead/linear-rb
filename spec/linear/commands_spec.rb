require 'spec_helper'

RSpec.describe Linear::Commands do
  let(:mock_client) { instance_double(Linear::Client) }

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  describe '.fetch_issue' do
    let(:issue_id) { 'FAT-123' }

    context 'when issue exists' do
      let(:issue_data) do
        {
          'data' => {
            'issue' => {
              'id' => 'issue-uuid',
              'identifier' => 'FAT-123',
              'title' => 'Test Issue',
              'description' => 'Test description',
              'state' => { 'name' => 'In Progress' },
              'assignee' => { 'name' => 'John Doe' },
              'priority' => 2,
              'url' => 'https://linear.app/issue/FAT-123'
            }
          }
        }
      end

      it 'fetches and displays the issue' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect { described_class.fetch_issue(issue_id, client: mock_client) }.to output(/FAT-123: Test Issue/).to_stdout
      end
    end

    context 'when issue does not exist' do
      let(:issue_data) { { 'data' => { 'issue' => nil } } }

      it 'displays not found message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect { described_class.fetch_issue(issue_id, client: mock_client) }.to output(/Issue not found: FAT-123/).to_stdout
      end
    end
  end

  describe '.list_issues' do
    context 'when issues are found with filters' do
      let(:issues_data) do
        {
          'data' => {
            'issues' => {
              'nodes' => [
                {
                  'identifier' => 'FAT-456',
                  'title' => 'Implement new feature',
                  'state' => { 'name' => 'Backlog' },
                  'assignee' => { 'name' => 'Jane Smith' },
                  'priority' => 3,
                  'url' => 'https://linear.app/issue/FAT-456'
                },
                {
                  'identifier' => 'FAT-789',
                  'title' => 'Fix bug',
                  'state' => { 'name' => 'Backlog' },
                  'assignee' => nil,
                  'priority' => 1,
                  'url' => 'https://linear.app/issue/FAT-789'
                }
              ]
            }
          }
        }
      end

      it 'lists issues filtered by project and state' do
        options = { project: 'project-123', state: 'Backlog' }
        filter = { project: { id: { eq: 'project-123' } }, state: { name: { eqIgnoreCase: 'Backlog' } } }

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::LIST_ISSUES, { filter: filter })
          .and_return(issues_data)
          .once

        output = capture_stdout { described_class.list_issues(options, client: mock_client) }
        expect(output).to match(/Found 2 issue/)
        expect(output).to match(/FAT-456/)
        expect(output).to match(/FAT-789/)
      end

      it 'filters by query text' do
        options = { query: 'authentication' }
        filter = { title: { contains: 'authentication' } }

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::LIST_ISSUES, { filter: filter })
          .and_return(issues_data)

        output = capture_stdout { described_class.list_issues(options, client: mock_client) }
        expect(output).to match(/Found 2 issue/)
      end

      it 'filters by team' do
        options = { team: 'ENG' }
        filter = { team: { key: { eq: 'ENG' } } }

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::LIST_ISSUES, { filter: filter })
          .and_return(issues_data)

        output = capture_stdout { described_class.list_issues(options, client: mock_client) }
        expect(output).to match(/Found 2 issue/)
      end

      it 'filters state case-insensitively' do
        options = { state: 'backlog' }
        filter = { state: { name: { eqIgnoreCase: 'backlog' } } }

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::LIST_ISSUES, { filter: filter })
          .and_return(issues_data)

        output = capture_stdout { described_class.list_issues(options, client: mock_client) }
        expect(output).to match(/Found 2 issue/)
      end

      it 'combines multiple filters' do
        options = { query: 'bug', state: 'in progress', team: 'ENG' }
        filter = {
          title: { contains: 'bug' },
          state: { name: { eqIgnoreCase: 'in progress' } },
          team: { key: { eq: 'ENG' } }
        }

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::LIST_ISSUES, { filter: filter })
          .and_return(issues_data)

        output = capture_stdout { described_class.list_issues(options, client: mock_client) }
        expect(output).to match(/Found 2 issue/)
      end
    end

    context 'when no issues are found' do
      let(:issues_data) { { 'data' => { 'issues' => { 'nodes' => [] } } } }

      it 'displays no issues message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::LIST_ISSUES, { filter: {} })
          .and_return(issues_data)

        expect { described_class.list_issues({}, client: mock_client) }.to output(/No issues found/).to_stdout
      end
    end
  end

  describe '.my_issues' do
    context 'when user has assigned issues' do
      let(:my_issues_data) do
        {
          'data' => {
            'viewer' => {
              'assignedIssues' => {
                'nodes' => [
                  {
                    'identifier' => 'FAT-123',
                    'title' => 'My Issue',
                    'state' => { 'name' => 'In Progress' },
                    'priority' => 2,
                    'url' => 'https://linear.app/issue/FAT-123'
                  }
                ]
              }
            }
          }
        }
      end

      it 'fetches and displays assigned issues' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::MY_ISSUES)
          .and_return(my_issues_data)

        expect { described_class.my_issues(client: mock_client) }.to output(/Found 1 issue/).to_stdout
      end
    end

    context 'when user has no assigned issues' do
      let(:my_issues_data) do
        { 'data' => { 'viewer' => { 'assignedIssues' => { 'nodes' => [] } } } }
      end

      it 'displays no issues message' do
        expect(mock_client).to receive(:query).and_return(my_issues_data)

        expect { described_class.my_issues(client: mock_client) }.to output(/No issues assigned to you/).to_stdout
      end
    end
  end

  describe '.list_teams' do
    let(:teams_data) do
      {
        'data' => {
          'teams' => {
            'nodes' => [
              { 'id' => 'team-1', 'key' => 'FAT', 'name' => 'Frontend Team' },
              { 'id' => 'team-2', 'key' => 'BAK', 'name' => 'Backend Team' }
            ]
          }
        }
      }
    end

    it 'fetches and displays all teams' do
      expect(mock_client).to receive(:query)
        .with(Linear::Queries::TEAMS)
        .and_return(teams_data)
        .once

      output = capture_stdout { described_class.list_teams(client: mock_client) }
      expect(output).to match(/FAT.*Frontend Team/)
      expect(output).to match(/BAK.*Backend Team/)
    end
  end

  describe '.list_projects' do
    context 'when projects exist' do
      let(:projects_data) do
        {
          'data' => {
            'projects' => {
              'nodes' => [
                {
                  'id' => 'project-1',
                  'name' => 'Q4 Launch',
                  'description' => 'Preparing for Q4 product launch',
                  'state' => 'started',
                  'progress' => 0.65,
                  'startDate' => '2025-10-01',
                  'targetDate' => '2025-12-31',
                  'url' => 'https://linear.app/project/q4-launch',
                  'lead' => { 'name' => 'Jane Smith', 'email' => 'jane@example.com' }
                },
                {
                  'id' => 'project-2',
                  'name' => 'Platform Refactor',
                  'description' => 'Technical debt reduction',
                  'state' => 'planned',
                  'progress' => 0.0,
                  'startDate' => '2026-01-01',
                  'targetDate' => '2026-03-31',
                  'url' => 'https://linear.app/project/refactor',
                  'lead' => nil
                }
              ]
            }
          }
        }
      end

      it 'fetches and displays all projects' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::PROJECTS)
          .and_return(projects_data)
          .once

        output = capture_stdout { described_class.list_projects(client: mock_client) }
        expect(output).to match(/Found 2 project/)
        expect(output).to match(/Q4 Launch/)
        expect(output).to match(/\[started\]/)
        expect(output).to match(/65%/)
        expect(output).to match(/Jane Smith/)
        expect(output).to match(/Platform Refactor/)
        expect(output).to match(/\[planned\]/)
        expect(output).to match(/No lead/)
      end
    end

    context 'when no projects exist' do
      let(:projects_data) { { 'data' => { 'projects' => { 'nodes' => [] } } } }

      it 'displays no projects message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::PROJECTS)
          .and_return(projects_data)

        expect { described_class.list_projects(client: mock_client) }
          .to output(/No projects found/).to_stdout
      end
    end
  end

  describe '.add_comment' do
    let(:issue_id) { 'FAT-123' }
    let(:comment_body) { 'This is a test comment' }
    let(:issue_data) do
      {
        'data' => {
          'issue' => {
            'id' => 'issue-uuid',
            'identifier' => 'FAT-123'
          }
        }
      }
    end

    context 'when comment is added successfully' do
      let(:comment_data) do
        {
          'data' => {
            'commentCreate' => {
              'success' => true,
              'comment' => { 'id' => 'comment-uuid', 'body' => comment_body }
            }
          }
        }
      end

      it 'adds comment and displays success message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::CREATE_COMMENT, { issueId: 'issue-uuid', body: comment_body })
          .and_return(comment_data)

        expect { described_class.add_comment(issue_id, comment_body, client: mock_client) }
          .to output(/Comment added to FAT-123/).to_stdout
      end
    end

    context 'when issue does not exist' do
      let(:issue_data) { { 'data' => { 'issue' => nil } } }

      it 'displays error message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect { described_class.add_comment(issue_id, comment_body, client: mock_client) }
          .to output(/Error: Issue not found: FAT-123/).to_stdout
      end
    end

    context 'when comment creation fails' do
      let(:comment_data) do
        { 'data' => { 'commentCreate' => { 'success' => false } } }
      end

      it 'displays error message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::CREATE_COMMENT, { issueId: 'issue-uuid', body: comment_body })
          .and_return(comment_data)

        expect { described_class.add_comment(issue_id, comment_body, client: mock_client) }
          .to output(/Error: Failed to add comment/).to_stdout
      end
    end
  end

  describe '.update_issue' do
    let(:issue_id) { 'FAT-123' }
    let(:issue_data) do
      {
        'data' => {
          'issue' => {
            'id' => 'issue-uuid',
            'identifier' => 'FAT-123'
          }
        }
      }
    end
    let(:teams_data) do
      {
        'data' => {
          'teams' => {
            'nodes' => [
              { 'id' => 'team-uuid', 'key' => 'FAT', 'name' => 'Frontend Team' }
            ]
          }
        }
      }
    end
    let(:states_data) do
      {
        'data' => {
          'team' => {
            'states' => {
              'nodes' => [
                { 'id' => 'state-1', 'name' => 'Todo', 'type' => 'unstarted' },
                { 'id' => 'state-2', 'name' => 'Done', 'type' => 'completed' }
              ]
            }
          }
        }
      }
    end

    context 'when no changes are provided' do
      it 'displays error message' do
        expect { described_class.update_issue(issue_id, client: mock_client) }
          .to output(/Error: At least one of --state, --title, or --description must be provided/).to_stdout
      end
    end

    context 'when issue does not exist' do
      let(:issue_data) { { 'data' => { 'issue' => nil } } }

      it 'displays error message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect { described_class.update_issue(issue_id, title: 'New title', client: mock_client) }
          .to output(/Error: Issue not found: FAT-123/).to_stdout
      end
    end

    context 'when updating state only' do
      let(:update_data) do
        {
          'data' => {
            'issueUpdate' => {
              'success' => true,
              'issue' => {
                'id' => 'issue-uuid',
                'identifier' => 'FAT-123',
                'state' => { 'name' => 'Done' }
              }
            }
          }
        }
      end

      it 'updates issue state and displays success message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::TEAMS)
          .and_return(teams_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::WORKFLOW_STATES, { teamId: 'team-uuid' })
          .and_return(states_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::UPDATE_ISSUE, { issueId: 'issue-uuid', stateId: 'state-2' })
          .and_return(update_data)

        expect { described_class.update_issue(issue_id, state: 'Done', client: mock_client) }
          .to output(/Updated FAT-123: state to 'Done'/).to_stdout
      end
    end

    context 'when updating title only' do
      let(:update_data) do
        {
          'data' => {
            'issueUpdate' => {
              'success' => true,
              'issue' => {
                'id' => 'issue-uuid',
                'identifier' => 'FAT-123',
                'title' => 'New title'
              }
            }
          }
        }
      end

      it 'updates issue title and displays success message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::UPDATE_ISSUE, { issueId: 'issue-uuid', title: 'New title' })
          .and_return(update_data)

        expect { described_class.update_issue(issue_id, title: 'New title', client: mock_client) }
          .to output(/Updated FAT-123: title/).to_stdout
      end
    end

    context 'when updating description only' do
      let(:update_data) do
        {
          'data' => {
            'issueUpdate' => {
              'success' => true,
              'issue' => {
                'id' => 'issue-uuid',
                'identifier' => 'FAT-123',
                'description' => 'New description'
              }
            }
          }
        }
      end

      it 'updates description and displays success message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::UPDATE_ISSUE, { issueId: 'issue-uuid', description: 'New description' })
          .and_return(update_data)

        expect { described_class.update_issue(issue_id, description: 'New description', client: mock_client) }
          .to output(/Updated FAT-123: description/).to_stdout
      end
    end

    context 'when updating multiple fields' do
      let(:update_data) do
        {
          'data' => {
            'issueUpdate' => {
              'success' => true,
              'issue' => {
                'id' => 'issue-uuid',
                'identifier' => 'FAT-123',
                'title' => 'New title',
                'state' => { 'name' => 'Done' },
                'description' => 'New description'
              }
            }
          }
        }
      end

      it 'updates all fields and displays success message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::TEAMS)
          .and_return(teams_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::WORKFLOW_STATES, { teamId: 'team-uuid' })
          .and_return(states_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::UPDATE_ISSUE, {
            issueId: 'issue-uuid',
            stateId: 'state-2',
            title: 'New title',
            description: 'New description'
          })
          .and_return(update_data)

        expect { described_class.update_issue(issue_id, state: 'Done', title: 'New title', description: 'New description', client: mock_client) }
          .to output(/Updated FAT-123: state to 'Done', title, description/).to_stdout
      end
    end
  end

  describe '.priority_label' do
    it 'returns correct label for valid priority' do
      expect(described_class.send(:priority_label, 2)).to eq('High')
    end

    it 'returns Unknown for invalid priority' do
      expect(described_class.send(:priority_label, 99)).to eq('Unknown')
    end
  end
end
