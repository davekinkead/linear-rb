# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2024-12-23

### Added
- Support for updating issue titles via `--title` flag
- Support for updating issue descriptions via `--description` flag
- Ability to update multiple fields (state, title, description) in a single command

### Changed
- **BREAKING**: `update` command now requires explicit flags instead of positional arguments
  - Old syntax: `linear update ISSUE_ID "State"`
  - New syntax: `linear update ISSUE_ID --state "State"`
- Consolidated `update_issue_state` and `update_issue_description` into single `update_issue` method
- Updated help text with new flag-based syntax and examples

### Fixed
- Validation now ensures at least one field is provided to update command

## [0.2.0] - 2024-12-09

### Changed
- Consolidated `issues` and `search` commands into single `issues` command with optional filters
- Removed standalone `search` command

### Added
- `--query`, `--project`, `--state`, and `--team` flags for filtering issues
- Case-insensitive state matching for issue filters

## [0.1.1] - 2024-12-09

### Added
- `list_issues` command for filtering and listing issues
- `list_projects` command for viewing projects
- Comprehensive test coverage with RSpec

## [0.1.0] - 2024-12-09

### Added
- Initial release
- `issue` command to fetch specific issues by ID
- `mine` command to show assigned issues
- `teams` command to list all teams
- `comment` command to add comments to issues
- `update` command to change issue states
- GraphQL client with zero external dependencies
- Live integration tests
