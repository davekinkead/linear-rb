module CommandsHelper
  def mock_client
    @mock_client ||= instance_double(Linear::Client)
  end

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end

RSpec.configure do |config|
  config.include CommandsHelper, type: :command
end
