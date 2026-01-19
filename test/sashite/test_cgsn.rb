#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/sashite/cgsn"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✔"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "=== CGSN Tests ==="
puts

# ============================================================================
# CONSTANTS
# ============================================================================

puts "Constants:"

run_test("STATUSES is a frozen Set") do
  raise "should be a Set" unless Sashite::Cgsn::STATUSES.is_a?(Set)
  raise "should be frozen" unless Sashite::Cgsn::STATUSES.frozen?
end

run_test("STATUSES contains 14 symbols") do
  raise "wrong count" unless Sashite::Cgsn::STATUSES.size == 14
end

run_test("INFERABLE_STATUSES is a frozen Set") do
  raise "should be a Set" unless Sashite::Cgsn::INFERABLE_STATUSES.is_a?(Set)
  raise "should be frozen" unless Sashite::Cgsn::INFERABLE_STATUSES.frozen?
end

run_test("INFERABLE_STATUSES contains 8 symbols") do
  raise "wrong count" unless Sashite::Cgsn::INFERABLE_STATUSES.size == 8
end

run_test("EXPLICIT_ONLY_STATUSES is a frozen Set") do
  raise "should be a Set" unless Sashite::Cgsn::EXPLICIT_ONLY_STATUSES.is_a?(Set)
  raise "should be frozen" unless Sashite::Cgsn::EXPLICIT_ONLY_STATUSES.frozen?
end

run_test("EXPLICIT_ONLY_STATUSES contains 6 symbols") do
  raise "wrong count" unless Sashite::Cgsn::EXPLICIT_ONLY_STATUSES.size == 6
end

run_test("STATUSES is union of INFERABLE and EXPLICIT_ONLY") do
  union = Sashite::Cgsn::INFERABLE_STATUSES | Sashite::Cgsn::EXPLICIT_ONLY_STATUSES
  raise "should be equal" unless Sashite::Cgsn::STATUSES == union
end

run_test("all statuses are symbols") do
  Sashite::Cgsn::STATUSES.each do |status|
    raise "#{status} should be a Symbol" unless status.is_a?(Symbol)
  end
end

# ============================================================================
# parse
# ============================================================================

puts
puts "parse method:"

run_test("parses 'checkmate' to :checkmate") do
  raise "wrong result" unless Sashite::Cgsn.parse("checkmate") == :checkmate
end

run_test("parses 'resignation' to :resignation") do
  raise "wrong result" unless Sashite::Cgsn.parse("resignation") == :resignation
end

run_test("parses all inferable statuses") do
  %w[check stale checkmate stalemate nomove bareking mareking insufficient].each do |str|
    result = Sashite::Cgsn.parse(str)
    raise "wrong result for #{str}" unless result == str.to_sym
  end
end

run_test("parses all explicit-only statuses") do
  %w[resignation illegalmove timelimit movelimit repetition agreement].each do |str|
    result = Sashite::Cgsn.parse(str)
    raise "wrong result for #{str}" unless result == str.to_sym
  end
end

run_test("raises ArgumentError for invalid status") do
  Sashite::Cgsn.parse("invalid")
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "invalid status"
end

run_test("raises ArgumentError for empty string") do
  Sashite::Cgsn.parse("")
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "invalid status"
end

run_test("raises ArgumentError for uppercase") do
  Sashite::Cgsn.parse("CHECKMATE")
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "invalid status"
end

run_test("raises ArgumentError for mixed case") do
  Sashite::Cgsn.parse("Checkmate")
  raise "should have raised"
rescue ArgumentError => e
  raise "wrong message" unless e.message == "invalid status"
end

# ============================================================================
# valid?
# ============================================================================

puts
puts "valid? method:"

run_test("returns true for all valid statuses") do
  %w[check stale checkmate stalemate nomove bareking mareking insufficient
     resignation illegalmove timelimit movelimit repetition agreement].each do |str|
    raise "#{str} should be valid" unless Sashite::Cgsn.valid?(str)
  end
end

run_test("returns false for invalid status") do
  raise "should be invalid" if Sashite::Cgsn.valid?("invalid")
end

run_test("returns false for empty string") do
  raise "should be invalid" if Sashite::Cgsn.valid?("")
end

run_test("returns false for uppercase") do
  raise "should be invalid" if Sashite::Cgsn.valid?("CHECKMATE")
end

run_test("returns false for mixed case") do
  raise "should be invalid" if Sashite::Cgsn.valid?("Checkmate")
end

run_test("returns false for nil") do
  raise "should be invalid" if Sashite::Cgsn.valid?(nil)
end

run_test("returns false for symbol") do
  raise "should be invalid" if Sashite::Cgsn.valid?(:checkmate)
end

run_test("returns false for integer") do
  raise "should be invalid" if Sashite::Cgsn.valid?(123)
end

# ============================================================================
# inferable?
# ============================================================================

puts
puts "inferable? method:"

run_test("returns true for all inferable statuses") do
  %i[check stale checkmate stalemate nomove bareking mareking insufficient].each do |sym|
    raise "#{sym} should be inferable" unless Sashite::Cgsn.inferable?(sym)
  end
end

run_test("returns false for explicit-only statuses") do
  %i[resignation illegalmove timelimit movelimit repetition agreement].each do |sym|
    raise "#{sym} should not be inferable" if Sashite::Cgsn.inferable?(sym)
  end
end

run_test("returns false for invalid symbol") do
  raise "should be false" if Sashite::Cgsn.inferable?(:invalid)
end

run_test("returns false for string") do
  raise "should be false" if Sashite::Cgsn.inferable?("checkmate")
end

run_test("returns false for nil") do
  raise "should be false" if Sashite::Cgsn.inferable?(nil)
end

# ============================================================================
# explicit_only?
# ============================================================================

puts
puts "explicit_only? method:"

run_test("returns true for all explicit-only statuses") do
  %i[resignation illegalmove timelimit movelimit repetition agreement].each do |sym|
    raise "#{sym} should be explicit-only" unless Sashite::Cgsn.explicit_only?(sym)
  end
end

run_test("returns false for inferable statuses") do
  %i[check stale checkmate stalemate nomove bareking mareking insufficient].each do |sym|
    raise "#{sym} should not be explicit-only" if Sashite::Cgsn.explicit_only?(sym)
  end
end

run_test("returns false for invalid symbol") do
  raise "should be false" if Sashite::Cgsn.explicit_only?(:invalid)
end

run_test("returns false for string") do
  raise "should be false" if Sashite::Cgsn.explicit_only?("resignation")
end

run_test("returns false for nil") do
  raise "should be false" if Sashite::Cgsn.explicit_only?(nil)
end

# ============================================================================
# statuses
# ============================================================================

puts
puts "statuses method:"

run_test("returns STATUSES constant") do
  raise "should be same object" unless Sashite::Cgsn.statuses.equal?(Sashite::Cgsn::STATUSES)
end

run_test("contains all 14 statuses") do
  raise "wrong count" unless Sashite::Cgsn.statuses.size == 14
end

# ============================================================================
# inferable_statuses
# ============================================================================

puts
puts "inferable_statuses method:"

run_test("returns INFERABLE_STATUSES constant") do
  raise "should be same object" unless Sashite::Cgsn.inferable_statuses.equal?(Sashite::Cgsn::INFERABLE_STATUSES)
end

run_test("contains all 8 inferable statuses") do
  raise "wrong count" unless Sashite::Cgsn.inferable_statuses.size == 8
end

# ============================================================================
# explicit_only_statuses
# ============================================================================

puts
puts "explicit_only_statuses method:"

run_test("returns EXPLICIT_ONLY_STATUSES constant") do
  raise "should be same object" unless Sashite::Cgsn.explicit_only_statuses.equal?(Sashite::Cgsn::EXPLICIT_ONLY_STATUSES)
end

run_test("contains all 6 explicit-only statuses") do
  raise "wrong count" unless Sashite::Cgsn.explicit_only_statuses.size == 6
end

# ============================================================================
# SECURITY - NON-STRING INPUT FOR valid?
# ============================================================================

puts
puts "Security - non-string input for valid?:"

run_test("rejects nil") do
  raise "should be invalid" if Sashite::Cgsn.valid?(nil)
end

run_test("rejects integer") do
  raise "should be invalid" if Sashite::Cgsn.valid?(123)
end

run_test("rejects array") do
  raise "should be invalid" if Sashite::Cgsn.valid?(%w[checkmate])
end

run_test("rejects symbol") do
  raise "should be invalid" if Sashite::Cgsn.valid?(:checkmate)
end

run_test("rejects hash") do
  raise "should be invalid" if Sashite::Cgsn.valid?({ status: "checkmate" })
end

# ============================================================================
# SECURITY - NON-SYMBOL INPUT FOR inferable?/explicit_only?
# ============================================================================

puts
puts "Security - non-symbol input for classification:"

run_test("inferable? rejects string") do
  raise "should be false" if Sashite::Cgsn.inferable?("checkmate")
end

run_test("inferable? rejects integer") do
  raise "should be false" if Sashite::Cgsn.inferable?(123)
end

run_test("explicit_only? rejects string") do
  raise "should be false" if Sashite::Cgsn.explicit_only?("resignation")
end

run_test("explicit_only? rejects integer") do
  raise "should be false" if Sashite::Cgsn.explicit_only?(123)
end

# ============================================================================
# ROUND-TRIP TESTS
# ============================================================================

puts
puts "Round-trip tests:"

run_test("parse then check inferable") do
  status = Sashite::Cgsn.parse("checkmate")
  raise "should be inferable" unless Sashite::Cgsn.inferable?(status)
end

run_test("parse then check explicit_only") do
  status = Sashite::Cgsn.parse("resignation")
  raise "should be explicit-only" unless Sashite::Cgsn.explicit_only?(status)
end

run_test("all parsed statuses are in statuses set") do
  %w[check stale checkmate stalemate nomove bareking mareking insufficient
     resignation illegalmove timelimit movelimit repetition agreement].each do |str|
    status = Sashite::Cgsn.parse(str)
    raise "#{status} should be in statuses" unless Sashite::Cgsn.statuses.include?(status)
  end
end

puts
puts "All CGSN tests passed!"
puts
