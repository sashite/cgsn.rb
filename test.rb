#!/usr/bin/env ruby
# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Cgsn (Chess Game Status Notation)
#
# Tests the CGSN implementation for Ruby, covering validation,
# categorization, status objects, and specification compliance
# according to the CGSN Specification v1.0.0.
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
    in_progress
    checkmate
    stalemate
    bare_king
    mare_king
    insufficient
    resignation
    illegal_move
    time_limit
    move_limit
    repetition
    agreement
  ]

  spec_statuses.each do |status|
    raise "Specification status '#{status}' should be valid but was rejected" unless Sashite::Cgsn.valid?(status)
  end

  # Verify no extra statuses
  cgsn_statuses = Sashite::Cgsn.statuses
  raise "Implementation has different status count than spec" unless cgsn_statuses.size == spec_statuses.size

  spec_statuses.each do |status|
    raise "Specification status '#{status}' missing from implementation" unless cgsn_statuses.include?(status)
  end
end

run_test("Inferable statuses match specification") do
  # Inferable statuses from CGSN Specification v1.0.0
  spec_inferable = %w[
    in_progress
    checkmate
    stalemate
    bare_king
    mare_king
    insufficient
  ]

  spec_inferable.each do |status|
    raise "Specification inferable status '#{status}' should be inferable" unless Sashite::Cgsn.inferable?(status)
    raise "Specification inferable status '#{status}' should not be explicit-only" if Sashite::Cgsn.explicit_only?(status)
  end

  # Verify inferable list matches
  cgsn_inferable = Sashite::Cgsn.inferable_statuses
  raise "Inferable status count mismatch" unless cgsn_inferable.size == spec_inferable.size

  spec_inferable.each do |status|
    raise "Inferable status '#{status}' missing from implementation" unless cgsn_inferable.include?(status)
  end
end

run_test("Explicit-only statuses match specification") do
  # Explicit-only statuses from CGSN Specification v1.0.0
  spec_explicit_only = %w[
    resignation
    illegal_move
    time_limit
    move_limit
    repetition
    agreement
  ]

  spec_explicit_only.each do |status|
    raise "Specification explicit-only status '#{status}' should be explicit-only" unless Sashite::Cgsn.explicit_only?(status)
    raise "Specification explicit-only status '#{status}' should not be inferable" if Sashite::Cgsn.inferable?(status)
  end

  # Verify explicit-only list matches
  cgsn_explicit_only = Sashite::Cgsn.explicit_only_statuses
  raise "Explicit-only status count mismatch" unless cgsn_explicit_only.size == spec_explicit_only.size

  spec_explicit_only.each do |status|
    raise "Explicit-only status '#{status}' missing from implementation" unless cgsn_explicit_only.include?(status)
  end
end

run_test("Status format follows specification") do
  # CGSN format: lowercase with underscore separators
  valid_statuses = Sashite::Cgsn.statuses

  valid_statuses.each do |status|
    # Must be lowercase
    raise "Status '#{status}' contains uppercase characters" unless status == status.downcase

    # Must match pattern: [a-z]+(?:_[a-z]+)*
    pattern = /\A[a-z]+(?:_[a-z]+)*\z/
    raise "Status '#{status}' doesn't match format pattern" unless status.match?(pattern)

    # No leading/trailing underscores
    raise "Status '#{status}' has leading underscore" if status.start_with?("_")
    raise "Status '#{status}' has trailing underscore" if status.end_with?("_")

    # No consecutive underscores
    raise "Status '#{status}' has consecutive underscores" if status.include?("__")
  end
end

# ============================================================================
# VALIDATION TESTS
# ============================================================================

run_test("Valid statuses are properly accepted") do
  valid_statuses = %w[
    in_progress
    checkmate
    stalemate
    bare_king
    mare_king
    insufficient
    resignation
    illegal_move
    time_limit
    move_limit
    repetition
    agreement
  ]

  valid_statuses.each do |status|
    raise "#{status.inspect} should be valid" unless Sashite::Cgsn.valid?(status)
  end
end

run_test("Invalid statuses are properly rejected") do
  invalid_statuses = [
    # Empty and non-string
    "", nil,

    # Wrong case
    "Checkmate", "CHECKMATE", "CheckMate",
    "Time_Limit", "TIME_LIMIT",

    # Invalid format
    "_checkmate", "checkmate_", "check__mate",
    "check-mate", "check mate", "check.mate",

    # Non-existent statuses
    "winning", "losing", "draw", "timeout",
    "forfeit", "abandoned", "cancelled",

    # Numbers
    "123", "1", "0"
  ]

  invalid_statuses.each do |status|
    raise "#{status.inspect} should be invalid" if Sashite::Cgsn.valid?(status)
  end
end

run_test("Non-string input is handled gracefully") do
  non_strings = [nil, 123, :checkmate, [], {}, true, false]

  non_strings.each do |input|
    raise "#{input.inspect} should be invalid" if Sashite::Cgsn.valid?(input)
    raise "#{input.inspect} should not be inferable" if Sashite::Cgsn.inferable?(input)
    raise "#{input.inspect} should not be explicit-only" if Sashite::Cgsn.explicit_only?(input)
  end
end

# ============================================================================
# STATUS CATEGORIZATION TESTS
# ============================================================================

run_test("Inferable status categorization is accurate") do
  inferable_statuses = %w[
    in_progress
    checkmate
    stalemate
    bare_king
    mare_king
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
    illegal_move
    time_limit
    move_limit
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

run_test("Status lists are mutually exclusive") do
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

# ============================================================================
# STATUS OBJECT TESTS
# ============================================================================

run_test("Status.new creates correct instances") do
  test_statuses = %w[checkmate resignation stalemate time_limit]

  test_statuses.each do |status_value|
    status = Sashite::Cgsn::Status.new(status_value)

    raise "Status should be a Status instance" unless status.is_a?(Sashite::Cgsn::Status)
    raise "Status to_s should return original value" unless status.to_s == status_value
    raise "Status should be frozen" unless status.frozen?
  end
end

run_test("Status.new validates input") do
  invalid_values = ["invalid", "Checkmate", "", "check_mate_extra"]

  invalid_values.each do |value|
    begin
      Sashite::Cgsn::Status.new(value)
      raise "Should have raised ArgumentError for #{value.inspect}"
    rescue ArgumentError => e
      raise "Error message should mention invalid status" unless e.message.include?("Invalid CGSN status")
    end
  end
end

run_test("Cgsn.parse creates Status objects") do
  status = Sashite::Cgsn.parse("checkmate")

  raise "parse should return Status instance" unless status.is_a?(Sashite::Cgsn::Status)
  raise "Parsed status should have correct value" unless status.to_s == "checkmate"
end

run_test("Status#inferable? method works correctly") do
  inferable_status = Sashite::Cgsn::Status.new("checkmate")
  explicit_status = Sashite::Cgsn::Status.new("resignation")

  raise "Checkmate status should be inferable" unless inferable_status.inferable?
  raise "Checkmate status should not be explicit-only" if inferable_status.explicit_only?

  raise "Resignation status should not be inferable" if explicit_status.inferable?
  raise "Resignation status should be explicit-only" unless explicit_status.explicit_only?
end

run_test("Status#explicit_only? method works correctly") do
  inferable_status = Sashite::Cgsn::Status.new("stalemate")
  explicit_status = Sashite::Cgsn::Status.new("time_limit")

  raise "Stalemate status should not be explicit-only" if inferable_status.explicit_only?
  raise "Stalemate status should be inferable" unless inferable_status.inferable?

  raise "Time limit status should be explicit-only" unless explicit_status.explicit_only?
  raise "Time limit status should not be inferable" if explicit_status.inferable?
end

run_test("Status equality and hash") do
  status1 = Sashite::Cgsn::Status.new("checkmate")
  status2 = Sashite::Cgsn::Status.new("checkmate")
  status3 = Sashite::Cgsn::Status.new("stalemate")

  # Test equality
  raise "Identical statuses should be equal" unless status1 == status2
  raise "Different statuses should not be equal" if status1 == status3

  # Test eql?
  raise "Identical statuses should be eql?" unless status1.eql?(status2)
  raise "Different statuses should not be eql?" if status1.eql?(status3)

  # Test hash consistency
  raise "Equal statuses should have same hash" unless status1.hash == status2.hash

  # Test in Set
  require "set"
  statuses_set = Set.new([status1, status2, status3])
  raise "Set should contain 2 unique statuses" unless statuses_set.size == 2
end

run_test("Status immutability") do
  status = Sashite::Cgsn::Status.new("checkmate")

  # Test that status is frozen
  raise "Status should be frozen" unless status.frozen?

  # Test that to_s returns frozen string
  str = status.to_s
  raise "Status string representation should be frozen" unless str.frozen?
end

# ============================================================================
# MODULE METHOD TESTS
# ============================================================================

run_test("Module statuses method returns all statuses") do
  statuses = Sashite::Cgsn.statuses

  raise "statuses should return an array" unless statuses.is_a?(Array)
  raise "statuses should return 12 values" unless statuses.size == 12

  # Should include all expected statuses
  expected = %w[
    in_progress checkmate stalemate bare_king mare_king insufficient
    resignation illegal_move time_limit move_limit repetition agreement
  ]

  expected.each do |status|
    raise "statuses should include '#{status}'" unless statuses.include?(status)
  end
end

run_test("Module inferable_statuses method returns correct list") do
  inferable = Sashite::Cgsn.inferable_statuses

  raise "inferable_statuses should return an array" unless inferable.is_a?(Array)
  raise "inferable_statuses should return 6 values" unless inferable.size == 6

  expected = %w[in_progress checkmate stalemate bare_king mare_king insufficient]

  expected.each do |status|
    raise "inferable_statuses should include '#{status}'" unless inferable.include?(status)
  end
end

run_test("Module explicit_only_statuses method returns correct list") do
  explicit_only = Sashite::Cgsn.explicit_only_statuses

  raise "explicit_only_statuses should return an array" unless explicit_only.is_a?(Array)
  raise "explicit_only_statuses should return 6 values" unless explicit_only.size == 6

  expected = %w[resignation illegal_move time_limit move_limit repetition agreement]

  expected.each do |status|
    raise "explicit_only_statuses should include '#{status}'" unless explicit_only.include?(status)
  end
end

run_test("Module methods return copies, not originals") do
  statuses1 = Sashite::Cgsn.statuses
  statuses2 = Sashite::Cgsn.statuses

  raise "Multiple calls should return different array objects" if statuses1.equal?(statuses2)
  raise "Multiple calls should return equal arrays" unless statuses1 == statuses2

  # Test that modifying returned array doesn't affect constant
  statuses1 << "invalid"
  statuses3 = Sashite::Cgsn.statuses
  raise "Modifying returned array should not affect subsequent calls" if statuses3.include?("invalid")
end

# ============================================================================
# CONSTANT TESTS
# ============================================================================

run_test("STATUSES constant is properly defined") do
  statuses = Sashite::Cgsn::STATUSES

  raise "STATUSES should be frozen" unless statuses.frozen?
  raise "STATUSES should be an array" unless statuses.is_a?(Array)
  raise "STATUSES should have 12 elements" unless statuses.size == 12

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
  raise "INFERABLE_STATUSES should have 6 elements" unless inferable.size == 6

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

# ============================================================================
# GAME-SPECIFIC SEMANTIC TESTS
# ============================================================================

run_test("Terminal position statuses are inferable") do
  terminal_statuses = %w[checkmate stalemate bare_king mare_king insufficient]

  terminal_statuses.each do |status|
    raise "Terminal status '#{status}' should be inferable" unless Sashite::Cgsn.inferable?(status)
  end
end

run_test("Player action statuses are explicit-only") do
  player_action_statuses = %w[resignation agreement illegal_move]

  player_action_statuses.each do |status|
    raise "Player action '#{status}' should be explicit-only" unless Sashite::Cgsn.explicit_only?(status)
  end
end

run_test("Temporal constraint statuses are explicit-only") do
  temporal_statuses = %w[time_limit move_limit repetition]

  temporal_statuses.each do |status|
    raise "Temporal constraint '#{status}' should be explicit-only" unless Sashite::Cgsn.explicit_only?(status)
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

run_test("Status objects work across game contexts") do
  # Same status value can be used for different games
  checkmate_chess = Sashite::Cgsn::Status.new("checkmate")
  checkmate_shogi = Sashite::Cgsn::Status.new("checkmate")
  checkmate_xiangqi = Sashite::Cgsn::Status.new("checkmate")

  raise "Same status across games should be equal" unless checkmate_chess == checkmate_shogi
  raise "Same status across games should be equal" unless checkmate_shogi == checkmate_xiangqi

  # Different contexts, same observable fact
  bare_king_shatranj = Sashite::Cgsn::Status.new("bare_king")
  bare_king_western = Sashite::Cgsn::Status.new("bare_king")

  raise "Same observable fact should use same status" unless bare_king_shatranj == bare_king_western
end

# ============================================================================
# EDGE CASES AND BOUNDARY CONDITIONS
# ============================================================================

run_test("Status with underscores are handled correctly") do
  multi_word_statuses = %w[bare_king mare_king illegal_move time_limit move_limit in_progress]

  multi_word_statuses.each do |status|
    raise "Multi-word status '#{status}' should be valid" unless Sashite::Cgsn.valid?(status)

    # Can create Status object
    status_obj = Sashite::Cgsn::Status.new(status)
    raise "Multi-word status should create valid object" unless status_obj.to_s == status
  end
end

run_test("Single-word statuses are handled correctly") do
  single_word_statuses = %w[checkmate stalemate insufficient resignation repetition agreement]

  single_word_statuses.each do |status|
    raise "Single-word status '#{status}' should be valid" unless Sashite::Cgsn.valid?(status)

    # Can create Status object
    status_obj = Sashite::Cgsn::Status.new(status)
    raise "Single-word status should create valid object" unless status_obj.to_s == status
  end
end

run_test("API methods are stateless and consistent") do
  test_status = "checkmate"

  # Test that repeated calls give consistent results
  5.times do
    raise "valid? should be consistent" unless Sashite::Cgsn.valid?(test_status) == true
    raise "inferable? should be consistent" unless Sashite::Cgsn.inferable?(test_status) == true
    raise "explicit_only? should be consistent" unless Sashite::Cgsn.explicit_only?(test_status) == false
  end

  5.times do
    status_obj = Sashite::Cgsn.parse(test_status)
    raise "parse should be consistent" unless status_obj.to_s == test_status
  end
end

run_test("Status comparison with strings") do
  status = Sashite::Cgsn::Status.new("checkmate")

  # Status object should not equal string directly
  raise "Status object should not equal raw string" if status == "checkmate"

  # But to_s should give the string
  raise "Status to_s should equal string" unless status.to_s == "checkmate"
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

  # Underscore separator (no hyphens, spaces, etc.)
  Sashite::Cgsn.statuses.each do |status|
    raise "Status '#{status}' contains invalid characters" if status.match?(/[^a-z_]/)
  end

  # No leading/trailing underscores
  Sashite::Cgsn.statuses.each do |status|
    raise "Status '#{status}' has leading underscore" if status.start_with?("_")
    raise "Status '#{status}' has trailing underscore" if status.end_with?("_")
  end

  # No consecutive underscores
  Sashite::Cgsn.statuses.each do |status|
    raise "Status '#{status}' has consecutive underscores" if status.include?("__")
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
