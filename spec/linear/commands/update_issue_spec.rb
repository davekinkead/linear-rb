require 'spec_helper'

RSpec.describe Linear::Commands::UpdateIssue, type: :command do
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
end
