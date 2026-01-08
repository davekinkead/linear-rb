require 'spec_helper'

RSpec.describe Linear::Commands::ListIssues, type: :command do
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
end
