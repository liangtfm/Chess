require './pieces.rb'

module Chess
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

    def can_step?(move_start, move_end)
      dir,len = cartesian_to_polar(move_start, move_end)
      step = [move_end[0] - move_start[0], move_end[1] - move_start[1]]
      return false unless self[*move_start].move_dirs.include?(step)

      true
    end

    def can_slide?(move_start, move_end)
      dir,len = cartesian_to_polar(move_start, move_end)
      path = []

      # make sure desired move is in the right direction
      return false unless self[*move_start].move_dirs.include?(dir)

      # calculate the path (intermediary tiles)
      1.upto(len-1) do |i|
        next_spot = [move_start[0] + (dir[0] * (i)),
                     move_start[1] + (dir[1] * (i))]

        path << next_spot
      end

      # make sure the path is clear
      return false unless path.all? {|i| self[*i].nil? }

      true
    end

    def can_take?(move_start, move_end)
      # spot is nil
      return true if self[*move_end].nil?

      # not the same color
      self[*move_start].color != self[*move_end].color
    end

    def can_pawn_move?(move_start, move_end)
      # No hard returns
      if self[*move_start].color == :w
        return move_start[0] - move_end[0] == 1 &&
          move_start[1] == move_end[1]
      elsif self[*move_start].color == :b
        return move_start[0] - move_end[0] == -1 &&
           move_start[1] == move_end[1]
      end
    end

    def can_pawn_take?(move_start, move_end)
      if self[*move_start].color == :w
        return self[*move_end] &&
          self[*move_start].color != self[*move_end].color &&
          move_start[0] - move_end[0] == 1 &&
          (move_start[1] - move_end[1]).abs == 1
      elsif self[*move_start].color == :b
        return !self[*move_end].nil? &&
          self[*move_start].color != self[*move_end].color &&
          move_start[0] - move_end[0] == -1 &&
          (move_start[1] - move_end[1]).abs == 1
      end
    end

    def cartesian_to_polar(x, y)
      theta = [(y[0] - x[0]), (y[1] - x[1])]
      radius = [theta[0].abs, theta[1].abs].max
      theta[0] = (theta[0].to_f / radius) unless radius == 0
      theta[1] = (theta[1].to_f / radius) unless radius == 0
      [theta, radius]
    end

    def make_move(move_start, move_end)
      #position_start = self[*move_start].position
      position_end = *move_end
      self[*move_start].position = position_end
      self[*move_end] = self[*move_start]
      self[*move_start] = nil
    end

    def move(move_start, move_end)
      # update board
      # raise exception if there is no piece at start
      # or the piece cannot move to end
      if self[*move_start].class <= Chess::SlidingPiece
        if can_slide?(move_start, move_end) &&
            can_take?(move_start, move_end)
          make_move(move_start, move_end)
        end
      elsif self[*move_start].class <= Chess::SteppingPiece
        if can_step?(move_start, move_end) &&
            can_take?(move_start, move_end)
          make_move(move_start, move_end)
        end
      elsif self[*move_start].class == Chess::Pawn
        if can_pawn_move?(move_start, move_end) ||
            can_pawn_take?(move_start, move_end)
          make_move(move_start, move_end)
        end
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


  class Game

    def initialize

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