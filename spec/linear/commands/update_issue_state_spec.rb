require 'spec_helper'

RSpec.describe Linear::Commands::UpdateIssueState, type: :command do
  describe '.update_issue_state' do
    let(:issue_id) { 'FAT-123' }
    let(:state_name) { 'Done' }
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

    context 'when state update is successful' do
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

        expect { described_class.update_issue_state(issue_id, state_name, client: mock_client) }
          .to output(/Updated FAT-123 to 'Done'/).to_stdout
      end
    end

    context 'when update fails' do
      let(:issue_data) { { 'data' => { 'issue' => nil } } }

      it 'displays error message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect { described_class.update_issue_state(issue_id, state_name, client: mock_client) }
          .to output(/Error: Issue not found: FAT-123/).to_stdout
      end
    end
  end
end
