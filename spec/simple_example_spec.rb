describe 'Some maths calculations' do
  context 'passing test' do
    it 'returns 4' do
      expect(2 + 2).to eq(4)
    end
  end
  context 'failing test' do
    it "doesn't return 4" do
      expect(2 + 2).to eq(5)
    end
  end
end
