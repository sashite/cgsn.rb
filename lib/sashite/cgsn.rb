# frozen_string_literal: true

require_relative "cgsn/status"

module Sashite
  # CGSN (Chess Game Status Notation) implementation for Ruby
  #
  # Provides functionality for working with rule-agnostic game status values
  # for abstract strategy board games.
  #
  # This implementation is strictly compliant with CGSN Specification v1.0.0
  # @see https://sashite.dev/specs/cgsn/1.0.0/ CGSN Specification v1.0.0
  module Cgsn
    # Complete list of all defined CGSN status values
    STATUSES = %w[
      in_progress
      checkmate
      stalemate
      staleturn
      bare_king
      mare_king
      insufficient
      resignation
      illegal_move
      time_limit
      move_limit
      repetition
      agreement
    ].freeze

    # Statuses that can be inferred from position analysis
    INFERABLE_STATUSES = %w[
      in_progress
      checkmate
      stalemate
      staleturn
      bare_king
      mare_king
      insufficient
    ].freeze

    # Statuses that require explicit declaration
    EXPLICIT_ONLY_STATUSES = %w[
      resignation
      illegal_move
      time_limit
      move_limit
      repetition
      agreement
    ].freeze

    # Check if a string is a valid CGSN status value
    #
    # @param value [String] the status to validate
    # @return [Boolean] true if the status is valid
    #
    # @example
    #   Sashite::Cgsn.valid?("checkmate")     # => true
    #   Sashite::Cgsn.valid?("staleturn")     # => true
    #   Sashite::Cgsn.valid?("time_limit")    # => true
    #   Sashite::Cgsn.valid?("invalid")       # => false
    #   Sashite::Cgsn.valid?("Checkmate")     # => false
    #   Sashite::Cgsn.valid?(:checkmate)      # => true (converts to "checkmate")
    def self.valid?(value)
      status_string = String(value)
      STATUSES.include?(status_string)
    rescue ::TypeError
      false
    end

    # Parse a status value into a Status object
    #
    # @param value [String] the status value to parse
    # @return [Status] new status instance
    # @raise [ArgumentError] if the status value is invalid
    #
    # @example
    #   Sashite::Cgsn.parse("checkmate")    # => #<Cgsn::Status value="checkmate">
    #   Sashite::Cgsn.parse("staleturn")    # => #<Cgsn::Status value="staleturn">
    #   Sashite::Cgsn.parse("resignation")  # => #<Cgsn::Status value="resignation">
    def self.parse(value)
      Status.new(value)
    end

    # Check if a status can be inferred from position analysis
    #
    # @param status [String, Status] the status to check
    # @return [Boolean] true if the status is inferable
    #
    # @example
    #   Sashite::Cgsn.inferable?("checkmate")     # => true
    #   Sashite::Cgsn.inferable?("staleturn")     # => true
    #   Sashite::Cgsn.inferable?("resignation")   # => false
    def self.inferable?(status)
      status_string = String(status)
      INFERABLE_STATUSES.include?(status_string)
    rescue ::TypeError
      false
    end

    # Check if a status requires explicit declaration
    #
    # @param status [String, Status] the status to check
    # @return [Boolean] true if the status is explicit-only
    #
    # @example
    #   Sashite::Cgsn.explicit_only?("resignation")  # => true
    #   Sashite::Cgsn.explicit_only?("checkmate")    # => false
    #   Sashite::Cgsn.explicit_only?("staleturn")    # => false
    def self.explicit_only?(status)
      status_string = String(status)
      EXPLICIT_ONLY_STATUSES.include?(status_string)
    rescue ::TypeError
      false
    end

    # Get the list of all defined CGSN status values
    #
    # @return [Array<String>] array of all status values
    #
    # @example
    #   Sashite::Cgsn.statuses
    #   # => ["in_progress", "checkmate", "stalemate", "staleturn", ...]
    def self.statuses
      STATUSES.dup
    end

    # Get the list of inferable status values
    #
    # @return [Array<String>] array of inferable status values
    #
    # @example
    #   Sashite::Cgsn.inferable_statuses
    #   # => ["in_progress", "checkmate", "stalemate", "staleturn", ...]
    def self.inferable_statuses
      INFERABLE_STATUSES.dup
    end

    # Get the list of explicit-only status values
    #
    # @return [Array<String>] array of explicit-only status values
    #
    # @example
    #   Sashite::Cgsn.explicit_only_statuses
    #   # => ["resignation", "illegal_move", "time_limit", ...]
    def self.explicit_only_statuses
      EXPLICIT_ONLY_STATUSES.dup
    end
  end
end
