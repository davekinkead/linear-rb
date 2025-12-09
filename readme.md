# linear-rb

A lightweight Ruby CLI wrapper for the Linear GraphQL API. Built for efficiency with zero external dependencies.

## Installation

### As a gem

```bash
gem install linear-rb
```

### Local development

```bash
# Clone and install locally
git clone https://github.com/davekinkead/linear-rb.git
cd linear-rb
gem build linear-rb.gemspec
gem install linear-rb-0.1.0.gem
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
linear comment FAT-85 "This looks good to me"
```

### Update issue state

```bash
# Move issue to a different state
linear update FAT-85 "Done"
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
Linear::Commands.add_comment("FAT-85", "Great work!")
Linear::Commands.update_issue_state("FAT-85", "Done")
Linear::Commands.update_issue_description("FAT-85", "Updated description")
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

## License

MIT
