require './pieces.rb'
require './board.rb'
require './deep_dup.rb'

class Game
  attr_reader :board

  def initialize
    @board = Board.new
  end

  def play
    color = :w
    puts "Let's play chess!"

    loop do
      render
      puts "It's #{color}'s turn!"
      take_turn(color)
      color == :w ? color = :b : color = :w

      break if @board.checkmate?(color)
    end

    puts "Checkmate! #{color} lost!"
  end

  def take_turn(color)
    begin
      puts "What piece would you like to move? (x,y)"
      start_move = gets.chomp.split(",").map(&:to_i)
      puts "Where would you like to move it?"
      end_move = gets.chomp.split(",").map(&:to_i)
      @board.move(start_move, end_move, color)
    rescue
      retry
    end
    nil
  end

  def render
    render = @board.draw_board
    render.each do |row|
      puts row.to_s
    end
    nil
  end

end