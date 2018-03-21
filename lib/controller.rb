#!/usr/bin/env ruby

##############################################################################
# Controller - has the bestMove function, handles game state and other stuff #
##############################################################################

require_relative('../lib/board')
require_relative('../lib/evalsettings')
require_relative('../lib/move')
require_relative('../lib/game_node')
require_relative('../lib/position')



class Controller

  # different states of the game
  module GameState
    WHITE_WINS		= 0
    BLACK_WINS		= 1
    ILLEGAL_MOVE	= 2
    ONE			    	= 3
    TWO				    = 4
    THREE			    = 5
  end

  # different players of the game
  module Player
    WHITE         = 0
    BLACK         = 1
    NEUTRAL	      = 2
  end

  # constructor for human vs. computer game
  def initialize( timeLimit, firstToAct, compColor)

    @myTimeLimit = timeLimit

    if firstToAct == 'C' || firstToAct == 'c'
      if compColor == 'W' || compColor == 'w'

        @myBoard = Board0.new(Player::WHITE)
        @myComputerColor = Player::WHITE
        @myHumanColor = Player::BLACK

      else

        @myBoard = Board0.new(Player::BLACK)
        @myComputerColor = Player::BLACK
        @myHumanColor = Player::WHITE
      end
    elsif compColor == 'W' || compColor == 'w'

      @myBoard = Board0.new(Player::BLACK)
      @myComputerColor = Player::WHITE
      @myHumanColor = Player::BLACK
    else

      @myBoard = Board0.new(Player::WHITE)
      @myComputerColor = Player::BLACK
      @myHumanColor = Player::WHITE
    end


    @myState = GameState::ONE
    @myGameOver = false
    @myEvalSettings = Evalsettings.new()
    @myLastBoard = nil
    @myEval = true

    # if the computer is first to act, make a move!
    if firstToAct == 'C' || firstToAct == 'c'
      computerMove( @myEvalSettings, @myEval )
    end
  end

  # the recursive bestmove function using alpha-beta!
  # NOTE: we need to keep track of if this is the first call to make sure that we don't evaluate moves
  # that would stick us into an infinite move loop
  def bestMove1(b, depth, mybest, hisbest, firstCall, ev)

    if depth == 0
      if ev
        return GameNode.new(b.evaluate(@myEvalSettings), nil)
      else
        return GameNode.new(b.evalTest(@myEvalSettings), nil)
      end
    end

    now = Time.now
    if now - @myStartTime > @myTimeLimit.to_f
    #if now - @myStartTime < @myTimeLimit.to_f
      @myHitTimeCutoff = true
      return nil
    end


    moveList = b.getMove()
    movesEvaluated = 0
    bestScore = mybest
    bestMove = nil

    while (moveList[movesEvaluated] != nil) && (movesEvaluated < $MAX_MOVES)

      evalBoard = Board1.new(b)
      evalBoard.move0(moveList[movesEvaluated])

      if firstCall && (@myLastBoard != nil) && evalBoard.isSameBoardState(@myLastBoard)
        # don't eval this move
      else
        attempt = bestMove1(evalBoard, depth - 1, 0 - hisbest, 0 - bestScore, false, ev)
        if (attempt != nil) && ((0 - attempt.score) > bestScore)
          bestScore = 0 - attempt.score

          if bestMove != nil
            #Marshal::restore(Marshal.dump(bestMove))
            bestMove = nil
          end

          #bestMove = Marshal::load(Marshal.dump( moveList[movesEvaluated] ))
          bestMove = Move0.new(moveList[movesEvaluated])
        end

        if bestScore > hisbest
          evalBoard = nil
          break
        end
      end

      evalBoard = nil
      movesEvaluated +=1
    end


    # free memory!
    movesEvaluated = 0
    while (moveList[movesEvaluated] != nil) && (movesEvaluated < $MAX_MOVES)
      moveList[movesEvaluated] = nil
      movesEvaluated +=1
    end

    moveList = nil


    return GameNode.new(bestScore, bestMove)
  end

    # this is the wrapper function for the recursive alpha-beta bestmove function.
  # this is an iterative deepening going 2 ply deeper if there's still time to search
  def bestMove(start, es, ev )

    now = Time.now
    @myStartTime = start
    @myHitTimeCutoff = false
    best = nil
    depth = 2

    until (now - @myStartTime)  > @myTimeLimit.to_f

      puts "Searching to depth: #{ depth } "
      temp = bestMove1(@myBoard, depth,  es.worst_score, es.best_score, true, ev)
      now = Time.now
      if @myHitTimeCutoff
        puts "Time limit reached before finding best move at this #{depth}."

      elsif (temp != nil) && (temp.move != nil)
        if best != nil
          best = nil
        end
        best = temp
        puts "Move #{best.move.move()} found in #{now - @myStartTime} seconds."

      elsif temp == nil
        break
      end

      depth +=2
    end

    return best
  end

  # function to perform a computer move on the board
  def computerMove( es, ev )
    ret = true
    puts "Determining computer's move..."
    tStart = Time.now
    tEnd = tStart
    m = bestMove(tStart, es, ev )

    if m == nil
      if @myBoard.hasWon(Player::BLACK)
            puts "Black has won!"
      elsif @myBoard.hasWon(Player::WHITE)
            puts "White has won!"

      # this next bit is because we didn't find a move.  I'm guessing it's because we're only a move or two away
      # from losing.  So get the list of moves and just toss out the first one.
      else
           puts "No best move found. You may be about to win!"
           moveList = @myBoard.getMove()
           if moveList[0] != nil
             puts "Computer move: #{ moveList[0].move }"
             @myBoard.move0(moveList[0])

           else
             puts "Couldn't find any move!"
             ret = false
           end
      end

    else
      puts "Best Move: #{ m.move.move() }"
      puts "Score: #{ m.score }"
      puts "Moves Generated: #{ m.move.ourMovesGenerated() } in #{ tEnd } seconds."
      puts "#{ @myBoard.getPlayerTurn() }'s (computer) move:  #{m.move.move()}"
      @myBoard.move0(m.move)
    end

    return ret
  end

  # takes a string (the move command from the user).  Performs the move and has the computer move in response
  def humanMove( strMove )
    ret = false
    myState = @myBoard.moveHuman(strMove)

    if myState != GameState::ILLEGAL_MOVE
      ret = true
    end

    if @myBoard.hasWon(@myHumanColor)
      puts "You have won!"
      @myGameOver = true

    # now have the computer move
    elsif ret
      @myBoard.print()

      if !computerMove(@myEvalSettings, true)
        @myGameOver = true
      elsif @myBoard.hasWon(@myComputerColor)
        puts "The computer has won!"
        @myGameOver = true
      end

      # keep track of what our last move was so we can avoid getting stuck in a loop with another player
      if @myLastBoard != nil
        #Marshal::restore(Marshal.dump( @myLastBoard))
        @myLastBoard = nil
      end

      #@myLastBoard = Marshal::load(Marshal.dump( @myBoard ))
      @myLastBoard = Board1.new(@myBoard)
    end

    return ret
  end

  def isOver
    return @myGameOver
  end

  # prints the status of the game.
  def print
    @myBoard.print()

    if @myBoard.hasWon(@myHumanColor)
      puts "You have won!"
    elsif @myBoard.hasWon(@myComputerColor)
      puts "I won!"
    end

    if @myBoard.getTurn() == @myComputerColor
      puts "It is the computer's move."
    else
      if @myBoard.getStage() == GameState::ONE
          puts "You have #{ @myBoard.getUnplacedPieces(@myHumanColor) } unplaced pieces."
          puts "Enter drop or drop and capture (ex: D1 or D1,B6): "

      elsif @myBoard.getStage() == GameState::TWO
          puts "Enter adjacent move or move and capture (ex: A1-A4 or A1-A4,G1): "

      else
          puts "Enter fly move or fly move and capture (ex: G1-A7 or G1-A7,D3): ";
      end
    end
  end
end

class EvalController < Controller

  # constructor for evaluate vs. evalTest game.  evalGoes determines if evaluate goes first
  def initialize(timeLimit, gamel, evalGoes)
    @myBoard = Board0.new(Controller::Player::WHITE)
    @myState = Controller::GameState::ONE
    @myTimeLimit = timeLimit
    @myGameOver = false
    @myLastBoard = nil
    @myEvalSettings = Evalsettings.new()

    while !isOver
      if evalGoes
        me = @myBoard.getTurn()
        computerMove(@myEvalSettings, true)
        if @myBoard.hasWon(me)
            @myGameOver = true
        end
        puts "The evaluate function has won!"

        if @myLastBoard != nil
          @myLastBoard = nil
        end

        @myLastBoard = Board1.new(@myBoard)
        evalGoes = false

      else
        me = @myBoard.getTurn()
        computerMove(@myEvalSettings, false)
        if @myBoard.hasWon(me)
            @myGameOver = true
        end
        puts "The evalTest function has won!"
        evalGoes = true

      end
      @myBoard.print()
    end
  end
end
