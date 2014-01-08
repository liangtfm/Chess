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
  #attr_accessor :move_dirs

  def initialize(position, board, color)
    super(position, board, color)
  end

  def moves
  end
end

class SteppingPiece < Piece
  #attr_accessor :move_dirs

  def initialize(position, board, color)
    super(position, board, color)
  end
end

class Queen < SlidingPiece

  def initialize(position, board, color)
    @token = :Q
    super(position, board, color)
  end

  def move_dirs
    QUEEN_MOVES
  end
end

class Rook < SlidingPiece
  def initialize(position, board, color)
    @token = :R
    super(position, board, color)
  end

  def move_dirs
    ROOK_MOVES
  end
end

class Bishop < SlidingPiece
  def initialize(position, board, color)
    @token = :B
    super(position, board, color)
  end

  def move_dirs
    BISHOP_MOVES
  end
end

class King < SteppingPiece
  def initialize(position, board, color)
    @token = :Ki
    super(position, board, color)
  end

  def move_dirs
    KING_MOVES
  end
end

class Knight < SteppingPiece
  def initialize(position, board, color)
    @token = :Kn
    super(position, board, color)
  end

  def move_dirs
    KNIGHT_MOVES
  end
end

class Pawn < Piece
  def initialize(position, board, color)
    @token = :P
    super(position, board, color)
  end

end

