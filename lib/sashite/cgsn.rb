# frozen_string_literal: true

module Sashite
  # CGSN (Chess Game Status Notation) vocabulary for Ruby.
  #
  # This module exposes the CGSN v1.0.0 standard status identifiers (as strings)
  # and helpers to validate / classify them.
  #
  # CGSN statuses are categorized as either:
  #
  # - *position-inferable*: can be determined from Position + Rule System,
  # - *explicit-only*: require extra context (history, clocks, declarations, etc.).
  #
  # This implementation is intentionally *rule-agnostic* and *does not compute*
  # game statuses. It only provides a stable vocabulary and membership checks.
  #
  # Specification:
  # https://sashite.dev/specs/cgsn/1.0.0/
  #
  # @note Some statuses (e.g. +check+, +stalemate+) are defined *per Terminal Piece* in the spec.
  #   Associating such a status with a specific piece belongs to the surrounding protocol / notation.
  #
  # @note While the spec allows extensions, this module validates only the *standard v1.0.0 vocabulary*.
  #
  # @example Validation
  #   Sashite::Cgsn.valid?("checkmate")  # => true
  #   Sashite::Cgsn.valid?("invalid")    # => false
  #
  # @example Classification
  #   Sashite::Cgsn.inferable?("checkmate")       # => true
  #   Sashite::Cgsn.explicit_only?("resignation") # => true
  #
  # @see https://sashite.dev/specs/cgsn/1.0.0/ CGSN Specification
  # @see https://sashite.dev/game-protocol/ Game Protocol
  # @see https://sashite.dev/glossary/ Glossary
  module Cgsn
    # Position-inferable status identifiers.
    #
    # "Position-inferable" means: given the current Position and the Rule System,
    # the status can be determined without external context (history, clocks, declarations, etc.).
    #
    # @return [Array<String>] frozen array of inferable status identifiers
    INFERABLE_STATUSES = %w[
      check
      stale
      checkmate
      stalemate
      nomove
      bareking
      mareking
      insufficient
    ].freeze

    # Explicit-only status identifiers.
    #
    # "Explicit-only" means: the status cannot be derived from Position + Rule System alone
    # because it requires external context (history, clocks, declarations, etc.).
    #
    # @return [Array<String>] frozen array of explicit-only status identifiers
    EXPLICIT_ONLY_STATUSES = %w[
      resignation
      illegalmove
      timelimit
      movelimit
      repetition
      agreement
    ].freeze

    # All CGSN v1.0.0 status identifiers.
    #
    # @return [Array<String>] frozen array of all status identifiers
    STATUSES = (INFERABLE_STATUSES + EXPLICIT_ONLY_STATUSES).freeze

    # Fast membership lookup sets (private implementation detail).
    INFERABLE_SET = INFERABLE_STATUSES.to_set.freeze
    EXPLICIT_ONLY_SET = EXPLICIT_ONLY_STATUSES.to_set.freeze
    STATUS_SET = STATUSES.to_set.freeze

    private_constant :INFERABLE_SET, :EXPLICIT_ONLY_SET, :STATUS_SET

    # Returns all CGSN v1.0.0 status identifiers.
    #
    # The returned array has a stable order.
    #
    # @return [Array<String>] all status identifiers
    #
    # @example
    #   Sashite::Cgsn.statuses
    #   # => ["check", "stale", "checkmate", "stalemate", "nomove", "bareking", "mareking", "insufficient",
    #   #     "resignation", "illegalmove", "timelimit", "movelimit", "repetition", "agreement"]
    def self.statuses
      STATUSES
    end

    # Returns all position-inferable CGSN v1.0.0 status identifiers.
    #
    # "Position-inferable" means: given the current Position and the Rule System,
    # the status can be determined without external context (history, clocks, declarations, etc.).
    #
    # @return [Array<String>] inferable status identifiers
    #
    # @example
    #   Sashite::Cgsn.inferable_statuses
    #   # => ["check", "stale", "checkmate", "stalemate", "nomove", "bareking", "mareking", "insufficient"]
    def self.inferable_statuses
      INFERABLE_STATUSES
    end

    # Returns all explicit-only CGSN v1.0.0 status identifiers.
    #
    # "Explicit-only" means: the status cannot be derived from Position + Rule System alone
    # because it requires external context (history, clocks, declarations, etc.).
    #
    # @return [Array<String>] explicit-only status identifiers
    #
    # @example
    #   Sashite::Cgsn.explicit_only_statuses
    #   # => ["resignation", "illegalmove", "timelimit", "movelimit", "repetition", "agreement"]
    def self.explicit_only_statuses
      EXPLICIT_ONLY_STATUSES
    end

    # Checks whether the given value is a standard CGSN v1.0.0 status identifier.
    #
    # This method is intentionally strict: it validates membership in the official
    # CGSN v1.0.0 vocabulary. It does *not* validate or accept non-standard extensions.
    #
    # @param status [Object] the value to check
    # @return [Boolean] true if the value is a valid CGSN status identifier
    #
    # @example
    #   Sashite::Cgsn.valid?("checkmate")   # => true
    #   Sashite::Cgsn.valid?("resignation") # => true
    #   Sashite::Cgsn.valid?("invalid")     # => false
    #   Sashite::Cgsn.valid?("")            # => false
    #   Sashite::Cgsn.valid?(nil)           # => false
    #   Sashite::Cgsn.valid?(123)           # => false
    def self.valid?(status)
      return false unless status.is_a?(::String)

      STATUS_SET.include?(status)
    end

    # Checks whether the given status is position-inferable in CGSN v1.0.0.
    #
    # @param status [Object] the value to check
    # @return [Boolean] true if the status is position-inferable, false otherwise
    #
    # @note Returns false for non-String inputs and unknown identifiers.
    #
    # @example
    #   Sashite::Cgsn.inferable?("checkmate")   # => true
    #   Sashite::Cgsn.inferable?("stalemate")   # => true
    #   Sashite::Cgsn.inferable?("repetition")  # => false
    #   Sashite::Cgsn.inferable?("invalid")     # => false
    def self.inferable?(status)
      return false unless status.is_a?(::String)

      INFERABLE_SET.include?(status)
    end

    # Checks whether the given status is explicit-only in CGSN v1.0.0.
    #
    # @param status [Object] the value to check
    # @return [Boolean] true if the status is explicit-only, false otherwise
    #
    # @note Returns false for non-String inputs and unknown identifiers.
    #
    # @example
    #   Sashite::Cgsn.explicit_only?("resignation") # => true
    #   Sashite::Cgsn.explicit_only?("timelimit")   # => true
    #   Sashite::Cgsn.explicit_only?("checkmate")   # => false
    #   Sashite::Cgsn.explicit_only?("invalid")     # => false
    def self.explicit_only?(status)
      return false unless status.is_a?(::String)

      EXPLICIT_ONLY_SET.include?(status)
    end
  end
end
