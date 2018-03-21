#!/usr/bin/env ruby

################################################################
# Move - holds information about a move (coordinates and type) #
################################################################

class Move
  #attr_reader :myType, :myEndPos, :myStartPos, :myCapPos, :ourMovesGenerated, :ourMovesDeleted
  attr_reader :myType, :myEndPos, :myStartPos, :myCapPos

  # different types of moves
  module MoveType
    DROP 				      = 0
    MOVE 				      = 1
    DROP_AND_CAPTURE 	= 2
    MOVE_AND_CAPTURE	= 3
  end

  @@ourMovesGenerated 	= 0
  @@ourMovesDeleted 		= 0

  # the start position (only used for MOVE and MOVE_AND_CAPTURE)
  @myStartPos 			  = 0
  # the end position (used for DROP, and MOVE)
  @myEndPos 				  = 0
  # the capture position (used only for CAPTURE types)
  @myCapPos 				  = 0

  @myType             = 0

  def humanLocation( index )
    case index
      when 0
        return 'A1'
      when 1
        return 'D1'
      when 2
        return 'G1'
      when 3
        return 'B2'
      when 4
        return 'D2'
      when 5
        return 'F2'
      when 6
        return 'C3'
      when 7
        return 'D3'
      when 8
        return 'E3'
      when 9
        return 'A4'
      when 10
        return 'B4'
      when 11
        return 'C4'
      when 12
        return 'E4'
      when 13
        return 'F4'
      when 14
        return 'G4'
      when 15
        return 'C5'
      when 16
        return 'D5'
      when 17
        return 'E5'
      when 18
        return 'B6'
      when 19
        return 'D6'
      when 20
        return 'F6'
      when 21
        return 'A7'
      when 22
        return 'D7'
      when 23
        return 'G7'
    end
  end

  def move
    if @myType == MoveType::DROP
      return "#{ humanLocation(@myEndPos)}"

    elsif @myType == MoveType::DROP_AND_CAPTURE
      return "#{ humanLocation(@myEndPos) } , #{ humanLocation(@myCapPos) }"

    elsif @myType == MoveType::MOVE
      return "#{ humanLocation(@myStartPos) } - #{ humanLocation(@myEndPos) }"

    else
      return "#{ humanLocation(@myStartPos) } - #{ humanLocation(@myEndPos) }, #{ humanLocation(@myCapPos) }"

    end
  end

  def compareMoves(a, b)
    aa = a
    bb = b
    return aa.myType > bb.myType ? -1 : aa.myType < bb.myType ? 1: 0
  end

  def ourMovesGenerated
    return @@ourMovesGenerated
  end

  def init
    @@ourMovesGenerated += 1
  end

end

class Move0 < Move
  def initialize(m)

    @myStartPos = m.myStartPos
    @myEndPos = m.myEndPos
    @myCapPos = m.myCapPos
    @myType = m.myType

    init()

  end

end

class Move1 < Move

  def initialize(type, pos1)
    @myType = type
    @myEndPos = pos1

    init()
  end
end

class Move2 < Move

  def initialize(type, pos1, pos2)
    @myType = type

    if type == Move::MoveType::DROP_AND_CAPTURE
      @myEndPos = pos1
      @myCapPos = pos2

    else
      if type == Move::MoveType::MOVE
        @myStartPos = pos1
      end

      @myEndPos = pos2
    end


    init()
  end
end

class Move3 < Move

  def initialize(type, startPos, endPos, capPos)
    @myType = type
    @myStartPos = startPos
    @myEndPos = endPos
    @myCapPos = capPos

    init()
  end
end