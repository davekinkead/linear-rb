require 'spec_helper'

RSpec.describe Linear::Commands::ListTeams, type: :command do
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
end
