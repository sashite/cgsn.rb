# Cgsn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/cgsn.rb?label=Version&logo=github)](https://github.com/sashite/cgsn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/cgsn.rb/main)
![Ruby](https://github.com/sashite/cgsn.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/cgsn.rb?label=License&logo=github)](https://github.com/sashite/cgsn.rb/raw/main/LICENSE.md)

> **CGSN** (Chess Game Status Notation) implementation for the Ruby language.

## What is CGSN?

CGSN (Chess Game Status Notation) provides a **rule-agnostic** taxonomy of observable game status values for abstract strategy board games. CGSN defines standardized identifiers for terminal conditions, player actions, and game progression states that can be recorded independently of competitive interpretation.

This gem implements the [CGSN Specification v1.0.0](https://sashite.dev/specs/cgsn/1.0.0/), providing a minimal Ruby interface for status validation and categorization with immutable status objects.

## Installation

```ruby
# In your Gemfile
gem "sashite-cgsn"
```

Or install manually:

```sh
gem install sashite-cgsn
```

## Format

CGSN status values are lowercase strings using underscore separators:

```ruby
"checkmate"
"bareking"
"timelimit"
"stale"
```

## API Reference

### Status Class

#### Creation and Parsing

* `Sashite::Cgsn::Status.new(value)` - Create status instance from string
* `Sashite::Cgsn.parse(value)` - Parse status value (module convenience method)

#### Instance Methods

* `#inferable?` - Check if status can be inferred from position analysis
* `#explicit_only?` - Check if status requires explicit declaration
* `#to_s` - Convert to string representation
* `#==(other)` - Equality comparison
* `#hash` - Hash value for use in collections

### Module Methods

#### Validation

* `Sashite::Cgsn.valid?(status)` - Check if string is a valid CGSN status value

#### Categorization

* `Sashite::Cgsn.inferable?(status)` - Check if status can be inferred from position analysis
* `Sashite::Cgsn.explicit_only?(status)` - Check if status requires explicit declaration

#### Status Lists

* `Sashite::Cgsn.statuses` - Array of all defined CGSN status values
* `Sashite::Cgsn.inferable_statuses` - Array of position-derivable statuses
* `Sashite::Cgsn.explicit_only_statuses` - Array of statuses requiring explicit recording

### Constants

* `Sashite::Cgsn::STATUSES` - Frozen array of all defined status values
* `Sashite::Cgsn::INFERABLE_STATUSES` - Frozen array of inferable status values
* `Sashite::Cgsn::EXPLICIT_ONLY_STATUSES` - Frozen array of explicit-only status values

## Usage

### Object-Oriented Approach

```ruby
require "sashite/cgsn"

# Parse status into object
status = Sashite::Cgsn.parse("checkmate")
status.inferable?      # => true
status.explicit_only?  # => false
status.to_s            # => "checkmate"

# Create from string
status = Sashite::Cgsn::Status.new("resignation")
status.inferable?      # => false
status.explicit_only?  # => true

# Immutable objects
status.frozen? # => true
```

### Functional Approach

```ruby
require "sashite/cgsn"

# Validate status strings
Sashite::Cgsn.valid?("checkmate")      # => true
Sashite::Cgsn.valid?("invalid")        # => false

# Check inference capability
Sashite::Cgsn.inferable?("stalemate") # => true
Sashite::Cgsn.explicit_only?("timelimit") # => true

# Get all statuses
Sashite::Cgsn.statuses
# => ["stale", "checkmate", "stalemate", ...]
```

## Properties

* **Rule-agnostic**: Independent of specific game mechanics or outcome interpretation
* **Observable-focused**: Records verifiable facts without competitive judgment
* **Inference-aware**: Distinguishes position-derivable from explicit-only statuses
* **String-based**: Simple string representation for broad compatibility
* **Functional**: Pure functions with no side effects
* **Immutable**: All status instances and data structures are frozen
* **Object-oriented**: Status objects with query methods

## Related Specifications

- [CGSN](https://sashite.dev/specs/cgsn/) - Chess Game Status Notation (this specification)
- [PCN](https://sashite.dev/specs/pcn/) - Portable Chess Notation (uses CGSN for status field)
- [Game Protocol](https://sashite.dev/protocol/) - Conceptual foundation for abstract strategy games

## Documentation

- [Official CGSN Specification v1.0.0](https://sashite.dev/specs/cgsn/1.0.0/)
- [CGSN Examples](https://sashite.dev/specs/cgsn/1.0.0/examples/)
- [API Documentation](https://rubydoc.info/github/sashite/cgsn.rb/main)

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/cgsn.rb.git
cd cgsn.rb

# Install dependencies
bundle install

# Run tests
ruby test.rb

# Generate documentation
yard doc
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Add tests for your changes
4. Ensure all tests pass (`ruby test.rb`)
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/new-feature`)
7. Create a Pull Request

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
