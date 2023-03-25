describe Class do
  describe '.new' do
    # should be marked as skipped
    xit 'skipped handles the "." method naming convention' do
      expect(Class.new).to be_a(Class)
    end

    it 'handles the "." method naming convention' do
      expect(Class.new).to be_a(Class)
    end
  end
end
