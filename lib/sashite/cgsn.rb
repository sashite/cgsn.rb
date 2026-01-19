# frozen_string_literal: true

require "set"

module Sashite
  # CGSN (Chess Game Status Notation) implementation for Ruby.
  #
  # Provides a rule-agnostic vocabulary for identifying game statuses
  # in abstract strategy board games with symbol-based identifiers.
  #
  # @example Parsing
  #   Sashite::Cgsn.parse("checkmate")  # => :checkmate
  #
  # @example Validation
  #   Sashite::Cgsn.valid?("checkmate")  # => true
  #   Sashite::Cgsn.valid?("invalid")    # => false
  #
  # @example Classification
  #   Sashite::Cgsn.inferable?(:checkmate)       # => true
  #   Sashite::Cgsn.explicit_only?(:resignation) # => true
  #
  # @see https://sashite.dev/specs/cgsn/1.0.0/
  module Cgsn
    # Position-inferable status symbols.
    #
    # These can be determined from Position + Rule System alone.
    #
    # @return [Set<Symbol>] frozen set of inferable status symbols
    INFERABLE_STATUSES = Set[
      :check,
      :stale,
      :checkmate,
      :stalemate,
      :nomove,
      :bareking,
      :mareking,
      :insufficient
    ].freeze

    # Explicit-only status symbols.
    #
    # These require external context (history, clocks, declarations).
    #
    # @return [Set<Symbol>] frozen set of explicit-only status symbols
    EXPLICIT_ONLY_STATUSES = Set[
      :resignation,
      :illegalmove,
      :timelimit,
      :movelimit,
      :repetition,
      :agreement
    ].freeze

    # All CGSN v1.0.0 status symbols.
    #
    # @return [Set<Symbol>] frozen set of all status symbols
    STATUSES = (INFERABLE_STATUSES | EXPLICIT_ONLY_STATUSES).freeze

    # Valid status strings for parsing (private implementation detail).
    VALID_STRINGS = STATUSES.map(&:to_s).to_set.freeze
    private_constant :VALID_STRINGS

    # Parses a CGSN string into a symbol.
    #
    # @param input [String] The CGSN status string to parse
    # @return [Symbol] The corresponding status symbol
    # @raise [ArgumentError] If the input is not a valid CGSN status
    #
    # @example
    #   Sashite::Cgsn.parse("checkmate")    # => :checkmate
    #   Sashite::Cgsn.parse("resignation")  # => :resignation
    #
    # @example Invalid input
    #   Sashite::Cgsn.parse("invalid")  # => raises ArgumentError
    #   Sashite::Cgsn.parse("")         # => raises ArgumentError
    def self.parse(input)
      raise ::ArgumentError, "invalid status" unless valid?(input)

      :"#{input}"
    end

    # Reports whether the input is a valid CGSN status string.
    #
    # @param input [Object] The value to check
    # @return [Boolean] true if valid, false otherwise
    #
    # @example
    #   Sashite::Cgsn.valid?("checkmate")    # => true
    #   Sashite::Cgsn.valid?("resignation")  # => true
    #   Sashite::Cgsn.valid?("invalid")      # => false
    #   Sashite::Cgsn.valid?("")             # => false
    #   Sashite::Cgsn.valid?(nil)            # => false
    def self.valid?(input)
      return false unless ::String === input

      VALID_STRINGS.include?(input)
    end

    # Reports whether the status is position-inferable.
    #
    # Position-inferable statuses can be determined from Position + Rule System
    # without external context (history, clocks, declarations).
    #
    # @param status [Symbol] The status to check
    # @return [Boolean] true if position-inferable, false otherwise
    #
    # @example
    #   Sashite::Cgsn.inferable?(:checkmate)   # => true
    #   Sashite::Cgsn.inferable?(:stalemate)   # => true
    #   Sashite::Cgsn.inferable?(:repetition)  # => false
    def self.inferable?(status)
      return false unless ::Symbol === status

      INFERABLE_STATUSES.include?(status)
    end

    # Reports whether the status is explicit-only.
    #
    # Explicit-only statuses require external context (history, clocks,
    # declarations) and cannot be derived from Position + Rule System alone.
    #
    # @param status [Symbol] The status to check
    # @return [Boolean] true if explicit-only, false otherwise
    #
    # @example
    #   Sashite::Cgsn.explicit_only?(:resignation)  # => true
    #   Sashite::Cgsn.explicit_only?(:timelimit)    # => true
    #   Sashite::Cgsn.explicit_only?(:checkmate)    # => false
    def self.explicit_only?(status)
      return false unless ::Symbol === status

      EXPLICIT_ONLY_STATUSES.include?(status)
    end

    # Returns all CGSN v1.0.0 status symbols.
    #
    # @return [Set<Symbol>] frozen set of all status symbols
    #
    # @example
    #   Sashite::Cgsn.statuses
    #   # => #<Set: {:check, :stale, :checkmate, ...}>
    def self.statuses
      STATUSES
    end

    # Returns position-inferable status symbols.
    #
    # @return [Set<Symbol>] frozen set of inferable status symbols
    #
    # @example
    #   Sashite::Cgsn.inferable_statuses
    #   # => #<Set: {:check, :stale, :checkmate, :stalemate, ...}>
    def self.inferable_statuses
      INFERABLE_STATUSES
    end

    # Returns explicit-only status symbols.
    #
    # @return [Set<Symbol>] frozen set of explicit-only status symbols
    #
    # @example
    #   Sashite::Cgsn.explicit_only_statuses
    #   # => #<Set: {:resignation, :illegalmove, :timelimit, ...}>
    def self.explicit_only_statuses
      EXPLICIT_ONLY_STATUSES
    end
  end
end
