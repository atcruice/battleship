require_relative 'battleship'

# Coord tests
describe Coord do
  before :each do
    @c1 = Coord.new
    @c2 = Coord.new(7, 8, true, @c1.object_id)
    @c3 = Coord.new(7, 8, false, @c2.object_id)
  end

  describe '.initialize' do
    it do
      # default values
      expect(@c1.x).to eql -1
      expect(@c1.y).to eql -1
      expect(@c1.hit).to eql false
      expect(@c1.owner).to eql nil
      # good values
      expect(@c2.x).to eql 7
      expect(@c2.y).to eql 8
      expect(@c2.hit).to eql true
      expect(@c2.owner).to eql @c1.object_id
    end
  end

  describe '#eql?' do
    it do
      expect(@c1.eql?(@c2)).to eql false
      expect(@c2.eql?(@c3)).to eql true
    end
  end
end

# Ship tests
describe Ship do
  before :each do
    @s1 = Ship.new
    @s2 = Ship.new(:rubbish_type)
    @s3 = Ship.new(:battleship)
  end

  describe '.initialize' do
    it do
      # default values
      expect(@s1.type).to eql 'Carrier'
      expect(@s1.size).to eql 5
      expect(@s1.occupied_coords).to eql []
      expect(@s1.sunk?).to eql false
      expect(@s2.type).to eql 'Carrier'
      expect(@s2.size).to eql 5
      expect(@s2.occupied_coords).to eql []
      expect(@s2.sunk?).to eql false
      # good values
      expect(@s3.type).to eql 'Battleship'
      expect(@s3.size).to eql 4
      expect(@s3.occupied_coords).to eql []
      expect(@s3.sunk?).to eql false
    end
  end

  describe '#sunk?' do
    it do
      c1 = Coord.new(0, 0, false)
      c2 = Coord.new(1, 0, true)
      c3 = Coord.new(2, 0, true)
      a1 = [c1, c2]
      a2 = [c2, c3]
      @s1.occupied_coords = a1
      @s2.occupied_coords = a2
      expect(@s1.sunk?).to eql false
      expect(@s2.sunk?).to eql true
    end
  end
end

# BattleshipBoard tests
describe BattleshipBoard do
  before :each do
    @b1 = BattleshipBoard.new
    @b2 = BattleshipBoard.new(200, -100)
    @b3 = BattleshipBoard.new(4, 4)
  end

  describe '.initialize' do
    it do
      # default values
      expect(@b1.width).to eql 10
      expect(@b1.height).to eql 10
      # corrects funky values
      expect(@b2.width).to eql 200
      expect(@b2.height).to eql 100
      # corrects too-small board
      expect(@b3.width).to eql 5
      expect(@b3.height).to eql 5
    end
  end

  describe '#place_ship' do
    it do
      # non-Coord, fails: bad param
      expect(@b1.place_ship(Ship.new(:patrol), 10, true)).to eql false
      # bad direction, fails: non-bool
      expect(@b1.place_ship(Ship.new(:patrol), Coord.new, nil)).to eql false
      # bad ship_type becomes Carrier
      expect(@b1.place_ship(Ship.new(:nomatch), Coord.new, true)).to eql true
      # same values different board
      expect(@b2.place_ship(Ship.new(:nomatch), Coord.new, true)).to eql true
      # good params, fails: overlap placement
      expect(@b1.place_ship(Ship.new(:patrol), Coord.new, true)).to eql false
    end
  end

  describe '#attack' do
    it do
      # bad param
      expect(@b1.attack(nil)).to eql false
      # attack empty board, false, MISS
      expect(@b1.attack(Coord.new)).to eql false
      # attack patrol ship, true, HIT
      @b1.place_ship(Ship.new(:patrol), Coord.new, true)
      expect(@b1.attack(Coord.new)).to eql true
      # sink patrol ship
      expect(@b1.attack(Coord.new(1, 0))).to eql true
    end
  end
end
