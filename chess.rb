# encoding: UTF-8
require './pieces.rb'
require './board.rb'
require './deep_dup.rb'
require 'colorize'

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

  WHITE_MAP = {
    :K => "\u2654",
    :Q => "\u2655",
    :R => "\u2656",
    :B => "\u2657",
    :k => "\u2658",
    :P => "\u2659",
    :_ => "\u0020"
  }

  BLACK_MAP = {
    :K => "\u265A",
    :Q => "\u265B",
    :R => "\u265C",
    :B => "\u265D",
    :k => "\u265E",
    :P => "\u265F",
    :_ => "\u0020"
  }

  attr_reader :board

  def initialize
    @board = Board.new
  end

  def play
    color = :w
    puts "Let's play chess!".colorize(:light_blue)

    loop do
      render
      puts "It's #{color}'s turn!"
      take_turn(color)
      color == :w ? color = :b : color = :w

      break if @board.checkmate?(color)
    end

    puts "Checkmate! #{color} lost!"
    render
  end

  def take_turn(color)
    begin
      puts "Which piece would you like to move? (ex. b1)"
      start_input = gets.chomp.downcase.split("")
      start_move = [KEY_MAP[start_input.last],
                    start_input.first.ord - "a".ord]
      puts "Where would you like to move it? (ex. c3)"
      end_input = gets.chomp.downcase.split("")
      end_move = [KEY_MAP[end_input.last],
                    end_input.first.ord - "a".ord]
      @board.move(start_move, end_move, color)
      puts "Moved!"
    rescue
      puts "Invalid input. Try again!"
      retry
    end
    nil
  end

  def render
    render = @board.draw_board
    render.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        k = i + j
        color = k.even? ? :yellow : :red
        #cell = " " if cell == :_
        if @board[[i,j]] && @board[[i,j]].color == :w
          print " #{WHITE_MAP[cell]} ".colorize( :background => color)
        else
          print " #{BLACK_MAP[cell]} ".colorize( :background => color)
        end
      end
      print "\n"
    end
    nil
  end

end