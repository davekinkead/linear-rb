require 'spec_helper'

RSpec.describe Linear::Commands::UpdateIssueDescription, type: :command do
  describe '.update_issue_description' do
    let(:issue_id) { 'FAT-123' }
    let(:description) { 'New description' }
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

    context 'when description update is successful' do
      let(:update_data) do
        {
          'data' => {
            'issueUpdate' => {
              'success' => true,
              'issue' => {
                'id' => 'issue-uuid',
                'identifier' => 'FAT-123',
                'description' => description
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
          .with(Linear::Queries::UPDATE_ISSUE, { issueId: 'issue-uuid', description: description })
          .and_return(update_data)

        expect { described_class.update_issue_description(issue_id, description, client: mock_client) }
          .to output(/Updated FAT-123 description/).to_stdout
      end
    end

    context 'when issue does not exist' do
      let(:issue_data) { { 'data' => { 'issue' => nil } } }

      it 'displays error message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect { described_class.update_issue_description(issue_id, description, client: mock_client) }
          .to output(/Error: Issue not found: FAT-123/).to_stdout
      end
    end
  end
end
