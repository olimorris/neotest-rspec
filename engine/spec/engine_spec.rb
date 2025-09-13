RSpec.describe 'Engine support' do
  it 'runs specs from the engine root' do
    expect(Dir.pwd).to end_with('/engine')
  end
end
