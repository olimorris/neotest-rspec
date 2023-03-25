RSpec.describe Array do
  describe 'when first created' do
    it { should be_empty }
  end
  describe 'when first created' do
    it { is_expected.to be_empty }
  end
  describe 'when first created' do
    it do
      is_expected.to be_empty
    end
  end
end
