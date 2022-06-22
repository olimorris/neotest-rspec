require 'spec_helper'

module Nested
  class Foo
    def call
      'foo'
    end
  end
end

describe Nested::Foo  do
  it 'adds two numbers together' do
    expect(2 + 2).to eq(4)
  end

  # run `:lua require('neotest').run.run()` on line 17 won't get test result
  describe '#call' do
    it 'returns foo' do
      expect(described_class.new.call).to eq('foo')
    end
  end
end
