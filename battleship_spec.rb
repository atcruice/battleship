# BattleshipBoard testing
require_relative 'battleship'

describe BattleshipBoard do
  before :each do
    @b1 = BattleshipBoard.new
    @b2 = BattleshipBoard.new(200, -100)
  end

  describe '.initialize' do
    # default values
    it { expect(@b1.width).to eql 10 }
    it { expect(@b1.height).to eql 10 }

    # corrects funky values
    it { expect(@b2.width).to eql 200 }
    it { expect(@b2.height).to eql 100 }
  end

  describe '#place_ship' do
    # bad ship_type
    it { expect(@b1.place_ship(:rubbish_type, Coord.new, true)).to eql false }
    # non-Coord
    it { expect(@b1.place_ship(:battleship, 10, true)).to eql false }
    # non-direction
    it { expect(@b1.place_ship(:battleship, Coord.new, nil)).to eql false }
    # all-good
    it { expect(@b1.place_ship(:battleship, Coord.new, true)).to eql true }
  end
end
