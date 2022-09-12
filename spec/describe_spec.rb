RSpec.describe "Something" do
  describe "Constants" do
    it "is there" do
      expect(described_class.const_defined?(:BODY_MESSAGE_KEY)).to be true
    end
  end
end
