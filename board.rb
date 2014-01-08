require './deep_dup.rb'
require './pieces.rb'

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
      pos_piece, pos_pawn = [i,j], [k,j]
      self[pos_piece] = piece.new(pos_piece, self, color)
      self[pos_pawn] = Pawn.new(pos_pawn, self, color)
    end

    nil
  end

  def draw_board
    @board.map do |subarr|
      subarr.map { |i| i.nil? ? :_ : i.token }
    end
  end

  def [](pos)
    x, y = pos
    @board[x][y]
  end

  def []=(pos, k=nil)
    x, y = pos
    @board[x][y] = k
  end

  def in_check?(color)
    king = find_king(color)
    check = false
    @board.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        next if cell.nil? || cell.color == color
        # piece agnostic
        if cell.class.superclass == Chess::SteppingPiece
          check = true if can_step?([i,j], king.position)
        elsif cell.class.superclass == Chess::SlidingPiece
          check = true if can_slide?([i,j], king.position)
        elsif cell.class == Chess::Pawn
          check = true if can_pawn_take?([i,j], king.position)
        end
      end
    end

    check
  end

  def checkmate?(color)
    return false unless in_check?(color)

    # iterate thru every position on the board twice
    (0...8).each do |i|
      (0...8).each do |j|
        (0...8).each do |m|
          (0...8).each do |n|
            if can_step?([i,j],[m,n]) || can_slide?([i,j],[m,n]) ||
              can_pawn_take?([i,j],[m,n]) || can_pawn_move?([i,j],[m,n])
              new_board = dup
              new_board.move([i,j],[m,n])
              return true if new_board.in_check?(color)
            end
          end
        end
      end
    end

    false
  end

  def find_king(color)
    king = nil

    # @board.flatten.select { |piece| }

    @board.each do |row|
      row.each do |cell|
        king = cell if cell.is_a?(Chess::King) && cell.color == color
      end
    end
    king
  end

  def move!(move_start, move_end)
    self[move_start].pos = move_end
    self[move_end] = self[move_start]
    self[move_start] = nil
  end

  def move(move_start, move_end)
    piece = self[move_start]
    p piece.valid_moves

    if self[move_start].valid_moves.include?(move_end)
      move!(move_start, move_end)
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
