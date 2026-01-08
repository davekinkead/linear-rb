require 'spec_helper'

RSpec.describe Linear::Commands::AddComment, type: :command do
  describe '.add_comment' do
    let(:issue_id) { 'FAT-123' }
    let(:comment_body) { 'This is a test comment' }
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

    context 'when comment is added successfully' do
      let(:comment_data) do
        {
          'data' => {
            'commentCreate' => {
              'success' => true,
              'comment' => { 'id' => 'comment-uuid', 'body' => comment_body }
            }
          }
        }
      end

      it 'adds comment and displays success message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::CREATE_COMMENT, { issueId: 'issue-uuid', body: comment_body })
          .and_return(comment_data)

        expect { described_class.add_comment(issue_id, comment_body, client: mock_client) }
          .to output(/Comment added to FAT-123/).to_stdout
      end
    end

    context 'when issue does not exist' do
      let(:issue_data) { { 'data' => { 'issue' => nil } } }

      it 'displays error message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect { described_class.add_comment(issue_id, comment_body, client: mock_client) }
          .to output(/Error: Issue not found: FAT-123/).to_stdout
      end
    end

    context 'when comment creation fails' do
      let(:comment_data) do
        { 'data' => { 'commentCreate' => { 'success' => false } } }
      end

      it 'displays error message' do
        expect(mock_client).to receive(:query)
          .with(Linear::Queries::ISSUE, { id: issue_id })
          .and_return(issue_data)

        expect(mock_client).to receive(:query)
          .with(Linear::Queries::CREATE_COMMENT, { issueId: 'issue-uuid', body: comment_body })
          .and_return(comment_data)

        expect { described_class.add_comment(issue_id, comment_body, client: mock_client) }
          .to output(/Error: Failed to add comment/).to_stdout
      end
    end
  end
end
