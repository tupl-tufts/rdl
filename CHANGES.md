# Change log!

## [Unreleased]

## [2.0.1] - 2016-11-11

### Fixed
- Improved support for modules (still incomplete)
- Fix a bug with typing self.new
- Fix bug with annotated return types
- Fix bug with rdl_query
- Fix bug with running under Rails where type files don't exist (Joel Holdbrooks)

## [2.0.0] - 2016-08-24
### Added
- Static type checking!
- `wrap: false` optional argument to `type`, `pre`, and `post`
- Non-null type annotation (not checked)
- Default argument configuration for `type`, `pre`, and `post`
- `attr_*_type` methods
- Initial types for Rails

### Changed
- Modified `self` type to be any instance of the self's class
- Library types now use new aliases %integer and %numeric instead of the Integer and Numeric classes
- Instead of requiring `rdl_types.rb`, require `types/core`

### Fixed
- Fix issue #14 - allow type/pre/post to coexist, improve docs on dependent types
- Fix typos in README, pull req #13
- Fix bug where calling method overloaded sometimes with block and sometimes without would always report type error

## [1.1.1] - 2016-05-21
### Fixed
- Update code to eliminate Ruby 2.3 warning messages
- Fixed errors in post conditions of numeric types (incorrect number of args)
- Added syntax highlighting in README.md as pointed out by jsyeo
- Comprehensive changes to types of Numeric subclass methods to make types more specific & accurate
- Changed superclasses of numeric classes to be `Numeric`

### Added
- Higher-order types and tests for them
- Dependent types
- `/extras` directory, which contains random type tests for numeric subclass method types
- `BigDecimal` added to alias `%real`
- Changelog added!

## [1.1.0] - 2016-01-03
### Added
- Added much enhanced `rdl_query` facility and accompanying command-line script.

## [1.0.0] - 2015-12-18
- First release!
