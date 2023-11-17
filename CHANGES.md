# Change log!

## [Unreleased]

## [2.2.0] - 2019-06-09

### Fixed
- Dynamic type checking of initialize method
- Bug with handling constants of certain types
- Broken rdl_attr_* methods
- Bug handling optional annotated/dependent types
- Add RDLAnnotate to rdl_disable
- Type checking of Object class singleton methods
- #52 Kernel.raise annotation
- #42 use grandparent type information for methods
- #43 allow fully qualified calls
- #45 handle local constants
- #62 allow more method names in structural types
- #34 clean up discussion of how type checking works in README
- Reordered list of RDL.* methods in README
- Remove (most) ordering dependencies among test cases
- Undefined identified issue for Rails assocation types
- Type check expressions within casts
- Fix to `var_type` method when called from outside class
- Add `RDL.query` support for nested classes, e.g., `RDL.query "ActiveRecord::Base#id`

### Added
- Support for type-level computations, including new annotations with
  type-level computations for Array, Hash, String, Integer, Float, and
  database query libraries
- Dynamic type
- `RDL.reset` method

## [2.1.0] - 2017-06-14

### Fixed
- Type checking bug in const expressions when env[:self] is SingletonType
- Type for unary minus in numeric type files (changed :- to :-@)
- Type checking initialize method bugs
- Type checking of Module methods
- Type checking method when class name is included in type annotation
- Dynamic type checks after calls to instantiate!
- Ruby 2.4 compatibility!
- Various core and standard library types
- Parsing bug with `or`
- Sub-classes not wrapped bug
- Exception from case/when branch with empty body

### Added
- Support operator assignment when left-hand side has method args
- Support nested class names
- Type for unary plus in numeric type files
- Support for instantiate! for binding type parameters during static type checking
- New "check" flag for calls to instantiate! indicating whether we want to check type of receiving object on call
- More precise static type checking for `Object#class` method
- Klass argument to rdl_nowrap, rdl_alias
- Some more support for Rails
- Support for next/break in block arguments
- Support for super in static analysis

### Changed
- Global variables are now module variables of RDL::Globals
- at_exit handler only installed if `Config.report` or `.guess_types` are accessed
- Subclass Parser::Diagnostic instead of monkey patching it
- Replaced `Fixnum` with `Integer` in README (suggested by https://github.com/Dorian)
- All annotations removed from `Object` and added to `RDL::Annotate`
- `type_cast`, `instantiate!`, and `deinstantiate!` are now part of the `RDL` module to avoid adding them to `Object`

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
