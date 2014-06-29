require 'spec_helper'

describe Arethusa::CLI do
  it 'has a version number' do
    expect(Arethusa::CLI::VERSION).not_to be nil
  end
end
