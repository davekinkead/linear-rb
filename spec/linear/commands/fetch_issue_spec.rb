require 'spec_helper'

RSpec.describe Linear::Commands::FetchIssue, type: :command do
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
end
