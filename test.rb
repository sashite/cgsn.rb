#!/usr/bin/env ruby
# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Cgsn (Chess Game Status Notation)
#
# Tests the CGSN implementation for Ruby, covering validation,
# categorization, and specification compliance according to
# the CGSN Specification v1.0.0.
#
# @see https://sashite.dev/specs/cgsn/1.0.0/ CGSN Specification v1.0.0
#
# This test suite validates strict compliance with the official specification
# and includes all status values defined in the spec documentation.

require_relative "lib/sashite-cgsn"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Cgsn (Chess Game Status Notation)"
puts "Validating compliance with CGSN Specification v1.0.0"
puts "Specification: https://sashite.dev/specs/cgsn/1.0.0/"
puts

# ============================================================================
# SPECIFICATION COMPLIANCE TESTS
# ============================================================================

run_test("All specification status values are defined") do
  # Status values directly from CGSN Specification v1.0.0
  spec_statuses = %w[
    check
    stale
    checkmate
    stalemate
    nomove
    bareking
    mareking
    insufficient
    resignation
    illegalmove
    timelimit
    movelimit
    repetition
    agreement
  ]

  spec_statuses.each do |status|
    raise "Specification status '#{status}' should be valid but was rejected" unless Sashite::Cgsn.valid?(status)
  end

  # Verify no extra statuses
  cgsn_statuses = Sashite::Cgsn.statuses
  raise "Implementation has different status count than spec (expected #{spec_statuses.size}, got #{cgsn_statuses.size})" unless cgsn_statuses.size == spec_statuses.size

  spec_statuses.each do |status|
    raise "Specification status '#{status}' missing from implementation" unless cgsn_statuses.include?(status)
  end
end

run_test("Inferable statuses match specification") do
  # Inferable statuses from CGSN Specification v1.0.0
  spec_inferable = %w[
    check
    stale
    checkmate
    stalemate
    nomove
    bareking
    mareking
    insufficient
  ]

  spec_inferable.each do |status|
    raise "Specification inferable status '#{status}' should be inferable" unless Sashite::Cgsn.inferable?(status)
    raise "Specification inferable status '#{status}' should not be explicit-only" if Sashite::Cgsn.explicit_only?(status)
  end

  # Verify inferable list matches
  cgsn_inferable = Sashite::Cgsn.inferable_statuses
  raise "Inferable status count mismatch (expected #{spec_inferable.size}, got #{cgsn_inferable.size})" unless cgsn_inferable.size == spec_inferable.size

  spec_inferable.each do |status|
    raise "Inferable status '#{status}' missing from implementation" unless cgsn_inferable.include?(status)
  end
end

run_test("Explicit-only statuses match specification") do
  # Explicit-only statuses from CGSN Specification v1.0.0
  spec_explicit_only = %w[
    resignation
    illegalmove
    timelimit
    movelimit
    repetition
    agreement
  ]

  spec_explicit_only.each do |status|
    raise "Specification explicit-only status '#{status}' should be explicit-only" unless Sashite::Cgsn.explicit_only?(status)
    raise "Specification explicit-only status '#{status}' should not be inferable" if Sashite::Cgsn.inferable?(status)
  end

  # Verify explicit-only list matches
  cgsn_explicit_only = Sashite::Cgsn.explicit_only_statuses
  raise "Explicit-only status count mismatch (expected #{spec_explicit_only.size}, got #{cgsn_explicit_only.size})" unless cgsn_explicit_only.size == spec_explicit_only.size

  spec_explicit_only.each do |status|
    raise "Explicit-only status '#{status}' missing from implementation" unless cgsn_explicit_only.include?(status)
  end
end

run_test("Status format follows specification") do
  # CGSN format: lowercase alphabetic characters only
  valid_statuses = Sashite::Cgsn.statuses

  valid_statuses.each do |status|
    # Must be lowercase
    raise "Status '#{status}' contains uppercase characters" unless status == status.downcase

    # Must match pattern: lowercase letters only
    raise "Status '#{status}' contains non-alphabetic characters" unless status.match?(/\A[a-z]+\z/)
  end
end

# ============================================================================
# VALIDATION TESTS
# ============================================================================

run_test("Valid statuses are properly accepted") do
  valid_statuses = %w[
    check
    stale
    checkmate
    stalemate
    nomove
    bareking
    mareking
    insufficient
    resignation
    illegalmove
    timelimit
    movelimit
    repetition
    agreement
  ]

  valid_statuses.each do |status|
    raise "#{status.inspect} should be valid" unless Sashite::Cgsn.valid?(status)
  end
end

run_test("Invalid statuses are properly rejected") do
  invalid_statuses = [
    # Empty string
    "",

    # Wrong case
    "Checkmate", "CHECKMATE", "CheckMate",
    "TimeLimit", "TIME_LIMIT",

    # Invalid format
    "_checkmate", "checkmate_", "check__mate",
    "check-mate", "check mate", "check.mate",
    "check_mate",

    # Non-existent statuses
    "winning", "losing", "draw", "timeout",
    "forfeit", "abandoned", "cancelled",

    # Numbers and special characters
    "123", "1", "0",
    "check1", "mate2"
  ]

  invalid_statuses.each do |status|
    raise "#{status.inspect} should be invalid" if Sashite::Cgsn.valid?(status)
  end
end

run_test("Non-string input is handled gracefully") do
  non_string_inputs = [
    nil,
    [],
    {},
    true,
    false,
    123,
    12.34,
    :checkmate,
    :invalid,
    Object.new
  ]

  non_string_inputs.each do |input|
    raise "#{input.inspect} should be invalid (non-string)" if Sashite::Cgsn.valid?(input)
    raise "#{input.inspect} should not be inferable (non-string)" if Sashite::Cgsn.inferable?(input)
    raise "#{input.inspect} should not be explicit-only (non-string)" if Sashite::Cgsn.explicit_only?(input)
  end
end

# ============================================================================
# STATUS CATEGORIZATION TESTS
# ============================================================================

run_test("Inferable status categorization is accurate") do
  inferable_statuses = %w[
    check
    stale
    checkmate
    stalemate
    nomove
    bareking
    mareking
    insufficient
  ]

  inferable_statuses.each do |status|
    raise "#{status.inspect} should be inferable" unless Sashite::Cgsn.inferable?(status)
    raise "#{status.inspect} should not be explicit-only" if Sashite::Cgsn.explicit_only?(status)
  end
end

run_test("Explicit-only status categorization is accurate") do
  explicit_only_statuses = %w[
    resignation
    illegalmove
    timelimit
    movelimit
    repetition
    agreement
  ]

  explicit_only_statuses.each do |status|
    raise "#{status.inspect} should be explicit-only" unless Sashite::Cgsn.explicit_only?(status)
    raise "#{status.inspect} should not be inferable" if Sashite::Cgsn.inferable?(status)
  end
end

run_test("Every status is either inferable or explicit-only") do
  all_statuses = Sashite::Cgsn.statuses

  all_statuses.each do |status|
    is_inferable = Sashite::Cgsn.inferable?(status)
    is_explicit_only = Sashite::Cgsn.explicit_only?(status)

    # Exactly one should be true
    raise "Status '#{status}' is neither inferable nor explicit-only" unless is_inferable || is_explicit_only
    raise "Status '#{status}' is both inferable and explicit-only" if is_inferable && is_explicit_only
  end
end

run_test("Status lists are mutually exclusive and exhaustive") do
  inferable = Sashite::Cgsn.inferable_statuses
  explicit_only = Sashite::Cgsn.explicit_only_statuses

  # No overlap
  overlap = inferable & explicit_only
  raise "Inferable and explicit-only lists have overlap: #{overlap.inspect}" unless overlap.empty?

  # Together they should equal all statuses
  all_statuses = Sashite::Cgsn.statuses
  combined = (inferable + explicit_only).sort
  raise "Combined lists don't match all statuses" unless combined == all_statuses.sort
end

run_test("Invalid statuses return false for categorization") do
  invalid_statuses = ["invalid", "unknown", "", "CHECKMATE"]

  invalid_statuses.each do |status|
    raise "Invalid status '#{status}' should not be inferable" if Sashite::Cgsn.inferable?(status)
    raise "Invalid status '#{status}' should not be explicit-only" if Sashite::Cgsn.explicit_only?(status)
  end
end

# ============================================================================
# MODULE METHOD TESTS
# ============================================================================

run_test("Module statuses method returns all statuses") do
  statuses = Sashite::Cgsn.statuses

  raise "statuses should return an array" unless statuses.is_a?(Array)
  raise "statuses should return 14 values" unless statuses.size == 14

  # Should include all expected statuses
  expected = %w[
    check stale checkmate stalemate nomove bareking mareking insufficient
    resignation illegalmove timelimit movelimit repetition agreement
  ]

  expected.each do |status|
    raise "statuses should include '#{status}'" unless statuses.include?(status)
  end
end

run_test("Module inferable_statuses method returns correct list") do
  inferable = Sashite::Cgsn.inferable_statuses

  raise "inferable_statuses should return an array" unless inferable.is_a?(Array)
  raise "inferable_statuses should return 8 values" unless inferable.size == 8

  expected = %w[check stale checkmate stalemate nomove bareking mareking insufficient]

  expected.each do |status|
    raise "inferable_statuses should include '#{status}'" unless inferable.include?(status)
  end
end

run_test("Module explicit_only_statuses method returns correct list") do
  explicit_only = Sashite::Cgsn.explicit_only_statuses

  raise "explicit_only_statuses should return an array" unless explicit_only.is_a?(Array)
  raise "explicit_only_statuses should return 6 values" unless explicit_only.size == 6

  expected = %w[resignation illegalmove timelimit movelimit repetition agreement]

  expected.each do |status|
    raise "explicit_only_statuses should include '#{status}'" unless explicit_only.include?(status)
  end
end

run_test("Module methods return frozen constants") do
  statuses = Sashite::Cgsn.statuses
  inferable = Sashite::Cgsn.inferable_statuses
  explicit_only = Sashite::Cgsn.explicit_only_statuses

  raise "statuses should be frozen" unless statuses.frozen?
  raise "inferable_statuses should be frozen" unless inferable.frozen?
  raise "explicit_only_statuses should be frozen" unless explicit_only.frozen?

  # Test that same object is returned (not a copy)
  raise "statuses should return same object" unless Sashite::Cgsn.statuses.equal?(statuses)
  raise "inferable_statuses should return same object" unless Sashite::Cgsn.inferable_statuses.equal?(inferable)
  raise "explicit_only_statuses should return same object" unless Sashite::Cgsn.explicit_only_statuses.equal?(explicit_only)
end

# ============================================================================
# CONSTANT TESTS
# ============================================================================

run_test("STATUSES constant is properly defined") do
  statuses = Sashite::Cgsn::STATUSES

  raise "STATUSES should be frozen" unless statuses.frozen?
  raise "STATUSES should be an array" unless statuses.is_a?(Array)
  raise "STATUSES should have 14 elements" unless statuses.size == 14

  # All elements should be frozen strings
  statuses.each do |status|
    raise "Status '#{status}' should be frozen" unless status.frozen?
    raise "Status '#{status}' should be a string" unless status.is_a?(String)
  end
end

run_test("INFERABLE_STATUSES constant is properly defined") do
  inferable = Sashite::Cgsn::INFERABLE_STATUSES

  raise "INFERABLE_STATUSES should be frozen" unless inferable.frozen?
  raise "INFERABLE_STATUSES should be an array" unless inferable.is_a?(Array)
  raise "INFERABLE_STATUSES should have 8 elements" unless inferable.size == 8

  # All elements should be frozen strings
  inferable.each do |status|
    raise "Status '#{status}' should be frozen" unless status.frozen?
    raise "Status '#{status}' should be a string" unless status.is_a?(String)
  end
end

run_test("EXPLICIT_ONLY_STATUSES constant is properly defined") do
  explicit_only = Sashite::Cgsn::EXPLICIT_ONLY_STATUSES

  raise "EXPLICIT_ONLY_STATUSES should be frozen" unless explicit_only.frozen?
  raise "EXPLICIT_ONLY_STATUSES should be an array" unless explicit_only.is_a?(Array)
  raise "EXPLICIT_ONLY_STATUSES should have 6 elements" unless explicit_only.size == 6

  # All elements should be frozen strings
  explicit_only.each do |status|
    raise "Status '#{status}' should be frozen" unless status.frozen?
    raise "Status '#{status}' should be a string" unless status.is_a?(String)
  end
end

run_test("Constants maintain specification order") do
  # Order should match specification's complete status list
  expected_order = %w[
    check stale checkmate stalemate nomove bareking mareking insufficient
    resignation illegalmove timelimit movelimit repetition agreement
  ]

  actual_order = Sashite::Cgsn::STATUSES

  raise "STATUSES order should match specification" unless actual_order == expected_order

  # Inferable order
  expected_inferable_order = %w[check stale checkmate stalemate nomove bareking mareking insufficient]
  raise "INFERABLE_STATUSES order should match specification" unless Sashite::Cgsn::INFERABLE_STATUSES == expected_inferable_order

  # Explicit-only order
  expected_explicit_order = %w[resignation illegalmove timelimit movelimit repetition agreement]
  raise "EXPLICIT_ONLY_STATUSES order should match specification" unless Sashite::Cgsn::EXPLICIT_ONLY_STATUSES == expected_explicit_order
end

# ============================================================================
# GAME-SPECIFIC SEMANTIC TESTS
# ============================================================================

run_test("Terminal Piece statuses are inferable") do
  terminal_piece_statuses = %w[check stale checkmate stalemate]

  terminal_piece_statuses.each do |status|
    raise "Terminal Piece status '#{status}' should be inferable" unless Sashite::Cgsn.inferable?(status)
  end
end

run_test("Position statuses are inferable") do
  position_statuses = %w[nomove bareking mareking insufficient]

  position_statuses.each do |status|
    raise "Position status '#{status}' should be inferable" unless Sashite::Cgsn.inferable?(status)
  end
end

run_test("External event statuses are explicit-only") do
  external_event_statuses = %w[resignation illegalmove timelimit movelimit repetition agreement]

  external_event_statuses.each do |status|
    raise "External event status '#{status}' should be explicit-only" unless Sashite::Cgsn.explicit_only?(status)
  end
end

# ============================================================================
# CROSS-GAME APPLICABILITY TESTS
# ============================================================================

run_test("Statuses are rule-agnostic") do
  # Test that status names don't imply specific game rules
  all_statuses = Sashite::Cgsn.statuses

  all_statuses.each do |status|
    # No game-specific terms
    game_specific_terms = %w[chess shogi xiangqi western japanese chinese]
    game_specific_terms.each do |term|
      raise "Status '#{status}' contains game-specific term '#{term}'" if status.include?(term)
    end

    # No outcome terms
    outcome_terms = %w[win lose draw victory defeat]
    outcome_terms.each do |term|
      raise "Status '#{status}' contains outcome term '#{term}'" if status.include?(term)
    end
  end
end

# ============================================================================
# API CONSISTENCY TESTS
# ============================================================================

run_test("API methods are stateless and consistent") do
  test_cases = [
    { status: "checkmate", valid: true, inferable: true, explicit_only: false },
    { status: "resignation", valid: true, inferable: false, explicit_only: true },
    { status: "check", valid: true, inferable: true, explicit_only: false },
    { status: "invalid", valid: false, inferable: false, explicit_only: false }
  ]

  # Test that repeated calls give consistent results
  5.times do
    test_cases.each do |test_case|
      status = test_case[:status]
      raise "valid?(#{status}) should be consistent" unless Sashite::Cgsn.valid?(status) == test_case[:valid]
      raise "inferable?(#{status}) should be consistent" unless Sashite::Cgsn.inferable?(status) == test_case[:inferable]
      raise "explicit_only?(#{status}) should be consistent" unless Sashite::Cgsn.explicit_only?(status) == test_case[:explicit_only]
    end
  end
end

run_test("check and stale are mutually exclusive by definition") do
  # According to the spec: for any Terminal Piece, exactly one of {check, stale} applies
  # Both should be valid and inferable
  raise "check should be valid" unless Sashite::Cgsn.valid?("check")
  raise "stale should be valid" unless Sashite::Cgsn.valid?("stale")
  raise "check should be inferable" unless Sashite::Cgsn.inferable?("check")
  raise "stale should be inferable" unless Sashite::Cgsn.inferable?("stale")
end

run_test("checkmate implies check, stalemate implies stale") do
  # According to the spec:
  # - checkmate: Terminal Piece is in check and cannot escape
  # - stalemate: Terminal Piece is stale but all moves lead to check
  raise "checkmate should be inferable" unless Sashite::Cgsn.inferable?("checkmate")
  raise "stalemate should be inferable" unless Sashite::Cgsn.inferable?("stalemate")
  raise "check should be inferable" unless Sashite::Cgsn.inferable?("check")
  raise "stale should be inferable" unless Sashite::Cgsn.inferable?("stale")
end

# ============================================================================
# SPECIFICATION COMPLIANCE VERIFICATION
# ============================================================================

run_test("All specification constraints are enforced") do
  puts "\n    Verifying specification constraints..."

  # Lowercase requirement
  Sashite::Cgsn.statuses.each do |status|
    raise "Status '#{status}' must be lowercase" unless status == status.downcase
  end

  # Only lowercase letters (no underscores, hyphens, numbers)
  Sashite::Cgsn.statuses.each do |status|
    raise "Status '#{status}' contains invalid characters" unless status.match?(/\A[a-z]+\z/)
  end

  # At least one letter
  Sashite::Cgsn.statuses.each do |status|
    raise "Status '#{status}' must contain at least one letter" unless status.match?(/[a-z]/)
  end

  puts "    ✓ All specification constraints verified"
end

puts
puts "All CGSN tests passed!"
puts
