require './pieces.rb'
require './board.rb'
require './deep_dup.rb'

class Game
  KEY_MAP = {
    "1" => 7,
    "2" => 6,
    "3" => 5,
    "4" => 4,
    "5" => 3,
    "6" => 2,
    "7" => 1,
    "8" => 0
  }
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
      puts "What piece would you like to move? (ex. g1)"
      start_input = gets.chomp.downcase.split("")
      start_move = [KEY_MAP[start_input.last],
                    start_input.first.ord - "a".ord]
      puts "Where would you like to move it?"
      end_input = gets.chomp.downcase.split("")
      end_move = [KEY_MAP[end_input.last],
                    end_input.first.ord - "a".ord]
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