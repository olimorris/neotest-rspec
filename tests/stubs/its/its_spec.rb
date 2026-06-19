require 'rspec/its'
require 'ostruct'

RSpec.describe 'its examples' do
  describe 'hash access' do
    subject { { foo: 1, bar: 2 } }

    its([:foo]) { is_expected.to eq(1) }

    its([:bar]) do
      is_expected.to eq(2)
    end
  end

  describe 'object access' do
    subject { OpenStruct.new(foo: 4, bar: 5, baz: 6) }

    its(:foo) { is_expected.to eq(4) }

    its(:bar) do
      is_expected.to eq(5)
    end

    its('baz') { is_expected.to eq(6) }
  end
end
