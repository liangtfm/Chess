ROOK_MOVES   = [[-1, 0], [ 1, 0],
                [ 0,-1], [ 0, 1]]
BISHOP_MOVES = [[-1,-1], [-1, 1],
                [ 1,-1], [ 1, 1]]
QUEEN_MOVES = ROOK_MOVES + BISHOP_MOVES
KING_MOVES = QUEEN_MOVES
PAWN_MOVES = [[1,-1],[1,0],[1,1],
              [-1,-1],[-1,0],[-1,1]]
KNIGHT_MOVES = [[-1, 2], [-1,-2],
                [ 1,-2], [ 1, 2],
                [-2, 1], [-2,-1],
                [ 2, 1], [ 2,-1]]


class Piece
  attr_accessor :pos, :board, :color
  attr_reader :token

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def moves
    moves = []
  end

  def valid_move?(pos)
  end

  def valid_moves
    # arr = []
    # @board.flatten.each do |pos|
    #   arr << pos if valid_pos?(pos)
    # end
    # arr
  end

  def can_take?(move_end)
    # spot is nil
    return true if @board[move_end].nil?

    # not the same color
    color != @board[move_end].color
  end

  def move_into_check?(pos)
    new_board = @board.dup
    new_board.move(@pos, pos)
    new_board.in_check?(@color)
  end
end

class SlidingPiece < Piece

  def initialize(pos, board, color)
    super(pos, board, color)
  end

  def moves
  end

  def valid_moves
    arr = []

    move_dirs.each do |dir|
      1.upto(7) do |len|
        position = [@pos[0] + (dir[0] * len), @pos[1] + (dir[1] * len)]
        if valid_move?(position)
          arr << position
        else
          break
        end
      end
    end

    arr
  end

  def valid_move?(move_end)
    can_slide?(move_end) && can_take?(move_end)
  end

  def can_slide?(move_end)
    dir,len = find_dir(@pos, move_end)
    path = []

    # make sure desired move is in the right direction
    return false unless move_dirs.include?(dir)

    # calculate the path (intermediary tiles)
    1.upto(len-1) do |i|
      next_spot = [@pos[0] + (dir[0] * (i)),
                   @pos[1] + (dir[1] * (i))]

      path << next_spot
    end

    # make sure the path is clear
    return false unless path.all? {|i| @board[i].nil? }

    true
  end

  def find_dir(x, y)
    dir = [(y[0] - x[0]), (y[1] - x[1])]
    len = [dir[0].abs, dir[1].abs].max
    dir[0] = (dir[0].to_f / len) unless len == 0
    dir[1] = (dir[1].to_f / len) unless len == 0
    [dir, len]
  end
end

class SteppingPiece < Piece
  #attr_accessor :move_dirs

  def initialize(pos, board, color)
    super(pos, board, color)
  end

  def valid_move?(move_end)
    return false unless [(0..8)]
    can_step?(move_end) && can_take?(move_end)
  end

  def valid_moves
    arr = []

    move_dirs.each do |dir|
      position = [@pos[0] + dir[0], @pos[1] + dir[1]]
      arr << position if valid_move?(position)
    end

    arr
  end

  def can_step?(move_end)
    step = [move_end[0] - @pos[0], move_end[1] - @pos[1]]
    return false unless move_dirs.include?(step)

    true
  end
end

class Queen < SlidingPiece

  def initialize(pos, board, color)
    @token = :Q
    super(pos, board, color)
  end

  def move_dirs
    QUEEN_MOVES
  end


end

class Rook < SlidingPiece
  def initialize(pos, board, color)
    @token = :R
    super(pos, board, color)
  end

  def move_dirs
    ROOK_MOVES
  end
end

class Bishop < SlidingPiece
  def initialize(pos, board, color)
    @token = :B
    super(pos, board, color)
  end

  def move_dirs
    BISHOP_MOVES
  end
end

class King < SteppingPiece
  def initialize(pos, board, color)
    @token = :Ki
    super(pos, board, color)
  end

  def move_dirs
    KING_MOVES
  end
end

class Knight < SteppingPiece
  def initialize(pos, board, color)
    @token = :Kn
    super(pos, board, color)
  end

  def move_dirs
    KNIGHT_MOVES
  end
end

class Pawn < Piece
  def initialize(pos, board, color)
    @token = :P
    super(pos, board, color)
  end


  def move_dirs
    PAWN_MOVES
  end

  def valid_moves
    arr = []

    move_dirs.each do |dir|
      position = [@pos[0] + dir[0], @pos[1] + dir[1]]
      arr << position if valid_move?(position)
    end

    arr
  end

  def valid_move?(move_end)
    can_pawn_move?(move_end) || can_pawn_take?(move_end)
  end

  def can_pawn_move?(move_end)
    # No hard returns
    if color == :w
      return pos[0] - move_end[0] == 1 &&
        pos[1] == move_end[1]
    elsif color == :b
      return pos[0] - move_end[0] == -1 &&
         pos[1] == move_end[1]
    end
  end

  def can_pawn_take?(move_end)
    if color == :w
      return @board[move_end] &&
        pos.color != @board[move_end].color &&
        pos[0] - move_end[0] == 1 &&
        (pos[1] - move_end[1]).abs == 1
    elsif color == :b
      return @board[move_end] &&
        color != @board[move_end].color &&
        pos[0] - move_end[0] == -1 &&
        (pos[1] - move_end[1]).abs == 1
    end
  end
end