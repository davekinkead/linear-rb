require 'spec_helper'

RSpec.describe Linear::Commands::MyIssues, type: :command do
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
end
