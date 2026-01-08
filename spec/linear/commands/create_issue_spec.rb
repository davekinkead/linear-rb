require 'spec_helper'

RSpec.describe Linear::Commands::CreateIssue, type: :command do
  describe '.create_issue' do
    let(:teams_data) do
      {
        'data' => {
          'teams' => {
            'nodes' => [
              { 'id' => 'team-uuid-1', 'key' => 'ENG', 'name' => 'Engineering' },
              { 'id' => 'team-uuid-2', 'key' => 'PROD', 'name' => 'Product' }
            ]
          }
        }
      }
    end

    context 'when creating issue with minimal required fields' do
      let(:options) { { team: 'ENG', title: 'Fix login bug' } }
      let(:create_data) do
        {
          'data' => {
            'issueCreate' => {
              'success' => true,
              'issue' => {
                'id' => 'issue-uuid',
                'identifier' => 'ENG-123',
                'title' => 'Fix login bug',
                'url' => 'https://linear.app/issue/ENG-123'
              }
            }
          }
        }
      end

      it 'creates issue and displays success message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::TEAMS)
          .and_return(teams_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::CREATE_ISSUE, { teamId: 'team-uuid-1', title: 'Fix login bug' })
          .and_return(create_data)

        output = capture_stdout { described_class.create_issue(options, client: mock_client) }
        expect(output).to match(/Created issue: ENG-123/)
        expect(output).to match(/Title: Fix login bug/)
        expect(output).to match(/URL: https:\/\/linear.app\/issue\/ENG-123/)
      end
    end

    context 'when creating issue with all optional fields' do
      let(:options) do
        {
          team: 'ENG',
          title: 'Implement caching',
          description: 'Add Redis caching layer',
          priority: 2,
          state: 'In Progress',
          project: 'project-123'
        }
      end
      let(:states_data) do
        {
          'data' => {
            'team' => {
              'states' => {
                'nodes' => [
                  { 'id' => 'state-1', 'name' => 'Todo', 'type' => 'unstarted' },
                  { 'id' => 'state-2', 'name' => 'In Progress', 'type' => 'started' }
                ]
              }
            }
          }
        }
      end
      let(:create_data) do
        {
          'data' => {
            'issueCreate' => {
              'success' => true,
              'issue' => {
                'id' => 'issue-uuid',
                'identifier' => 'ENG-124',
                'title' => 'Implement caching',
                'url' => 'https://linear.app/issue/ENG-124'
              }
            }
          }
        }
      end

      it 'creates issue with all fields' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::TEAMS)
          .and_return(teams_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::WORKFLOW_STATES, { teamId: 'team-uuid-1' })
          .and_return(states_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::CREATE_ISSUE, {
            teamId: 'team-uuid-1',
            title: 'Implement caching',
            description: 'Add Redis caching layer',
            priority: 2,
            stateId: 'state-2',
            projectId: 'project-123'
          })
          .and_return(create_data)

        output = capture_stdout { described_class.create_issue(options, client: mock_client) }
        expect(output).to match(/Created issue: ENG-124/)
      end
    end

    context 'when team is not found' do
      let(:options) { { team: 'INVALID', title: 'Test issue' } }

      it 'displays error and lists available teams' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::TEAMS)
          .and_return(teams_data)

        output = capture_stdout { described_class.create_issue(options, client: mock_client) }
        expect(output).to match(/Error: Team 'INVALID' not found/)
        expect(output).to match(/ENG - Engineering/)
        expect(output).to match(/PROD - Product/)
      end
    end

    context 'when state is not found' do
      let(:options) { { team: 'ENG', title: 'Test issue', state: 'InvalidState' } }
      let(:states_data) do
        {
          'data' => {
            'team' => {
              'states' => {
                'nodes' => [
                  { 'id' => 'state-1', 'name' => 'Todo', 'type' => 'unstarted' }
                ]
              }
            }
          }
        }
      end
      let(:create_data) do
        {
          'data' => {
            'issueCreate' => {
              'success' => true,
              'issue' => {
                'id' => 'issue-uuid',
                'identifier' => 'ENG-125',
                'title' => 'Test issue',
                'url' => 'https://linear.app/issue/ENG-125'
              }
            }
          }
        }
      end

      it 'displays warning and creates issue without state' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::TEAMS)
          .and_return(teams_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::WORKFLOW_STATES, { teamId: 'team-uuid-1' })
          .and_return(states_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::CREATE_ISSUE, { teamId: 'team-uuid-1', title: 'Test issue' })
          .and_return(create_data)

        output = capture_stdout { described_class.create_issue(options, client: mock_client) }
        expect(output).to match(/Warning: State 'InvalidState' not found, using default/)
        expect(output).to match(/Created issue: ENG-125/)
      end
    end

    context 'when issue creation fails' do
      let(:options) { { team: 'ENG', title: 'Test issue' } }
      let(:create_data) do
        { 'data' => { 'issueCreate' => { 'success' => false } } }
      end

      it 'displays error message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::TEAMS)
          .and_return(teams_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::CREATE_ISSUE, { teamId: 'team-uuid-1', title: 'Test issue' })
          .and_return(create_data)

        output = capture_stdout { described_class.create_issue(options, client: mock_client) }
        expect(output).to match(/Error: Failed to create issue/)
      end
    end

    context 'when team key is case insensitive' do
      let(:options) { { team: 'eng', title: 'Test issue' } }
      let(:create_data) do
        {
          'data' => {
            'issueCreate' => {
              'success' => true,
              'issue' => {
                'id' => 'issue-uuid',
                'identifier' => 'ENG-126',
                'title' => 'Test issue',
                'url' => 'https://linear.app/issue/ENG-126'
              }
            }
          }
        }
      end

      it 'finds team with case insensitive matching' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::TEAMS)
          .and_return(teams_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::CREATE_ISSUE, { teamId: 'team-uuid-1', title: 'Test issue' })
          .and_return(create_data)

        output = capture_stdout { described_class.create_issue(options, client: mock_client) }
        expect(output).to match(/Created issue: ENG-126/)
      end
    end
  end
end
