# frozen_string_literal: true

module Sashite
  module Cgsn
    # Represents a status value in CGSN (Chess Game Status Notation) format.
    #
    # A status consists of a lowercase string with optional underscore separators.
    # Each status represents an observable game state that can be recorded
    # independently of competitive interpretation.
    #
    # All instances are immutable.
    class Status
      # Error message for invalid status values
      ERROR_INVALID_STATUS = "Invalid CGSN status: %s"

      # Create a new status instance
      #
      # @param value [String] status value
      # @raise [ArgumentError] if the value is invalid
      #
      # @example
      #   Status.new("checkmate")     # => #<Cgsn::Status value="checkmate">
      #   Status.new("resignation")   # => #<Cgsn::Status value="resignation">
      def initialize(value)
        @value = String(value)

        raise ::ArgumentError, format(ERROR_INVALID_STATUS, @value) unless Cgsn::STATUSES.include?(@value)

        freeze
      end

      # Check if the status can be inferred from position analysis
      #
      # @return [Boolean] true if inferable
      #
      # @example
      #   Status.new("checkmate").inferable?     # => true
      #   Status.new("resignation").inferable?   # => false
      def inferable?
        Cgsn::INFERABLE_STATUSES.include?(@value)
      end

      # Check if the status requires explicit declaration
      #
      # @return [Boolean] true if explicit-only
      #
      # @example
      #   Status.new("resignation").explicit_only?  # => true
      #   Status.new("checkmate").explicit_only?    # => false
      def explicit_only?
        Cgsn::EXPLICIT_ONLY_STATUSES.include?(@value)
      end

      # Convert the status to its string representation
      #
      # @return [String] status value
      #
      # @example
      #   Status.new("checkmate").to_s  # => "checkmate"
      def to_s
        @value
      end

      # Custom equality comparison
      #
      # @param other [Object] object to compare with
      # @return [Boolean] true if statuses are equal
      def ==(other)
        return false unless other.is_a?(self.class)

        to_s == other.to_s
      end

      # Alias for == to ensure Set functionality works correctly
      alias eql? ==

      # Custom hash implementation for use in collections
      #
      # @return [Integer] hash value
      def hash
        [self.class, @value].hash
      end
    end
  end
end
