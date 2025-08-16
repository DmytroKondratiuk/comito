# frozen_string_literal: true

require "spec_helper"
require "cogito"

RSpec.describe Cogito::DoCommit do
  describe ".load_config" do
    let(:config_path) { File.join(Dir.pwd, "cogito_config.yml") }

    after do
      File.delete(config_path) if File.exist?(config_path)
    end

    it "returns defaults if config file does not exist" do
      types, scopes, msg_length, confirm = described_class.load_config

      expect(types).to eq(described_class::DEFAULT_TYPES)
      expect(scopes).to eq(described_class::DEFAULT_SCOPES)
      expect(msg_length).to eq(described_class::DEFAULT_MESSAGE_LENGTH)
      expect(confirm).to eq(true)
    end

    it "loads custom config if present" do
      File.write(config_path, {
        "types" => { "custom" => "My custom type" },
        "scopes" => { "core" => "Core system" },
        "message_length" => 50,
        "confirm_commit_message" => false
      }.to_yaml)

      types, scopes, msg_length, confirm = described_class.load_config

      expect(types).to include("custom")
      expect(scopes).to include("core")
      expect(msg_length).to eq(49)
      expect(confirm).to eq(false)
    end
  end

  describe ".run" do
    context "when not confirming commit message" do
      before do
        allow(described_class).to receive(:load_config).and_return(
          [
            { "feat" => "A new feature" },
            { "app" => "App changes" },
            72,
            false
          ]
        )
      end

      it "aborts if no staged files" do
        allow(described_class).to(
          receive(:`).with("git diff --cached --name-only").and_return("")
        )

        expect { described_class.run }.to output(/No files staged/).to_stdout
      end

      it "creates commit with chosen type, scope and message" do
        allow(described_class).to(
          receive(:`)
            .with("git diff --cached --name-only")
            .and_return("file.rb\n")
        )
        
        allow(CLI::UI::Prompt).to receive(:ask).with(/commit type/) do |_, &block|
          handler = double
          allow(handler).to receive(:option) do |text, &option_block|
            option_block.call if text.include?("feat")
          end
          block.call(handler)
        end

        allow(CLI::UI::Prompt).to receive(:ask).with(/scope/) do |_, &block|
          handler = double
          allow(handler).to receive(:option) do |text, &option_block|
            option_block.call if text.include?("app")
          end
          block.call(handler)
        end
        
        allow_any_instance_of(Object).to(
          receive(:gets).and_return("Added feature\n")
        )

        expect(described_class).to(
          receive(:system).with("git commit -m \"feat(app): Added feature\"")
        )

        described_class.run
      end

      it "shows error if message too long" do
        allow(described_class).to(
          receive(:`)
            .with("git diff --cached --name-only")
            .and_return("file.rb\n")
        )
        allow(CLI::UI::Prompt).to receive(:ask).and_yield(double(option: nil))
        allow_any_instance_of(Object).to receive(:gets).and_return("A" * 100)

        expect { described_class.run }.to output(/exceeds/).to_stdout
      end
  end

    context "when confirming commit message" do
      before do
        allow(described_class).to(
          receive(:`)
            .with("git diff --cached --name-only")
            .and_return("file.rb\n")
        )

        allow_any_instance_of(Object).to(
          receive(:gets).and_return("Added feature\n")
        )
      end

    it "executes git commit when user confirms 'yes'" do
      allow(CLI::UI::Prompt).to receive(:ask).with(/commit type/) do |_, &block|
        handler = double
        allow(handler).to receive(:option) do |text, &option_block|
          option_block.call if text.include?("feat")
        end
        block.call(handler)
      end

      allow(CLI::UI::Prompt).to receive(:ask).with(/scope/) do |_, &block|
        handler = double
        allow(handler).to receive(:option) do |text, &option_block|
          option_block.call if text.include?("app")
        end
        block.call(handler)
      end

      allow(CLI::UI::Prompt).to receive(:ask).with(/Commit with/) do |_, &block|
        handler = double
        allow(handler).to receive(:option) do |text, &option_block|
          option_block.call if text.include?("yes")
        end
        block.call(handler)
      end

      expect(described_class).to receive(:system).with(/git commit -m/)

      described_class.run
    end

    it "aborts commit when user selects 'no'" do
      allow(CLI::UI::Prompt).to receive(:ask).with(/commit type/) do |_, &block|
        handler = double
        allow(handler).to receive(:option) do |text, &option_block|
          option_block.call if text.include?("feat")
        end
        block.call(handler)
      end

      allow(CLI::UI::Prompt).to receive(:ask).with(/scope/) do |_, &block|
        handler = double
        allow(handler).to receive(:option) do |text, &option_block|
          option_block.call if text.include?("app")
        end
        block.call(handler)
      end

      allow(CLI::UI::Prompt).to receive(:ask).with(/Commit with/) do |_, &block|
        handler = double
        allow(handler).to receive(:option) do |text, &option_block|
          option_block.call if text.include?("no")
        end
        block.call(handler)
      end

      expect(described_class).not_to receive(:system)
      expect { described_class.run }.to output(/Aborted/).to_stdout
    end
    end
  end
end
