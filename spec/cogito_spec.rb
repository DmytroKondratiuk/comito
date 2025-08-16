# frozen_string_literal: true

RSpec.describe Cogito do
  it "has a version number" do
    expect(Cogito::VERSION).not_to be nil
  end

  it "returns correct version number" do
    expect(Cogito::VERSION).to eq("0.1.0")
  end
end
