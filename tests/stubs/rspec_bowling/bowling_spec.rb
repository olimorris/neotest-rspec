require_relative 'bowling'

RSpec.describe Bowling, '#score' do
  context 'with no strikes or spares' do
    it 'sums the pin count for each roll' do
      bowling = Bowling.new
      puts "too much output"
      puts "too much output"
      puts "too much output"
      puts "too much output"
      puts "too much output"
      puts "too much output"
      puts "too much output"
      20.times { bowling.hit(4) }
      expect(bowling.score).to eq 80
    end
  end
end
