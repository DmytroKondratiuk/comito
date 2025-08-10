# frozen_string_literal: true

require_relative "lib/cogito/version"

Gem::Specification.new do |spec|
  spec.name = "cogito"
  spec.version = Cogito::VERSION
  spec.authors = ["Dmytro"]
  spec.email = ["k-d-m@ukr.net"]

  spec.summary = "Interactive CLI for generating Conventional Commits messages in Ruby projects."
  spec.description = <<~DESC
    Cogito is a lightweight and easy-to-use Ruby CLI tool that provides an interactive interface for generating commit messages
    following the Conventional Commits specification. It is designed primarily for Ruby and Rails developers who want to standardize
    their commit history with minimal setup and dependencies. Cogito guides users through selecting the commit type, optional scope,
    and description, then formats the message correctly and optionally executes the git commit command. This helps teams maintain
    a clean, consistent, and meaningful git history to improve collaboration, automate changelogs, and streamline release processes.
  DESC
  spec.homepage = "https://github.com/DmytroKondratiuk/cogito"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/DmytroKondratiuk/cogito/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  # spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
