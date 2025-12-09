require 'spec_helper'

RSpec.describe Linear::Client do
  describe '#initialize' do
    it 'raises error when no API key is provided' do
      ENV.delete('LINEAR_API_KEY')
      expect { described_class.new }.to raise_error(
        RuntimeError, 'No API key configured. Set LINEAR_API_KEY environment variable'
      )
    end
  end

  describe '#query' do
    let(:api_key) { 'test_api_key' }
    let(:client) { described_class.new(api_key) }
    let(:query) { 'query { viewer { id } }' }
    let(:variables) { {} }

    context 'when GraphQL query is successful' do
      before do
        allow(client).to receive(:`).and_return('{"data":{"viewer":{"id":"123"}}}')
      end

      it 'returns parsed JSON response' do
        result = client.query(query, variables)
        expect(result).to eq({ 'data' => { 'viewer' => { 'id' => '123' } } })
      end

      it 'calls curl with correct parameters' do
        expect(client).to receive(:`).with(a_string_matching(/curl -s -X POST/))
          .and_return('{"data":{"viewer":{"id":"123"}}}')
        client.query(query, variables)
      end
    end

    context 'when GraphQL returns errors' do
      before do
        allow(client).to receive(:`).and_return(
          '{"errors":[{"message":"Unauthorized"},{"message":"Invalid token"}]}'
        )
      end

      it 'raises an error with combined error messages' do
        expect { client.query(query, variables) }.to raise_error(
          RuntimeError,
          'GraphQL Error: Unauthorized, Invalid token'
        )
      end
    end

    context 'when GraphQL returns single error' do
      before do
        allow(client).to receive(:`).and_return(
          '{"errors":[{"message":"Not found"}]}'
        )
      end

      it 'raises an error with the error message' do
        expect { client.query(query, variables) }.to raise_error(
          RuntimeError,
          'GraphQL Error: Not found'
        )
      end
    end

    context 'when curl returns invalid JSON' do
      before do
        allow(client).to receive(:`).and_return('invalid json')
      end

      it 'raises JSON parse error' do
        expect { client.query(query, variables) }.to raise_error(JSON::ParserError)
      end
    end

    context 'when variables are provided' do
      let(:variables) { { 'id' => 'issue-123' } }

      before do
        allow(client).to receive(:`).and_return('{"data":{"issue":{"id":"issue-123"}}}')
      end

      it 'includes variables in the request' do
        expected_payload = { query: query, variables: variables }.to_json
        expect(client).to receive(:`).with(a_string_including(Shellwords.escape(expected_payload)))
        client.query(query, variables)
      end
    end
  end
end
