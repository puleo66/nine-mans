#!/usr/bin/env ruby

#####################################
# Board - holds board state         #
#####################################


require_relative('../lib/controller')
require_relative('../lib/position')

$MAX_MOVES             = 50

class Board
  attr_accessor :ourBoardsGenerated,
                :ourBoardsDeleted,
                :myUnplaced,
                :myPlaced,
                :myPositions,
                :myPlayerTurn

  @@ourBoardsGenerated = 0
  @@ourBoardsDeleted   = 0

  #@myUnplaced         = Array.new(2, nil)
  #@myPlaced           = Array.new(2, nil)
  #@myPositions        = Array.new(24, nil)


  def init
    @myUnplaced         = Array.new(2, nil)
    @myPlaced           = Array.new(2, nil)
    @myPositions        = Array.new(24, nil)
    
    @myUnplaced[Controller::Player::WHITE] = 9
    @myUnplaced[Controller::Player::BLACK] = 9
    @myPlaced[Controller::Player::WHITE]   = 0
    @myPlaced[Controller::Player::BLACK]   = 0

    (0..23).each do |i|
      @myPositions[i] = Position.new(i)
    end

    # now set the up, down, left, and right pointers for each position on board
    @myPositions[0].right = @myPositions[1]
    @myPositions[0].down = @myPositions[9]
    @myPositions[1].left = @myPositions[0]
    @myPositions[1].down = @myPositions[4]
    @myPositions[1].right = @myPositions[2]
    @myPositions[2].left = @myPositions[1]
    @myPositions[2].down = @myPositions[14]
    @myPositions[3].right = @myPositions[4]
    @myPositions[3].down = @myPositions[10]
    @myPositions[4].left = @myPositions[3]
    @myPositions[4].right = @myPositions[5]
    @myPositions[4].up = @myPositions[1]
    @myPositions[4].down = @myPositions[7]
    @myPositions[5].left = @myPositions[4]
    @myPositions[5].down = @myPositions[13]
    @myPositions[6].right = @myPositions[7]
    @myPositions[6].down = @myPositions[11]
    @myPositions[7].left = @myPositions[6]
    @myPositions[7].right = @myPositions[8]
    @myPositions[7].up = @myPositions[4]
    @myPositions[8].left = @myPositions[7]
    @myPositions[8].down = @myPositions[12]
    @myPositions[9].right = @myPositions[10]
    @myPositions[9].up = @myPositions[0]
    @myPositions[9].down = @myPositions[21]
    @myPositions[10].left = @myPositions[9]
    @myPositions[10].right = @myPositions[11]
    @myPositions[10].up = @myPositions[3]
    @myPositions[10].down = @myPositions[18]
    @myPositions[11].left = @myPositions[10]
    @myPositions[11].up = @myPositions[6]
    @myPositions[11].down = @myPositions[15]
    @myPositions[12].right = @myPositions[13]
    @myPositions[12].up = @myPositions[8]
    @myPositions[12].down = @myPositions[17]
    @myPositions[13].left = @myPositions[12]
    @myPositions[13].right = @myPositions[14]
    @myPositions[13].up = @myPositions[5]
    @myPositions[13].down = @myPositions[20]
    @myPositions[14].left = @myPositions[13]
    @myPositions[14].up = @myPositions[2]
    @myPositions[14].down = @myPositions[23]
    @myPositions[15].right = @myPositions[16]
    @myPositions[15].up = @myPositions[11]
    @myPositions[16].left = @myPositions[15]
    @myPositions[16].right = @myPositions[17]
    @myPositions[16].down = @myPositions[19]
    @myPositions[17].left = @myPositions[16]
    @myPositions[17].up = @myPositions[12]
    @myPositions[18].right = @myPositions[19]
    @myPositions[18].up = @myPositions[10]
    @myPositions[19].left = @myPositions[18]
    @myPositions[19].right = @myPositions[20]
    @myPositions[19].up = @myPositions[16]
    @myPositions[19].down = @myPositions[22]
    @myPositions[20].left = @myPositions[19]
    @myPositions[20].up = @myPositions[13]
    @myPositions[21].right = @myPositions[22]
    @myPositions[21].up = @myPositions[9]
    @myPositions[22].left = @myPositions[21]
    @myPositions[22].right = @myPositions[23]
    @myPositions[22].up = @myPositions[19]
    @myPositions[23].left = @myPositions[22]
    @myPositions[23].up = @myPositions[14]
  end

  def initialize()
    @@ourBoardsGenerated += 1
    init()
  end

  def allPiecesInMills(player)
    piecesInMills = 0

    (0..23).each do |i|
      if (@myPositions[i].player == player) && isMill(@myPositions[i].location, player)
        piecesInMills +=1
      end
    end

    if piecesInMills == @myPlaced[player]
      return true
    else
      return false
    end
  end

  def addMoveAndCaptureMoves(moves, movesGenerated, startPos, endPos)
    # change the start position to Controller::Position::NEUTRAL, we'll change it back
	  @myPositions[startPos].player = Controller::Player::NEUTRAL

    if isMill(endPos, @myPlayerTurn)
      capMoves = 0

      capPlayer = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE

      (0..23).each do |i|
        if (@myPositions[i].player == capPlayer) && !isMill(i, @myPositions[i].player) && (movesGenerated < $MAX_MOVES)
            moves[movesGenerated] = Move3.new(Move::MoveType::MOVE_AND_CAPTURE, startPos, endPos, i)
            movesGenerated +=1
        end
      end

      # exception rule.  if all the opponenet's pieces are in mills, we can pull one out
		  if capMoves == 0
        (0..23).each do |i|
				  if (@myPositions[i].player == capPlayer) && (movesGenerated < $MAX_MOVES)
            moves[movesGenerated] = Move3.new(Move::MoveType::MOVE_AND_CAPTURE, startPos, endPos, i)
            movesGenerated +=1

          end
        end
      end
    elsif movesGenerated < $MAX_MOVES
      moves[movesGenerated] = Move2.new(Move::MoveType::MOVE, startPos, endPos)
      movesGenerated +=1
    end
    @myPositions[startPos].player = @myPlayerTurn
  end

  def getUnplacedPieces( player)

      return @myUnplaced[player]
  end

  #returns the GameState representing the stage of the game.
  def getStage
    if (@myUnplaced[Controller::Player::WHITE] > 0) || (@myUnplaced[Controller::Player::BLACK] > 0)
      return Controller::GameState::ONE
    elsif (@myPlaced[Controller::Player::WHITE] < 4) || (@myPlaced[Controller::Player::BLACK] < 4)
      return Controller::GameState::THREE
    else
      return Controller::GameState::TWO
    end
  end

  #returns the index that a col/row combo is stored in (i.e. col A row 1 returns 0)
  def getArrayIndex(row, col)
    index = 0
    case row
      when '1'
        if col == 'A'
          index = 0
        elsif col == 'D'
          index = 1
        else index = 2
        end
      when '2'
        if col == 'B'
          index = 3
        elsif col == 'D'
          index = 4
        else index = 5
        end
      when '3'
        if col == 'C'
          index = 6
        elsif col == 'D'
          index = 7
        else index = 8
        end
      when '4'
        if col == 'A'
          index = 9
        elsif col == 'B'
          index = 10
        elsif col == 'C'
          index = 11
        elsif col == 'E'
          index = 12
        elsif col == 'F'
          index = 13
        else index = 14
        end
      when '5'
        if col == 'C'
          index = 15
        elsif col == 'D'
          index = 16
        else
          index = 17
        end
      when '6'
        if col == 'B'
          index = 18
        elsif col == 'D'
          index = 19
        else
          index = 20
        end
      when '7'
        if col == 'A'
          index = 21
        elsif col == 'D'
          index = 22
        else
          index = 23
        end
    end
    return index
  end

  def getMove

    moves = Array.new($MAX_MOVES, nil)
    movesGenerated = 0

    # if we're in stage one enumerate all the possible drops
    if @myUnplaced[@myPlayerTurn] > 0

      (0..23).each do |i|
        if @myPositions[i].player == Controller::Player::NEUTRAL
          if isMill(i, @myPlayerTurn)

            capPlayer = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE

            # the capMoves part added for the exception rule.  if all the other player's pieces are in mills
					  # we can remove one from them
            capMoves = 0

            (0..23).each do |j|
						  if (@myPositions[j].player == capPlayer && !isMill(j, @myPositions[j].player)) && (movesGenerated < $MAX_MOVES)
							  capMoves +=1
                moves[movesGenerated]  = Move2.new(Move::MoveType::DROP_AND_CAPTURE, i, j)
                movesGenerated +=1
              end
            end

					  # exception rule
					  if capMoves == 0

              (0..23).each do |j|
							  if (@myPositions[j].player == capPlayer) && (movesGenerated < $MAX_MOVES)
                  moves[movesGenerated] = Move2.new(Move::MoveType::DROP_AND_CAPTURE, i, j)
                  movesGenerated +=1
                end
              end
            end
					  # end exception

          elsif movesGenerated < $MAX_MOVES
            moves[movesGenerated] = Move1.new(Move::MoveType::DROP, i)
            movesGenerated +=1
          end
        end
      end

    # if we're in stage two enumerate all the possible adjacent moves
    elsif @myPlaced[@myPlayerTurn] > 3

      (0..23).each do |i|
        # first figure out which pieces we own
        if @myPositions[i].player == @myPlayerTurn
          # now look at each adjacent empty spot
          # for each one, if making the move forms a mill, enumerate the possible captures
          if (@myPositions[i].up != nil) && @myPositions[i].up.player == Controller::Player::NEUTRAL
            addMoveAndCaptureMoves(moves, movesGenerated, i, @myPositions[i].up.location )
          end

          if (@myPositions[i].down != nil) && @myPositions[i].down.player == Controller::Player::NEUTRAL
             addMoveAndCaptureMoves(moves, movesGenerated, i, @myPositions[i].down.location)
          end

          if (@myPositions[i].left != nil) && @myPositions[i].left.player == Controller::Player::NEUTRAL
             addMoveAndCaptureMoves(moves, movesGenerated, i, @myPositions[i].left.location)
          end

          if (@myPositions[i].right != nil) && @myPositions[i].right.player == Controller::Player::NEUTRAL
             addMoveAndCaptureMoves(moves, movesGenerated, i, @myPositions[i].right.location)
          end
        end
      end
    # if we're in stage three enumerate all possible move/drops
    else

      (0..23).each do |i|
        # first we find which pieces we own
        if @myPositions[i].player == @myPlayerTurn
          # now look at each empty spot
          # for each one, if making the move forms a mill, enumberate the possible captures
          (0..23).each do |j|
            if @myPositions[j].player == Controller::Player::NEUTRAL
              addMoveAndCaptureMoves(moves, movesGenerated, i, j)
            end
          end
        end
      end
    end

    moves = qsort(moves)

    return moves
  end

  #returns true if the coordinate is one on the board
  def isLegalCoord(row, col)
    legal = false
    if row == '1' || row == '7'
      if col == 'A' || col == 'D' || col == 'G'
        legal = true
      end
    elsif row == '2' || row == '6'
      if col == 'B' || col == 'D' || col == 'F'
        legal = true
      end
    elsif row == '3' || row == '5'
      if col == 'C' || col == 'D' || col == 'E'
        legal = true
      end
    elsif row == '4'
      if col == 'A' || col == 'B' || col == 'C' || col == 'E' || col == 'F' || col == 'G'
        legal = true
      end
    end

    return legal
  end

  # returns true if the passed in board contains the same state as this one
  def isSameBoardState(b)
    ret = true
    if @myPlaced[Controller::Player::WHITE] != b.myPlaced[Controller::Player::WHITE]
      ret = false
    elsif @myPlaced[Controller::Player::BLACK] != b.myPlaced[Controller::Player::BLACK]
      ret = false
    elsif @myUnplaced[Controller::Player::WHITE] != b.myUnplaced[Controller::Player::WHITE]
      ret = false
    elsif @myUnplaced[Controller::Player::BLACK] != b.myUnplaced[Controller::Player::BLACK]
      ret = false
    end

    (0..23).each do |i|
      if @myPositions[i].player != b.myPositions[i].player
        ret = false
        break
      end
    end

    return ret
  end

  # returns true if a start position and end position are adjacent to each other (in the sense of a board move)
  def isAdjacent(startPos, endPos)
    if @myPositions[startPos].up != nil
      if @myPositions[startPos].up.location == endPos
        return true
      end
    end

    if @myPositions[startPos].down != nil
      if @myPositions[startPos].down.location == endPos
        return true
      end
    end

    if @myPositions[startPos].left != nil
      if @myPositions[startPos].left.location == endPos
        return true
      end
    end

    if @myPositions[startPos].right != nil
      if @myPositions[startPos].right.location == endPos
        return true
      end
    end

    return false
  end


  def isVerticalMill(pos, player)

    # both neighbors are below
    if @myPositions[pos].up == nil
      return (@myPositions[pos].down.player == @myPositions[pos].down.down.player) && (@myPositions[pos].down.player == player)

    # both above
    elsif @myPositions[pos].down == nil
      return (@myPositions[pos].up.player == @myPositions[pos].up.up.player) && (@myPositions[pos].up.player == player)

    else
      return (@myPositions[pos].up.player == @myPositions[pos].down.player) && (@myPositions[pos].up.player == player)
    end

  end

  def isHorizontalMill(pos, player)

    # both to right
    if @myPositions[pos].left == nil
      return (@myPositions[pos].right.player == @myPositions[pos].right.right.player) && (@myPositions[pos].right.player == player)

    # both to left
    elsif @myPositions[pos].right == nil
      return (@myPositions[pos].left.player == @myPositions[pos].left.left.player) && (@myPositions[pos].left.player == player)

    else
      return (@myPositions[pos].left.player == @myPositions[pos].right.player) && (@myPositions[pos].left.player == player)
    end

  end

  def isMill(pos, player)
    ret = isVerticalMill(pos, player)
    if !ret
      ret = isHorizontalMill(pos, player)
    end
    return ret
  end

  def countMills(startPlayer, player)
    ret = 0
    locInH = Array.new(24, false)
    locInV = Array.new(24, false)

    (0..23).each do |i|
      if @myPositions[i].player == startPlayer
        if !locInH[i] && isHorizontalMill(i, player)
          locInH[i] = true
          ret +=1

          if @myPositions[i].left == nil
            locInH[@myPositions[i].right.location] = true
            locInH[@myPositions[i].right.right.location] = true

          elsif @myPositions[i].right == nil
            locInH[@myPositions[i].left.location] = true
            locInH[@myPositions[i].left.left.location] = true

          else
            locInH[@myPositions[i].right.location] = true
            locInH[@myPositions[i].left.location] = true
          end
        end

        if !locInV[i] && isVerticalMill(i, player)
          locInV[i] = true
          ret +=1

          if @myPositions[i].up == nil
            locInV[@myPositions[i].down.location] = true
            locInV[@myPositions[i].down.down.location] = true

          elsif @myPositions[i].down == nil
            locInV[@myPositions[i].up.location] = true
            locInV[@myPositions[i].up.up.location] = true

          else
            locInV[@myPositions[i].down.location] = true
            locInV[@myPositions[i].up.location] = true
          end
        end
      end
    end

    return ret
  end

  def moveHuman(command)
    state = Controller::GameState::ILLEGAL_MOVE

    #first we need to figure out if it's a placement, placement and capture, move, or move and capture
    # it's a placement
    if command.length == 2
      #verify legal coord, we're in stage one, and the current player has a piece to place
      #if (isLegalCoord(command[1], command[0]) && getStage() == Controller::GameState::ONE) && (@myPlaced[@myPlayerTurn] > 0)
      if isLegalCoord(command[1], command[0]) && getStage() == Controller::GameState::ONE
        index = getArrayIndex(command[1], command[0])

        #make sure there isn't a piece already there
        if @myPositions[index].player == Controller::Player::NEUTRAL
          @myPositions[index].player = @myPlayerTurn
          @myUnplaced[@myPlayerTurn] -= 1
          @myPlaced[@myPlayerTurn] += 1


          @myPlayerTurn = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
          state = getStage()
        end
      end

    #next case is either a simple move or a drop and capture
    elsif command.length == 5
      # it's a drop and capture
      if command[2] == ','
        if isLegalCoord(command[1], command[0]) && isLegalCoord(command[4], command[3] )
          dropPos = getArrayIndex(command[1], command[0])
          capturePos = getArrayIndex(command[4], command[3])

          # verify that the drop forms a mill and the piece they're trying to capture isn't in a mill
          if isMill(dropPos, @myPlayerTurn) && !isMill(capturePos, @myPositions[capturePos].player) || allPiecesInMills(@myPositions[capturePos].player)
            # make the move
            @myPositions[dropPos].player = @myPlayerTurn
            @myPositions[capturePos].player = Controller::Player::NEUTRAL
            @myUnplaced[@myPlayerTurn] -=1
            @myPlaced[@myPlayerTurn] +=1

            @myPlayerTurn = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
            @myPlaced[@myPlayerTurn] -=1
            state = getStage()
          end
        end

      # it's a simple move
      # verify both coords are valid
      else
        if isLegalCoord(command[1], command[0]) && isLegalCoord(command[4], command[3])
          startPos = getArrayIndex(command[1], command[0])
          endPos = getArrayIndex(command[4], command[3])

          # the startPos must be owned by the player and the endPos must be Controller::Player::NEUTRAL
          if (@myPositions[startPos].player == @myPlayerTurn) && (@myPositions[endPos].player == Controller::Player::NEUTRAL)

            # the move must be to an adjacent location or if not the player must have only 3 pieces
            if isAdjacent(startPos, endPos) || @myPlaced[@myPlayerTurn] == 3

              # the move is legal, do it and update board state
              @myPositions[startPos].player = Controller::Player::NEUTRAL
              @myPositions[endPos].player = @myPlayerTurn

              @myPlayerTurn = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
              state = getStage()
            end
          end
        end
      end

    # last case is a move and capture
    elsif command.length == 8
      # verify all three coords are valid
      if isLegalCoord(command[1], command[0]) && isLegalCoord(command[4], command[3]) && isLegalCoord(command[7], command[6])
        startPos = getArrayIndex(command[1], command[0])
        endPos = getArrayIndex(command[4], command[3])
        capPos = getArrayIndex(command[7], command[6])

        # the startPos must be owned by the player and the endPos must be Controller::Player::NEUTRAL
        # the move must form a mill (endPos)
        # the capPos must also not be in a mill

        if (@myPositions[startPos].player == @myPlayerTurn) && (@myPositions[endPos].player == Controller::Player::NEUTRAL) &&
            (isMill(endPos, @myPlayerTurn) && (!isMill(capPos, @myPositions[capPos].player)) || allPiecesInMills(@myPositions[capPos].player))

          # the move must be to an adjacent location or if not the player must have only 3 pieces
          if isAdjacent(startPos, endPos) || @myPlaced[@myPlayerTurn] == 3

            # the move is legal, do it and update board state
            @myPositions[startPos].player = Controller::Player::NEUTRAL
            @myPositions[endPos].player = @myPlayerTurn
            @myPositions[capPos].player = Controller::Player::NEUTRAL

            @myPlayerTurn = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
            @myPlaced[@myPlayerTurn] -=1
            state = getStage()
          end
        end
      end
    end

    if hasWon(Controller::Player::BLACK)
      state = Controller::GameState::BLACK_WINS

    elsif hasWon(Controller::Player::WHITE)
      state = Controller::GameState::WHITE_WINS

    end

    return state
  end

  def move0(m)
    if m.myType == Move::MoveType::DROP
      drop(m.myEndPos)
    elsif m.myType == Move::MoveType::DROP_AND_CAPTURE
      drop(m.myEndPos)
      capture(m.myCapPos)
    elsif m.myType == Move::MoveType::MOVE
      move1(m.myStartPos, m.myEndPos)
    else
      move1(m.myStartPos, m.myEndPos)
      capture(m.myCapPos)
    end
    changeTurn()
  end

  def move1(startPos, endPos)
    @myPositions[startPos].player = Controller::Player::NEUTRAL
    @myPositions[endPos].player = @myPlayerTurn
  end

  def qsort(list)
    return [] if list.size == 0
    listTmp = []

    (0..list.size).each do |i|
      if list[i] != nil
        listTmp[i] = list[i]
      else
        break
      end
    end

    x, *xs = *listTmp
    less, more = xs.partition{|y| y.myType < x.myType}
    qsort(less) + [x] + qsort(more)
  end

  #some functions that are used by the AI to change the board
  def drop(pos)
    @myPositions[pos].player = @myPlayerTurn
    @myUnplaced[@myPlayerTurn] -= 1
    @myPlaced[@myPlayerTurn] +=1
  end

  def capture(pos)
    capPlayer = @myPositions[pos].player
    @myPositions[pos].player = Controller::Player::NEUTRAL
    @myPlaced[capPlayer] -=1
  end

  def changeTurn
    @myPlayerTurn = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
  end

  def getTurn
    return @myPlayerTurn
  end

  def getPlayerTurn
    if @myPlayerTurn == Controller::Player::BLACK
      return "Black"
    else
      return "White"
    end
  end

  # returns true if all the pieces on the board for the player are blocked
  def blocked(player)
    # check every piece on the board
    (0..23).each do |i|
      # if it's the player's piece check if it can move
      if @myPositions[i].player == player

        # if it can move up, down, left, or right then the player isn't blocked
	  		if @myPositions[i].up != nil && @myPositions[i].up.player == Controller::Player::NEUTRAL
			  	return false
        end

		  	if @myPositions[i].down != nil && @myPositions[i].down.player == Controller::Player::NEUTRAL
				  return false
        end

			  if @myPositions[i].left != nil && @myPositions[i].left.player == Controller::Player::NEUTRAL
				  return false
        end

			  if @myPositions[i].right != nil && @myPositions[i].right.player == Controller::Player::NEUTRAL
				  return false
        end
      end
    end

	  # we must be blocked
  	return true
  end

  def hasWon(player)

    opponent = player == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE

    # if the opponent has unplaced pieces, we're still in stage one and we haven't won
    if @myUnplaced[opponent] > 0
      return false
    end

    # if the opponent has less than three pieces then we've won!
	  if @myPlaced[opponent] + @myUnplaced[opponent] < 3
		  return true
    end

    # if the opponent is blocked then we've won!
    return blocked(opponent)

  end

  def print
    puts
    puts "It is the #{ getPlayerTurn() } player's turn."
    puts

    puts "    A   B   C   D   E   F   G"
    puts "1   #{ @myPositions[0].PlayerChar() }-----------#{ @myPositions[1].PlayerChar() }-----------#{ @myPositions[2].PlayerChar() } "
    puts "    |           |           |"
    puts "2   |   #{ @myPositions[3].PlayerChar() }-------#{ @myPositions[4].PlayerChar() }-------#{ @myPositions[5].PlayerChar() }   |"
    puts "    |   |       |       |   |"
    puts "3   |   |   #{ @myPositions[6].PlayerChar() }---#{ @myPositions[7].PlayerChar() }---#{ @myPositions[8].PlayerChar() }   |   |"
    puts "    |   |   |       |   |   |"
    puts "4   #{ @myPositions[9].PlayerChar() }---#{ @myPositions[10].PlayerChar() }---#{ @myPositions[11].PlayerChar() }       #{ @myPositions[12].PlayerChar() }---#{ @myPositions[13].PlayerChar() }---#{ @myPositions[14].PlayerChar() }"
    puts "    |   |   |       |   |   |"
    puts "5   |   |   #{ @myPositions[15].PlayerChar() }---#{ @myPositions[16].PlayerChar() }---#{ @myPositions[17].PlayerChar() }   |   |"
    puts "    |   |       |       |   |"
    puts "6   |   #{ @myPositions[18].PlayerChar() }-------#{ @myPositions[19].PlayerChar() }-------#{ @myPositions[20].PlayerChar() }   |"
    puts "    |           |           |"
    puts "7   #{ @myPositions[21].PlayerChar() }-----------#{ @myPositions[22].PlayerChar() }-----------#{ @myPositions[23].PlayerChar() } "
    puts
    puts

  end


  def evalOne(evals)

    opponent = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
    ret = 0

    # give me points for each mill I blocked
    ret += evals.mill_blocked * countMills(@myPlayerTurn, opponent)

    # give me points for each piece I have on the board.  I get points for range of movement
    # this is specific for stage one
    (0..23).each do |i|
      if @myPositions[i].player == @myPlayerTurn
        if @myPositions[i].up != nil
          ret += evals.adjacent_spot
        end
        if @myPositions[i].down != nil
          ret += evals.adjacent_spot
        end
        if @myPositions[i].left != nil
          ret += evals.adjacent_spot
        end
        if @myPositions[i].right != nil
          ret += evals.adjacent_spot
        end
      end
    end

    # give me points for each piece I have captured
    i = 8
    until i < @myPlaced[opponent] + @myUnplaced[opponent]
      ret += evals.captured_piece
      i -=1
    end

    # take away points for each piece my opponent has captured
    i = 8
    until i < @myPlaced[@myPlayerTurn] + @myUnplaced[@myPlayerTurn]
      ret += evals.lost_piece
      i -=1
    end

    # take away points for each mill my opponent has formed
    ret += evals.mill_opponent * countMills(opponent, opponent)

    return ret

  end

  def evalTwo(evals)
    opponent = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
    ret = 0

    # a board in which I lose is the worst!  we can stop right here.
    if hasWon(opponent)
      return evals.worst_score
    end

    # a board in which I win is the best!
    if hasWon(@myPlayerTurn)
      return evals.best_score
    end

    # give me points for each piece I have captured
    i = 8
    until i < @myPlaced[opponent] + @myUnplaced[opponent]
      ret += evals.captured_piece
      i -=1
    end

    # take away points for each piece my opponent has captured
    i = 8
    until i < @myPlaced[@myPlayerTurn] + @myUnplaced[@myPlayerTurn]
      ret+= evals.lost_piece
      i -=1
    end

    # a board that gives me an opportunity to form a mill is good
    ret+= evals.mill_formable * countMills(Controller::Player::NEUTRAL, @myPlayerTurn)

    # give me points for each mill I have
    ret+= evals.mill_formed * countMills(@myPlayerTurn, @myPlayerTurn)

    # take away points for each mill my opponent has formed
    ret+= evals.mill_opponent * countMills(opponent, opponent)

    # give me points for each spot of my opponent that is blocked
    (0..23).each do |i|
      if @myPositions[i].player == opponent
        blocked = true
        if @myPositions[i].up != nil && @myPositions[i].up.player == Controller::Player::NEUTRAL
          blocked = false
        elsif @myPositions[i].down != nil && @myPositions[i].down.player == Controller::Player::NEUTRAL
          blocked = false
        elsif @myPositions[i].left != nil && @myPositions[i].left.player == Controller::Player::NEUTRAL
          blocked = false
        elsif @myPositions[i].right != nil && @myPositions[i].right.player == Controller::Player::NEUTRAL
          blocked = false
        end

        if blocked
          ret+= evals.blocked_opponent_spot
        end

      end
    end
    return ret
  end

  def evalThree(evals)
    opponent = myplayerurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
    ret = 0

    # a board in which I lose is the worst!  we can stop right here.
    if hasWon(opponent)
      return evals.worst_score
    end

    # give me points for each piece I have captured
    i = 8
    #until i > @myPlaced[opponent] + @myUnplaced[opponent]
    until i < @myPlaced[opponent] + @myUnplaced[opponent]
      ret+= evals.captured_piece
      i -=1
    end

    # a board that gives me an opportunity to form a mill is good
    ret+= evals.mill_formable * countMills(Controller::Player::NEUTRAL, @myPlayerTurn)

    # give me points for each mill I blocked
    ret+= evals.mill_blocked * countMills(@myPlayerTurn, opponent)

    return ret
  end

  def evalOneTest(evals)
    opponent = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE

    ret = 0
    # give me points for each piece I have on the board.  I get points for range of movement
    # this is specific for stage one
    (0..23).each do |i|
      if @myPositions[i].player == @myPlayerTurn
        if @myPositions[i].up != nil
          ret+= evals.adjacent_spot
        end
        if @myPositions[i].down != nil
          ret+= evals.adjacent_spot
        end
        if @myPositions[i].left != nil
          ret+= evals.adjacent_spot
        end
        if @myPositions[i].right != nil
          ret+= evals.adjacent_spot
        end
      end
    end

    i = 8
    # give me points for each piece I have captured
    until i < (@myPlaced[opponent] + @myUnplaced[opponent])
      ret+= evals.captured_piece
      i -=1
    end

    i = 8
    # take away points for each piece my opponent has captured
    until i < (@myPlaced[@myPlayerTurn] + @myUnplaced[@myPlayerTurn])
      ret+= evals.lost_piece
      i -=1
    end

    return ret
  end

  def evalTwoTest(evals)
    """
    opponent = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
    ret = 0

    # a board in which I lose is the worst!  we can stop right here.
	  if hasWon(opponent)
      return evals.worst_score
    end

    # a board in which I win is great!
	  if hasWon(@myPlayerTurn)
      return evals.best_score
    end

    # give me points for each piece I have captured
    i = 8
    until i < (@myPlaced[opponent] + @myUnplaced[opponent])
      ret+= evals.captured_piece
      i -=1
    end

    # take away points for each piece my opponent has captured
    i = 8
    until i < (@myPlaced[@myPlayerTurn] + @myUnplaced[@myPlayerTurn])
      ret+= evals.lost_piece
      i -=1
    end

    return ret
    """
    return evalOne(evals)
  end

  def evalThreeTest(evals)
    """
    opponent = @myPlayerTurn == Controller::Player::WHITE ? Controller::Player::BLACK : Controller::Player::WHITE
    ret = 0

    # a board in which I lose is the worst!  we can stop right here.
    if hasWon(opponent)
      return evals.worst_score
    end

    # a board in which I win is great!
    if hasWon(@myPlayerTurn)
      return evals.best_score
    end

    # give me points for each piece I have captured
    i = 8
    until i < (@myPlaced[opponent] + @myUnplaced[opponent])
      ret+= evals.captured_piece
      i -=1
    end

    # take away points for each piece my opponent has captured
    i = 8
    until i < (@myPlaced[@myPlayerTurn] + @myUnplaced[@myPlayerTurn])
      ret+= evals.lost_piece
      i -=1
    end

    return ret
    """
    return evalOne(evals)
  end

  def evaluate(evals)
    if getStage() == Controller::GameState::ONE
      return evalOne(evals)

    else
      if getStage() == Controller::GameState::TWO
        return evalTwo(evals)
      else
        return evalThree(evals)
      end
    end
  end

  def evalTest(evals)
    if getStage() == Controller::GameState::ONE
      return evalOneTest(evals)
    elsif getStage() == Controller::GameState::TWO
      return evalTwoTest(evals)
    else
      return evalThreeTest(evals)
    end
  end
end

class Board0 < Board
  def initialize(pplayer)
    super()
    @myPlayerTurn = pplayer
  end
end


class Board1 < Board

  def initialize(b)
    # first initialize as blank new board
    super()

    # now do the deep copy stuff
    @myUnplaced[Controller::Player::BLACK] = b.myUnplaced[Controller::Player::BLACK]
    @myPlaced[Controller::Player::WHITE] = b.myPlaced[Controller::Player::WHITE]
    @myPlaced[Controller::Player::BLACK] = b.myPlaced[Controller::Player::BLACK]
    @myPlayerTurn = b.myPlayerTurn

    (0..23).each do |i|
      @myPositions[i].player = b.myPositions[i].player
    end
  end
end
