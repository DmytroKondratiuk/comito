# frozen_string_literal: true

require_relative "cogito/version"

module Cogito
  class Error < StandardError; end

  VERSION = "0.1.0"
  
  TYPES = {
    "feat" => "A new feature",
    "fix" => "A bug fix",
    "chore" => "Build process changes",
    "docs" => "Documentation only",
    "style" => "Code style changes",
    "refactor" => "Refactor code",
    "test" => "Add or correct tests"
  }.freeze

  def self.run
    puts "Select commit type:"
    TYPES.each_with_index { |(key, desc), i| puts "#{i+1}. #{key} — #{desc}" }

    type = nil
    loop do
      print "> "
      input = gets.strip.to_i
      if input.between?(1, TYPES.size)
        type = TYPES.keys[input-1]
        break
      else
        puts "Please enter a number between 1 and #{TYPES.size}"
      end
    end

    print "Scope (optional): "
    scope = gets.strip

    print "Short description: "
    desc = gets.strip

    commit_msg = "#{type}#{scope.empty? ? '' : "(#{scope})"}: #{desc}"

    puts "\nYour commit message:"
    puts commit_msg

    print "\nCommit now? (y/n): "
    confirm = gets.strip.downcase

    if confirm == 'y'
      system("git commit -m \"#{commit_msg}\"")
    else
      puts "Aborted."
    end
  end
end
