RSpec.describe 'a thing' do
  it 'this works and gets tested by neotest' do
    expect(3).to eq 3
  end

  it { expect('single line tests'.size).to eq(17) }

  it 'what about focus', focus: true do
    expect(:hi).to be
  end

  context 'contexts work' do
    it { expect('single line tests'.size).to eq(17) }
  end

  # # if this line is present it will make it so no other tests in this group show up, everything else in this group seems ok
  it 'this is a pending test'
end

# this is valid, but also seems to not show up
RSpec.describe do
  it { expect("single line tests".size).to eq(17) }
end
