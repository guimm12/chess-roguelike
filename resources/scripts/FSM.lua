current_state = "player_turn"
game_states = {
    player_turn = {
      draw = nil,
      update = nil,
      keypressed = nil,
      mousepressed = nil },
    enemy_turn = {
      draw = nil,
      update = nil,
      keypressed = function(key) end,
      mousepressed = function(x, y, button) end },
    paused = {
      draw = function() love.graphics.clear() love.graphics.print("The game is paused", 0, 0) end,
      update = function(dt) end,
      keypressed = function(key) if key == "p" then current_state = "player_turn" end end,
      mousepressed = function(x, y, button) end }
  }

function love.update(dt)
    game_states[current_state].update(dt)
end

function love.draw()
    game_states[current_state].draw()
end

function love.keypressed(key)
    game_states[current_state].keypressed(key)
end

game_states["player_turn"].update = function(dt)
  --update stuff
  tile:update()
  wall:update()
  piece:update(dt)
  --move the the camera arround the board
  board:update(dt)
  inventory:update()
end

game_states["player_turn"].draw = function()
  love.graphics.clear(bg_color_r[board.color], bg_color_g[board.color], bg_color_b[board.color], 1)

  tile:draw()
  wall:draw()
  piece:draw()
  inventory:draw()
end

game_states["player_turn"].keypressed = function(key)
  --toogle fullscreen
  if key == "f4" then
    if fullscreen then
      resizeCanvas(window_width, window_height)
    else
      resizeCanvas(screen_width, screen_height)
    end
    fullscreen = not fullscreen
  end
  --quit the game
  if key == "escape" then
    love.event.quit()
  end
  --regenerate level
  if key == "r" then
    board.color = love.math.random(sprite_sheet:getHeight()/22-1)+1
    level:new(level.w, level.h)
  end
  --pause
  if key == "p" then
    current_state = "paused"
  end
  --skip turn
  if key == "z" then
    current_state = "enemy_turn"
  end
end

game_states["player_turn"].mousepressed = function(x, y, button)
  if button == 1 then
    piece:mouseClick(x, y)
  end
end

game_states["enemy_turn"].update = function(dt)
  --Update stuff
  tile:update()
  wall:update()
  piece:update(dt)
  --Move the the camera arround the board
  board:update(dt)

  --Enemy AI
  local scored_moves = {}
  local piece_to_move
  for i = 1, #level.objects.enemyPieces do
    piece_to_move = level.objects.enemyPieces[i]
    piece:calculatePossibleMoves(piece_to_move)
    if #piece_to_move.possibleMoves > 0 then
      for j = 1, #piece_to_move.possibleMoves do
        table.insert(scored_moves, piece:getScoredMove(piece_to_move, piece_to_move.possibleMoves[j]))
      end
    end
  end

  if #scored_moves > 0 then
    --ranking the moves by score
    local max_score_move = {}
    max_score_move.value = -1000
    for i = 1, #scored_moves do
      if max_score_move.value < scored_moves[i].value then
        max_score_move = scored_moves[i]
      end
    end

    --removing all moves with less score than the best(s) one(s)
    --debug_text = ""
    for i = #scored_moves, 1, -1 do
      if scored_moves[i].value < max_score_move.value then
        table.remove(scored_moves, i)
      else
        --debug_text = debug_text.."type: "..scored_moves[i].piece.type..", score: "..scored_moves[i].value.."\n"
      end
    end

    --choosing a random move of the remaining ones
    max_score_move = scored_moves[love.math.random(#scored_moves)]

    piece:move(max_score_move.piece, max_score_move)
    current_state = "player_turn"
  else
    current_state = "player_turn"
  end
end

game_states["enemy_turn"].draw = function()
  love.graphics.clear(bg_color_r[board.color], bg_color_g[board.color], bg_color_b[board.color], 1)

  tile:draw()
  wall:draw()
  piece:draw()
end
