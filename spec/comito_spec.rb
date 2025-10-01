# frozen_string_literal: true

RSpec.describe Comito do
  it "has a version number" do
    expect(Comito::VERSION).not_to be nil
  end

  it "returns correct version number" do
    expect(Comito::VERSION).to eq("0.2.0")
  end
end
