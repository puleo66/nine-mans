#!/usr/bin/env ruby

require_relative('lib/controller')
# f 10
# t 10

input_array = ARGV

if input_array.length > 1
  if input_array[0].to_s == 't'
    game = EvalController.new(input_array[1].to_i, 10, true)
  else
    game = EvalController.new(input_array[1].to_i, 10, false)
  end

else
  puts
  puts "Enter the answer to the questions"
  puts

  print "Enter time limit per move (in seconds): "
  timel = gets.chomp

  print "Enter who makes first move (C or H): "
  first = gets.chomp


  print "Enter what color player the computer is (W or B): "
  compcolor = gets.chomp


  game = Controller.new( timel, first, compcolor )

  game.print()

  command = ""

  while command != "q" && !game.isOver()

    print "command: "
    command = gets.chomp


    if game.humanMove(command)
      game.print()
    else
      puts "ILLEGAL MOVE!"
    end
  end
end
game = nil
