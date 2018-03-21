#!/usr/bin/env ruby

##############################################################
# Position - holds information about a position on the board #
##############################################################

require_relative('../lib/controller')

class Position
  attr_accessor :up, :down, :left, :right, :player, :location

  @@positionsDeleted    = 0
  @@positionsGenerated  = 0

  def initialize(location)
    @location           = location
    @player             = Controller::Player::NEUTRAL
    @up                 = nil
    @down               = nil
    @left               = nil
    @right              = nil

    @@positionsGenerated += 1

  end

  def PlayerChar
    if @player == Controller::Player::NEUTRAL
      return "+"
    elsif @player == Controller::Player::BLACK
      return "B"
    else
      return "W"
    end
  end
end