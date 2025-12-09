# linear-rb

A lightweight Ruby CLI wrapper for the Linear GraphQL API. Built for efficiency with zero external dependencies.

## Installation

### As a gem

```bash
gem install linear-rb
```

### Direct usage (without installing)

```bash
./bin/linear <command>
```

## Configuration

Set your Linear API key as an environment variable:

```bash
export LINEAR_API_KEY=lin_api_YOUR_KEY_HERE
```

Or prepend each command:

```bash
 LINEAR_API_KEY=XYZ123 linear projects
```

Add this to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.) to make it permanent.

Get your API key from: https://linear.app/settings/api

**Security Note**: The gem never stores your API key - it only reads from the environment variable.

## Usage

### View issue details

```bash
linear issue ENG-123
```

### Search for issues

```bash
# Basic search
linear search "authentication bug"

# Filter by team
linear search "bug" --team=ENG

# Filter by state
linear search "feature" --state=Backlog

# Combine filters
linear search "api" --team=ENG --state="In Progress"
```

### View your assigned issues

```bash
linear mine
```

### List teams

```bash
linear teams
```

### Add a comment to an issue

```bash
linear comment DEV-85 "This looks good to me"
```

### Update issue state

```bash
# Move issue to a different state
linear update DEV-85 "Done"
linear update ENG-123 "In Progress"
```

### Help

```bash
linear help
```

## As a Library

You can also use linear-rb as a library in your Ruby code:

```ruby
require 'linear'

# Option 1: Use LINEAR_API_KEY environment variable
# (No code needed - just set the env var)

# Option 2: Pass API key directly to client
client = Linear::Client.new('lin_api_xxx')

# Use the client directly
client = Linear::Client.new
result = client.query(Linear::Queries::ISSUE, { id: "ENG-123" })

# Or use commands
Linear::Commands.fetch_issue("ENG-123")
Linear::Commands.search("bug", team: "ENG")
Linear::Commands.my_issues
Linear::Commands.add_comment("DEV-85", "Great work!")
Linear::Commands.update_issue_state("ENG-85", "Done")
Linear::Commands.update_issue_description("MKT-85", "Updated description")
```


## Development

```bash
# Run locally
./bin/linear help

# Build gem
gem build linear-rb.gemspec

# Install locally
gem install linear-rb-0.1.0.gem
```

### Testing

The project includes both unit tests and integration tests:

```bash
# Run all tests (skips live API tests by default)
rspec

# Run tests with live API integration
LINEAR_API_KEY=your_key rspec

# Run only integration tests
rspec spec/integration/

# Run specific test file
rspec spec/linear/client_spec.rb
```

**Test Structure:**
- `spec/linear/` - Unit tests with mocked API responses
- `spec/integration/` - Integration tests for the CLI binary
  - Tests tagged with `:live` require a valid `LINEAR_API_KEY` and will make real API calls
  - Live tests display command output and intent rather than making assertions
  - Useful for verifying the CLI works end-to-end with real Linear data

## License

MIT
