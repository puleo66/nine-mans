#!/usr/bin/env ruby

###############################################################
# GameNode - holds a move and a score (what bestMove returns) #
###############################################################


class GameNode
  attr_reader :score, :move

  def initialize(s, m )
    @score = s
    @move  = m
  end
end