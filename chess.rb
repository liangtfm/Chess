module Chess
  ROOK_MOVES   = [[-1, 0], [ 1, 0],
                  [ 0,-1], [ 0, 1]]
  BISHOP_MOVES = [[-1,-1], [-1, 1],
                  [ 1,-1], [ 1, 1]]
  QUEEN_MOVES = ROOK_MOVES + BISHOP_MOVES
  KING_MOVES = QUEEN_MOVES
  KNIGHT_MOVES = [[-1, 2], [-1,-2],
                  [ 1,-2], [ 1, 2],
                  [-2, 1], [-2,-1],
                  [ 2, 1], [ 2,-1]]

  class Piece
    attr_accessor :position, :board, :color
    attr_reader :token

    def initialize(position, board, color)
      @position = position
      @board = board
      @color = color
    end

    def moves
      moves = []
    end

    def move_into_check?(pos)
      new_board = @board.dup
      new_board.move(@position, pos)
      new_board.in_check?(@color)
    end
  end

  class SlidingPiece < Piece
    attr_accessor :move_dirs

    def initialize(position, board, color)
      super(position, board, color)
    end

    def moves
    end
  end

  class SteppingPiece < Piece
    def initialize(position, board, color)
      super(position, board, color)
    end
  end

  class Queen < SlidingPiece

    def initialize(position, board, color)
      @token = :Q
      @queen_moves = []
      @move_dirs = QUEEN_MOVES
      super(position, board, color)
    end
  end

  class Rook < SlidingPiece
    def initialize(position, board, color)
      @token = :R
      super(position, board, color)
    end
  end

  class Bishop < SlidingPiece
    def initialize(position, board, color)
      @token = :B
      super(position, board, color)
    end
  end

  class King < SteppingPiece
    def initialize(position, board, color)
      @token = :Ki
      super(position, board, color)
    end
  end

  class Knight < SteppingPiece
    def initialize(position, board, color)
      @token = :Kn
      super(position, board, color)
    end
  end

  class Pawn < Piece
    def initialize(position, board, color)
      @token = :P
      super(position, board, color)
    end
  end

  class Board
    PIECES = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

    attr_accessor :board

    def initialize
      @board = Array.new(8) { Array.new(8, nil) }
      make_board(:w, 7, 6)
      make_board(:b, 0, 1)
    end

    def make_board(color, i, k)
      8.times do |j|
        piece = PIECES[j]
        self[i,j] = piece.new([i,j], self, color)
        self[k,j] = Pawn.new([k,j], self, color)
      end

      nil
    end

    def draw_board
      @board.map do |subarr|
        subarr.map { |i| i.nil? ? :_ : i.token }
      end
    end

    def [](i,j)
      @board[i][j]
    end

    def []=(i,j,k = nil)
      @board[i][j] = k
    end

    def in_check?(color)
      # find the king on the board
      # see if any opposing pieces can move there

    end

    def can_move?(move_start, move_end)
      dir,len = cartesian_to_polar(move_start, move_end)
      path = []

      return false unless self[*move_start].move_dirs.include?(dir)

      1.upto(len-1) do |i|
        next_spot = [move_start[0] + (dir[0] * (i)),
                     move_start[1] + (dir[1] * (i))]

        path << next_spot
      end

      return false unless path.all? {|i| self[*i].nil? }

      true
    end


    def can_take?(move_start, move_end)
      # spot is nil
      return true if self[*move_end].nil?

      # not the same color
      self[*move_start].color != self[*move_end].color
    end

    def cartesian_to_polar(x, y)
      theta = [(y[0] - x[0]), (y[1] - x[1])]
      radius = [theta[0].abs, theta[1].abs].max
      theta[0] = (theta[0].to_f / radius) unless radius == 0
      theta[1] = (theta[1].to_f / radius) unless radius == 0
      [theta, radius]
    end

    def move(whence, thither)
      # update board
      # raise exception if there is no piece at start
      # or the piece cannot move to end
      if can_move?(whence, thither) &&
          can_take?(whence, thither)
        self[thither.first, thither.last] = self[whence.first, whence.last]
        self[whence.first, whence.last] = nil
      else
        raise "Illegal move."
      end
    end

    def dup
      new_board = Board.new
      new_board.board = self.board.deep_dup
      new_board
    end


  end


end


class Array
  def deep_dup

    [].tap do |new_array|
      self.each do |el|
        new_array << (el.is_a?(Array) ? el.deep_dup : el)
      end
    end

  end
end