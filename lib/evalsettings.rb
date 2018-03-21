#!/usr/bin/env ruby

#########################################################################
# EvalSettings - holds evaluation settings (what each feature is worth) #
#########################################################################

class Evalsettings

  attr_reader :mill_blocked,
              :mill_formable,
              :mill_formed,
              :mill_opponent,
              :captured_piece,
              :lost_piece,
              :adjacent_spot,
              :blocked_opponent_spot,
              :worst_score,
              :best_score

  def initialize
    @mill_formable			    = 50
    @mill_formed			      = 70
    @mill_blocked			      = 60
    @mill_opponent			    = -80
    @captured_piece			    = 70
    @lost_piece				      = -110
    @adjacent_spot			    = 2
    @blocked_opponent_spot	= 2
    @worst_score			      = -10000
    @best_score				      = 10000
  end
end