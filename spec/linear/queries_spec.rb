require 'spec_helper'

RSpec.describe Linear::Queries do
  describe 'ISSUE' do
    it 'is a valid GraphQL query string' do
      expect(described_class::ISSUE).to be_a(String)
      expect(described_class::ISSUE).to include('query($id: String!)')
      expect(described_class::ISSUE).to include('issue(id: $id)')
    end

    it 'includes expected fields' do
      query = described_class::ISSUE
      expect(query).to include('id')
      expect(query).to include('identifier')
      expect(query).to include('title')
      expect(query).to include('description')
      expect(query).to include('state')
      expect(query).to include('assignee')
      expect(query).to include('priority')
      expect(query).to include('createdAt')
      expect(query).to include('updatedAt')
      expect(query).to include('url')
    end
  end

  describe 'SEARCH_ISSUES' do
    it 'is a valid GraphQL query string' do
      expect(described_class::SEARCH_ISSUES).to be_a(String)
      expect(described_class::SEARCH_ISSUES).to include('query($filter: IssueFilter!)')
      expect(described_class::SEARCH_ISSUES).to include('issues(filter: $filter)')
    end

    it 'returns nodes with expected fields' do
      query = described_class::SEARCH_ISSUES
      expect(query).to include('nodes')
      expect(query).to include('identifier')
      expect(query).to include('title')
      expect(query).to include('state')
      expect(query).to include('assignee')
      expect(query).to include('priority')
      expect(query).to include('url')
    end
  end

  describe 'MY_ISSUES' do
    it 'is a valid GraphQL query string' do
      expect(described_class::MY_ISSUES).to be_a(String)
      expect(described_class::MY_ISSUES).to include('query')
      expect(described_class::MY_ISSUES).to include('viewer')
      expect(described_class::MY_ISSUES).to include('assignedIssues')
    end

    it 'returns nodes with expected fields' do
      query = described_class::MY_ISSUES
      expect(query).to include('nodes')
      expect(query).to include('identifier')
      expect(query).to include('title')
      expect(query).to include('state')
      expect(query).to include('priority')
      expect(query).to include('url')
    end
  end

  describe 'TEAMS' do
    it 'is a valid GraphQL query string' do
      expect(described_class::TEAMS).to be_a(String)
      expect(described_class::TEAMS).to include('query')
      expect(described_class::TEAMS).to include('teams')
    end

    it 'returns nodes with expected fields' do
      query = described_class::TEAMS
      expect(query).to include('nodes')
      expect(query).to include('id')
      expect(query).to include('key')
      expect(query).to include('name')
    end
  end

  describe 'WORKFLOW_STATES' do
    it 'is a valid GraphQL query string' do
      expect(described_class::WORKFLOW_STATES).to be_a(String)
      expect(described_class::WORKFLOW_STATES).to include('query($teamId: String!)')
      expect(described_class::WORKFLOW_STATES).to include('team(id: $teamId)')
    end

    it 'returns states nodes with expected fields' do
      query = described_class::WORKFLOW_STATES
      expect(query).to include('states')
      expect(query).to include('nodes')
      expect(query).to include('id')
      expect(query).to include('name')
      expect(query).to include('type')
    end
  end

  describe 'CREATE_COMMENT' do
    it 'is a valid GraphQL mutation string' do
      expect(described_class::CREATE_COMMENT).to be_a(String)
      expect(described_class::CREATE_COMMENT).to include('mutation($issueId: String!, $body: String!)')
      expect(described_class::CREATE_COMMENT).to include('commentCreate')
    end

    it 'includes expected fields in response' do
      query = described_class::CREATE_COMMENT
      expect(query).to include('success')
      expect(query).to include('comment')
      expect(query).to include('id')
      expect(query).to include('body')
    end
  end

  describe 'UPDATE_ISSUE' do
    it 'is a valid GraphQL mutation string' do
      expect(described_class::UPDATE_ISSUE).to be_a(String)
      expect(described_class::UPDATE_ISSUE).to include('mutation($issueId: String!, $stateId: String, $description: String)')
      expect(described_class::UPDATE_ISSUE).to include('issueUpdate')
    end

    it 'includes expected fields in response' do
      query = described_class::UPDATE_ISSUE
      expect(query).to include('success')
      expect(query).to include('issue')
      expect(query).to include('id')
      expect(query).to include('identifier')
      expect(query).to include('state')
      expect(query).to include('description')
    end
  end
end
