require 'rspec'
require 'sum'

RSpec.describe Service::Sum, type: :model do
  subject(:sum) { described_class.new }

  context 'when passing test' do
    describe '#call' do
      before(:each) do
      end

      # xit is a disabled example
      xit 'should return the sum of two numbers' do
        expect(sum.call(1, 3)).to eq(3)
      end
    end

    let(:result) { 2 + 2 }

    it 'returns 4' do
      expect(2 + 2).to eq(result)
    end
  end

  context 'when failing test' do
    it "doesn't return 4" do
      expect(2 + 2).to eq(5)
    end
  end
end
