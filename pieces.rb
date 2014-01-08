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
  end

  def valid_move?(pos)
  end

  def valid_moves
  end

  def can_take?(move_end)
    # spot is nil
    return true if @board[move_end].nil?

    # not the same color
    color != @board[move_end].color
  end

  def move_into_check?(position)
    new_board = @board.dup
    # to refactor
    new_board.board.each_index do |i|
      new_board.board.each_index do |j|
        if new_board[[i,j]]
          new_board[[i,j]] = new_board[[i,j]].dup(new_board)
        end
      end
    end
    new_board.move!(@pos, position)
    new_board.in_check?(@color)
  end

  def dup(board)
    self.class.new(@pos, board, @color)
  end
end

class SlidingPiece < Piece

  def initialize(pos, board, color)
    super(pos, board, color)
  end

  def moves
    possible_moves = []

    move_dirs.each do |dir|
      1.upto(7) do |len|
        position = [@pos[0] + (dir[0] * len), @pos[1] + (dir[1] * len)]
        if (0..7).include?(position[0]) && (0..7).include?(position[1])
          possible_moves << position
        end
      end
    end

    possible_moves
  end

  def valid_moves
    moves.select { |move| valid_move?(move) }
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

  def initialize(pos, board, color)
    super(pos, board, color)
  end

  def valid_move?(move_end)
    can_step?(move_end) &&
      can_take?(move_end)
  end

  def moves
    possible_moves = []

    move_dirs.each do |dir|
      position = [@pos[0] + dir[0], @pos[1] + dir[1]]
      if (0..7).include?(position[0]) && (0..7).include?(position[1])
        possible_moves << position
      end
    end

    possible_moves
  end

  def valid_moves
    moves.select { |move| valid_move?(move) }
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
    @token = :K
    super(pos, board, color)
  end

  def move_dirs
    KING_MOVES
  end
end

class Knight < SteppingPiece
  def initialize(pos, board, color)
    @token = :k
    super(pos, board, color)
  end

  def move_dirs
    KNIGHT_MOVES
  end
end

class Pawn < SteppingPiece
  def initialize(pos, board, color)
    @token = :P
    super(pos, board, color)
  end

  def move_dirs
    PAWN_MOVES
  end



  def valid_move?(move_end)
    can_move?(move_end) || can_take?(move_end)
  end

  def can_move?(move_end)
    n = color == :w ? 1 : -1

    pos[0] - move_end[0] == n &&
      pos[1] == move_end[1] &&
      @board[move_end].nil?
  end

  def can_take?(move_end)
    n = color == :w ? 1 : -1

    @board[move_end] &&
    color != @board[move_end].color &&
    pos[0] - move_end[0] == n &&
    (pos[1] - move_end[1]).abs == 1
  end
end