# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-cgsn"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "CGSN (Chess Game Status Notation) implementation for Ruby with symbol-based status vocabulary"
  spec.description            = "CGSN (Chess Game Status Notation) implementation for Ruby. Provides a rule-agnostic vocabulary for identifying game statuses in abstract strategy board games with symbol-based identifiers and immutable sets."
  spec.homepage               = "https://github.com/sashite/cgsn.rb"
  spec.license                = "Apache-2.0"
  spec.files                  = ::Dir["LICENSE", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/cgsn.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/cgsn.rb/main",
    "homepage_uri"          => "https://github.com/sashite/cgsn.rb",
    "source_code_uri"       => "https://github.com/sashite/cgsn.rb",
    "specification_uri"     => "https://sashite.dev/specs/cgsn/1.0.0/",
    "wiki_uri"              => "https://sashite.dev/specs/cgsn/1.0.0/examples/",
    "funding_uri"           => "https://github.com/sponsors/sashite",
    "rubygems_mfa_required" => "true"
  }
end
