# cgsn.rb

[![Version](https://img.shields.io/github/v/tag/sashite/cgsn.rb?label=Version&logo=github)](https://github.com/sashite/cgsn.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/cgsn.rb/main)
[![CI](https://github.com/sashite/cgsn.rb/actions/workflows/ruby.yml/badge.svg?branch=main)](https://github.com/sashite/cgsn.rb/actions)
[![License](https://img.shields.io/github/license/sashite/cgsn.rb)](https://github.com/sashite/cgsn.rb/blob/main/LICENSE)

> **CGSN** (Chess Game Status Notation) implementation for Ruby.

## Overview

This library implements the [CGSN Specification v1.0.0](https://sashite.dev/specs/cgsn/1.0.0/).

## Installation

```ruby
# In your Gemfile
gem "sashite-cgsn"
```

Or install manually:

```sh
gem install sashite-cgsn
```

## Usage

### Parsing (String → Symbol)

Convert a CGSN string into a symbol.

```ruby
require "sashite/cgsn"

# Standard parsing (raises on error)
Sashite::Cgsn.parse("checkmate")    # => :checkmate
Sashite::Cgsn.parse("resignation")  # => :resignation

# Invalid input raises ArgumentError
Sashite::Cgsn.parse("invalid")  # => raises ArgumentError
Sashite::Cgsn.parse("")         # => raises ArgumentError
```

### Validation

```ruby
# Boolean check
Sashite::Cgsn.valid?("checkmate")    # => true
Sashite::Cgsn.valid?("resignation")  # => true
Sashite::Cgsn.valid?("invalid")      # => false
Sashite::Cgsn.valid?("")             # => false
Sashite::Cgsn.valid?(nil)            # => false
```

### Classification

```ruby
# Position-inferable: can be determined from Position + Rule System
Sashite::Cgsn.inferable?(:checkmate)   # => true
Sashite::Cgsn.inferable?(:stalemate)   # => true
Sashite::Cgsn.inferable?(:repetition)  # => false

# Explicit-only: requires external context (history, clocks, declarations)
Sashite::Cgsn.explicit_only?(:resignation)  # => true
Sashite::Cgsn.explicit_only?(:timelimit)    # => true
Sashite::Cgsn.explicit_only?(:checkmate)    # => false
```

### Accessing Statuses

```ruby
# All statuses (unordered)
Sashite::Cgsn.statuses
# => #<Set: {:check, :stale, :checkmate, :stalemate, :nomove, :bareking,
#            :mareking, :insufficient, :resignation, :illegalmove, :timelimit,
#            :movelimit, :repetition, :agreement}>

# Position-inferable statuses
Sashite::Cgsn.inferable_statuses
# => #<Set: {:check, :stale, :checkmate, :stalemate, :nomove, :bareking,
#            :mareking, :insufficient}>

# Explicit-only statuses
Sashite::Cgsn.explicit_only_statuses
# => #<Set: {:resignation, :illegalmove, :timelimit, :movelimit, :repetition,
#            :agreement}>
```

## API Reference

### Constants

```ruby
Sashite::Cgsn::STATUSES               # Set of all 14 status symbols
Sashite::Cgsn::INFERABLE_STATUSES     # Set of 8 position-inferable symbols
Sashite::Cgsn::EXPLICIT_ONLY_STATUSES # Set of 6 explicit-only symbols
```

### Parsing

```ruby
# Parses a CGSN string into a symbol.
# Raises ArgumentError if the string is not valid.
#
# @param input [String] CGSN status string
# @return [Symbol]
# @raise [ArgumentError] if invalid
def Sashite::Cgsn.parse(input)
```

### Validation

```ruby
# Reports whether string is a valid CGSN status identifier.
#
# @param input [String] The value to check
# @return [Boolean]
def Sashite::Cgsn.valid?(input)
```

### Classification

```ruby
# Reports whether status is position-inferable.
#
# @param status [Symbol] The status to check
# @return [Boolean]
def Sashite::Cgsn.inferable?(status)

# Reports whether status is explicit-only.
#
# @param status [Symbol] The status to check
# @return [Boolean]
def Sashite::Cgsn.explicit_only?(status)
```

### Listing

```ruby
# Returns all CGSN v1.0.0 status symbols.
#
# @return [Set<Symbol>]
def Sashite::Cgsn.statuses

# Returns position-inferable status symbols.
#
# @return [Set<Symbol>]
def Sashite::Cgsn.inferable_statuses

# Returns explicit-only status symbols.
#
# @return [Set<Symbol>]
def Sashite::Cgsn.explicit_only_statuses
```

### Errors

All parsing errors raise `ArgumentError` with descriptive messages:

| Message | Cause |
|---------|-------|
| `"invalid status"` | Input is not a valid CGSN status |

## Design Principles

- **Symbol-based**: Statuses represented as Ruby symbols for identity semantics
- **Set-based**: Unordered collections reflect vocabulary nature
- **Strict validation**: Only standard v1.0.0 vocabulary accepted
- **Rule-agnostic**: Records conditions without defining outcomes
- **Immutable constants**: All sets are frozen
- **No dependencies**: Pure Ruby standard library only

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [CGSN Specification](https://sashite.dev/specs/cgsn/1.0.0/) — Official specification
- [CGSN Examples](https://sashite.dev/specs/cgsn/1.0.0/examples/) — Usage examples

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
