# frozen_string_literal: true

require "spec_helper"
require "comito"

RSpec.describe Comito::DoCommit do
  describe ".load_config" do
    let(:config_path) { File.join(Dir.pwd, "comito_config.yml") }

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
    let(:prompt) { instance_double(TTY::Prompt) }

    before do
      allow(TTY::Prompt).to receive(:new).and_return(prompt)
    end

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
        
        allow(prompt).to receive(:select).with(/commit type/).and_return("feat")
        allow(prompt).to receive(:select).with(/scope/).and_return("ruby")
        allow(prompt).to receive(:ask)
          .with(/Your commit message:/, default: "")
          .and_return("Added feature")
        
        expect(described_class).to(
          receive(:system).with("git commit -m \"feat(ruby): Added feature\"")
        )

        described_class.run
      end

      it "shows error if message too long" do
        allow(described_class).to(
          receive(:`)
            .with("git diff --cached --name-only")
            .and_return("file.rb\n")
        )
        allow(prompt).to receive(:select).with(/commit type/).and_return("feat")
        allow(prompt).to receive(:select).with(/scope/).and_return("ruby")
        allow(prompt).to receive(:ask).with(/Your commit message:/, default: "").and_return("A" * 100)

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
        allow(prompt).to receive(:select).with(/commit type/).and_return("feat")
        allow(prompt).to receive(:select).with(/scope/).and_return("ruby")
        allow(prompt).to receive(:ask).with(/Your commit message:/, default: "").and_return("Added feature")
        allow(prompt).to receive(:yes?).with(/Commit with this message\?/).and_return(true)

        expect(described_class).to receive(:system).with(/git commit -m/)

        described_class.run
      end

      it "aborts commit when user selects 'no'" do
        allow(prompt).to receive(:select).with(/commit type/).and_return("feat")
        allow(prompt).to receive(:select).with(/scope/).and_return("ruby")
        allow(prompt).to receive(:ask).with(/Your commit message:/, default: "").and_return("Added feature")
        allow(prompt).to receive(:yes?).with(/Commit with this message\?/).and_return(false)

        expect(described_class).not_to receive(:system)
        expect { described_class.run }.to output(/Aborted/).to_stdout
      end
    end
  end
end
