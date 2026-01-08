require 'spec_helper'

RSpec.describe Linear::Commands::ListProjects, type: :command do
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
end
