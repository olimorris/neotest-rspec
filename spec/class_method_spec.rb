RSpec.describe Class do
  describe '.new' do
    it 'handles the "." method naming convention' do
      expect(Class.new).to be_a(Class)
    end
  end
end
