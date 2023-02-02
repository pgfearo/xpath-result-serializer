
# Change Log
All notable changes to this project will be documented in this file.
 
## [Unreleased] - yyyy-mm-dd

<!-- ### Added
   
### Changed
 
### Fixed -->
 
## [0.1.0] 2 February 2023
 
### Added

- Baseline Release `src` directory
    - Serialization for all XPath 3.1 types
        - Supports nested maps, arrays and sequences
    - Colorisation for types using ANSI codes for terminal output
    - Bracket-pair colorisation
    - Multi-line Formatting for nested maps, arrays and sequences
    - Representation of nodes adapts for cases where there is no context document
    - Abbreviated form of element content shown in following priority:
      1. Justified, normalised text node serialisation
      2. (`@name`, `@class`, `@id`, `@*`)[1] attribute
    - Colorisation auto-disabled for Saxon versions later than 9.9.0.1
        - (required for command-line usage as text MessageEmitter no longer supported)
- XSLT sample directory
- XSLT test directory (manual testing)
- README documentation

