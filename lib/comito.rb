# frozen_string_literal: true

require_relative "comito/version"
require "tty-prompt"

module Comito
  class DoCommit
    class Error < StandardError; end

    GREEN = "\e[32m"
    YELLOW = "\e[33m"
    BLUE = "\e[34m"
    RED = "\e[31m"
    RESET = "\e[0m"

    DEFAULT_MESSAGE_LENGTH = 72
    CONFIRM_COMMIT_MESSAGE = true
    
    DEFAULT_TYPES  = {
      "feat" => "A new feature",
      "fix" => "A bug fix",
      "chore" => "Build process changes",
      "docs" => "Documentation only",
      "style" => "Code style changes",
      "refactor" => "Refactor code",
      "test" => "Add or correct tests"
    }.freeze

    DEFAULT_SCOPES = {
      "ruby" => "Ruby code",
      "JS" => "JS code",
      "db" => "Database migrations",
      "api" => "API changes",
      "jobs" => "Jobs changes",
      "spec" => "Add or correct specs",
  }.freeze

    def self.load_config
      config_path = File.join(Dir.pwd, "comito_config.yml")

      if File.exist?(config_path)
        config = YAML.load_file(config_path)

        types = config["types"] || DEFAULT_TYPES
        scopes = config["scopes"] || DEFAULT_SCOPES
        msg_length = 
          config["message_length"] < DEFAULT_MESSAGE_LENGTH ? config["message_length"] : DEFAULT_MESSAGE_LENGTH
        confirm_commit_message = config.fetch("confirm_commit_message", CONFIRM_COMMIT_MESSAGE)

        [types, scopes, msg_length - 1, confirm_commit_message]
      else
        [DEFAULT_TYPES, DEFAULT_SCOPES, DEFAULT_MESSAGE_LENGTH, CONFIRM_COMMIT_MESSAGE]
      end
    end

    def self.run
      types, scopes, msg_length, confirn_commit_message = load_config

      staged_files = `git diff --cached --name-only`.split("\n")

      if staged_files.empty?
        puts "#{RED}\nNo files staged for commit.\n#{RESET}"
        return
      end

      prompt = TTY::Prompt.new

      type = prompt.select("#{YELLOW}Select commit type:#{RESET}") do |menu|
        types.each do |key, desc|
          menu.choice("#{GREEN}#{key} — #{desc}#{RESET}", key)
        end
      end

      scope = prompt.select("#{YELLOW}Select scope:#{RESET}") do |menu|
        scopes.each do |key, desc|
          menu.choice("#{GREEN}#{key} — #{desc}#{RESET}", key)
        end
      end

      message = prompt.ask("#{YELLOW}Your commit message:#{RESET}", default: "")

      commit_msg = "#{type}#{scope.to_s.empty? ? '' : "(#{scope})"}: #{message}"

      if commit_msg.length > msg_length
        puts "#{RED}\nError: Commit message exceeds #{msg_length} characters limit.\n#{RESET}"
        puts "#{RED}\nYour full commit message: \n#{commit_msg}\n#{RESET}"
      end

      puts "#{YELLOW}\nFinal full commit message:#{RESET}"
      puts "--------------------------------"
      puts "\n#{BLUE}#{commit_msg[0..msg_length]}#{RESET}\n\n"
      puts "--------------------------------"

      confirm = true

      if confirn_commit_message
        confirm = prompt.yes?("#{YELLOW}Commit with this message?#{RESET}")
      end

      if confirm
        system("git commit -m \"#{commit_msg}\"")
      else
        puts "#{RED}\nAborted.#{RESET}"
      end
    end
  end
end
