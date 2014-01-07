module Chess

  class Piece
    attr_accessor :position, :board, :color

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
  end



  class Queen < SlidingPiece
    def initialize(position, board, color)
      super(position, board, color)
    end
  end

  class Rook < SlidingPiece
    def initialize(position, board, color)
      super(position, board, color)
    end
  end

  class Bishop < SlidingPiece
  end

  class King < SteppingPiece
  end

  class Knight < SteppingPiece
  end

  class Pawn < Piece
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

    def [](i,j)
      @board[i][j]
    end

    def []=(i,j,k)
      @board[i][j] = k
    end

    def in_check?(color)
      # find the king on the board
      # see if any opposing pieces can move there

    end

    def move(move_start, move_end)
      # update board
      # raise exception if there is no piece at start
      # or the piece cannot move to end

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