# Class to represent a Battleship board
# (think the classic Milton Bradley board game).
#
# State is derived from a list of ships occupying coordinates on the board.
# Default board size: 10 x 10
# Minimum board size: 5 x 5 (restricted by biggest ship)
#
# @author Alex Cruice
# @version 20140329
class BattleshipBoard
  # useful if client wants board info
  attr_reader :width, :height, :ships

  def initialize(w = 10, h = 10)
    # board dimension "constants"
    biggest_ship = Ship.class_variable_get(:@@ship_types).values.max
    @width = [w.abs, biggest_ship].max
    @height = [h.abs, biggest_ship].max
    @width.freeze
    @height.freeze

    @ships = []
  end

  # Try to place a ship on this board.
  #
  # @param ship ship_type symbol (valid please)
  # @param loc  Coord of desired placement
  # @param horiz bool representing horizontal placement (false for vertical)
  # @return true for successful placement, false otherwise
  def place_ship(ship, loc, horiz)
    if ship.class == Ship &&
       loc.class == Coord &&
       (horiz.class == TrueClass || horiz.class == FalseClass)

      potential_occupied = []

      # identify bounds for valid ship placement
      # attempts to correct invalid Coord
      # axis that changes
      potential_delta_lower = horiz ? loc.x : loc.y
      delta_upper = (horiz ? @width : @height) - ship.size
      delta_lower = [[0, potential_delta_lower].max, delta_upper].min
      # axis that doesn't change
      potential_const_lower = horiz ? loc.y : loc.x
      const_upper = (horiz ? @height : @width) - ship.size
      const = [[0, potential_const_lower].max, const_upper].min
      # build potential coords
      (delta_lower...delta_lower + ship.size).each do |n|
        x = horiz ? n : const
        y = horiz ? const : n
        potential_occupied.push(Coord.new(x, y, false, ship.object_id))
      end

      # use Coord set intersection to determine placement validity
      if (board_occupied & potential_occupied).length == 0
        # empty set intersection, valid placement
        # populate ship coords, update board
        ship.occupied_coords = potential_occupied
        @ships.push(ship)
        # puts 'SALL GOOD'
        true # placement successful
      else
        # non-empty set intersection, overlap!
        # puts 'OVERLAP'
        false # invalid placement
      end
    else
      # puts 'BAD PARAM'
      false # placement failed, invalid params
    end
  end

  # Attempt an attack at the given board coordinates.
  #
  # Corrects invalid coordinates.
  # Allows repeated attempted attacks on the same location,
  # just like the real game (Player is responsible for
  # tracking attack history).
  #
  # @param x x-coord
  # @param y y-coord
  # @return true if HIT, false otherwise
  def attack(loc)
    if loc.class == Coord
      # sanitise values
      loc = Coord.new([[0, loc.x].max, @width].min, [[0, loc.y].max, @height].min)
      # set intersection with all occupied Coords
      # loc MUST be on the RHS of the following expression
      # need to retain ownership of possible hit Coord for sink test
      intersection = board_occupied & [loc]
      if intersection.length == 0
        # empty set, MISS!
        puts 'miss'
        false
      else
        # non-empty intersection, HIT!
        # update Coord
        puts 'hit'
        intersection[0].hit = true

        # TODO: do something more with sunk-ness?
        hit_ship = ObjectSpace._id2ref(intersection[0].owner)
        puts "Destroyed #{hit_ship.type}" if hit_ship.sunk?
        true
      end
    else
      # puts 'BAD PARAM'
      false # invalid param
    end
  end

  private

  # returns Array of occupied Coords
  def board_occupied
    all_occupied = []

    # set union of all occupied Coords
    @ships.each do |s|
      all_occupied |= s.occupied_coords
    end

    all_occupied
  end
end

# Class to represent ship types.
#
# Defaults to Carrier.
#
# size: size/length of ship type
# occupied_coords: list of board Coords occupied by this Ship,
#                  only populated when valid
# type: pretty string e.g.: "Battleship"
class Ship
  attr_accessor :occupied_coords
  attr_reader :type, :size

  @@ship_types = { carrier:    5,
                   battleship: 4,
                   submarine:  3,
                   destroyer:  3,
                   patrol:     2 }
  @@ship_types.freeze

  def initialize(type = :carrier)
    type = :carrier if @@ship_types[type].nil?
    @size = @@ship_types[type]
    @type = type.to_s.capitalize
    @occupied_coords = []
  end

  # Determine if all Coords of this are hit
  def sunk?
    if occupied_coords == []
      return false
    else
      outcome = true
      occupied_coords.each do |c|
        outcome &= c.hit
      end
      outcome
    end
  end
end

# Simple class to represent a coordinate point on the
# BattleshipBoard and it's owner
# (if the Coord belongs to a Ship)
class Coord
  attr_reader :x, :y, :owner
  attr_accessor :hit

  def initialize(x = -1, y = -1, hit = false, owner = nil)
    @x, @y, @hit, @owner = x, y, hit, owner
  end

  # Coord equality ignores hit-ness and ownership
  def hash
    [@x, @y].hash
  end

  def eql?(other)
    @x == other.x && @y == other.y
  end
end
