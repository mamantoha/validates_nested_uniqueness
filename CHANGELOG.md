# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-11-13

### Added
- **New `:comparison` option** for custom value normalization logic
- Enhanced input validation with better error messages
- Required `:attribute` parameter validation
- Comprehensive edge case handling
- Extensive test coverage for edge cases

### Changed
- Refactored validator logic into smaller, focused methods
- Improved code organization and maintainability
- Enhanced documentation with more examples
- Better nil and empty value handling
- More robust error handling throughout

### Fixed
- Safer method calls with proper existence checks
- Better handling of non-string values with case sensitivity

## [1.2.0] - 2024-11-13
### Added
- Updated minimal supported versions (Ruby >= 3.2.0, ActiveModel >= 7.2.0)
- Support for Rails 8.0 and 8.1
- Enhanced Ruby 3.4 support

### Changed
- Updated CI workflow to test with latest Rails versions

## [1.1.1] - 2024-11-13
### Fixed
- Added missing `require 'logger'` statement

## [1.1.0] - 2024-12-18
### Added
- Ruby 3.4 support
- Comprehensive test matrix for different Rails versions

## [1.0.0] - 2024-03-15
### Added
- Initial stable release
- Core nested uniqueness validation functionality
- Support for `:attribute`, `:scope`, `:case_sensitive`, `:message`, `:error_key` options
- Support for Rails 6.1+ and Ruby 2.7+
