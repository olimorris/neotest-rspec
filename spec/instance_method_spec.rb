RSpec.describe String do
  describe '#downcase' do
    it 'handles the "#" naming convention' do
      expect(String.new('HI').downcase).to eq('hi')
    end
  end
end
