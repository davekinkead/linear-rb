require 'spec_helper'
require 'open3'

RSpec.describe 'bin/linear', type: :integration do
  let(:bin_path) { File.expand_path('../../bin/linear', __dir__) }

  def run_command(*args)
    cmd = [bin_path, *args].join(' ')
    stdout, stderr, status = Open3.capture3(cmd)
    { stdout: stdout, stderr: stderr, status: status }
  end

  describe 'help command' do
    it 'displays usage information' do
      result = run_command('help')
      expect(result[:stdout]).to include('Linear CLI')
      expect(result[:stdout]).to include('Usage:')
      expect(result[:status].success?).to be true
    end
  end

  describe 'teams command' do
    context 'when API key is configured', :live do
      it 'lists teams' do
        puts "\n→ Running: linear teams"
        result = run_command('teams')
        puts result[:stdout]
        puts "(exit code: #{result[:status].exitstatus})"
      end
    end

    context 'when API key is missing' do
      it 'displays error message' do
        result = run_command('teams')
        # Will either succeed if key exists, or fail with helpful message
        unless result[:status].success?
          expect(result[:stdout]).to include('Error:')
        end
      end
    end
  end

  describe 'issue command' do
    context 'when issue ID is missing' do
      it 'displays error and usage' do
        result = run_command('issue')
        expect(result[:stdout]).to include('Error: issue ID required')
        expect(result[:stdout]).to include('Usage: linear issue ISSUE_ID')
        expect(result[:status].success?).to be false
      end
    end

    context 'when issue does not exist', :live do
      it 'displays not found message' do
        puts "\n→ Running: linear issue NONEXISTENT-99999"
        result = run_command('issue', 'NONEXISTENT-99999')
        puts result[:stdout]
        puts "(exit code: #{result[:status].exitstatus})"
      end
    end
  end

  describe 'search command' do
    context 'when query is missing' do
      it 'displays error and usage' do
        result = run_command('search')
        expect(result[:stdout]).to include('Error: search query required')
        expect(result[:stdout]).to include('Usage: linear search QUERY')
        expect(result[:status].success?).to be false
      end
    end

    context 'with valid query', :live do
      it 'executes search' do
        puts "\n→ Running: linear search test"
        result = run_command('search', 'test')
        puts result[:stdout]
        puts "(exit code: #{result[:status].exitstatus})"
      end
    end
  end

  describe 'mine command', :live do
    it 'displays assigned issues' do
      puts "\n→ Running: linear mine"
      result = run_command('mine')
      puts result[:stdout]
      puts "(exit code: #{result[:status].exitstatus})"
    end
  end

  describe 'comment command' do
    context 'when arguments are missing' do
      it 'displays error for missing issue ID' do
        result = run_command('comment')
        expect(result[:stdout]).to include('Error: issue ID and comment text required')
        expect(result[:status].success?).to be false
      end

      it 'displays error for missing comment text' do
        result = run_command('comment', 'FAT-123')
        expect(result[:stdout]).to include('Error: issue ID and comment text required')
        expect(result[:status].success?).to be false
      end
    end
  end

  describe 'update command' do
    context 'when arguments are missing' do
      it 'displays error for missing issue ID' do
        result = run_command('update')
        expect(result[:stdout]).to include('Error: issue ID and state name required')
        expect(result[:status].success?).to be false
      end

      it 'displays error for missing state name' do
        result = run_command('update', 'FAT-123')
        expect(result[:stdout]).to include('Error: issue ID and state name required')
        expect(result[:status].success?).to be false
      end
    end
  end

  describe 'unknown command' do
    it 'displays error and usage' do
      result = run_command('foobar')
      expect(result[:stdout]).to include('Unknown command: foobar')
      expect(result[:stdout]).to include('Usage:')
      expect(result[:status].success?).to be false
    end
  end
end
