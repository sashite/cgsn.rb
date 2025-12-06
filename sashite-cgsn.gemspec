# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-cgsn"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "CGSN (Chess Game Status Notation) implementation for Ruby with immutable status objects"
  spec.description            = <<~DESC
    CGSN (Chess Game Status Notation) provides a rule-agnostic taxonomy of observable game status
    values for abstract strategy board games. This gem implements the CGSN Specification v1.0.0 with
    a minimal Ruby interface featuring immutable status objects and functional programming principles.
    CGSN defines standardized identifiers for terminal conditions (checkmate, stalemate, bareking,
    mareking, insufficient), player actions (resignation, agreement, illegalmove), and temporal
    constraints (timelimit, movelimit, repetition), enabling precise and portable status identification
    across multiple games and variants. Perfect for game engines, notation systems, and hybrid gaming
    platforms requiring consistent, rule-agnostic game state representation.
  DESC
  spec.homepage               = "https://github.com/sashite/cgsn.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/cgsn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/cgsn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/cgsn.rb",
    "source_code_uri"       => "https://github.com/sashite/cgsn.rb",
    "specification_uri"     => "https://sashite.dev/specs/cgsn/1.0.0/",
    "wiki_uri"              => "https://sashite.dev/specs/cgsn/1.0.0/examples/",
    "rubygems_mfa_required" => "true"
  }
end
