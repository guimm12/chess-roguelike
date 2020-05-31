piece = {}

piece.types = {"king", "queen", "bishop", "knight", "rook", "pawn"}
piece.values = {900, 90, 30, 30, 50, 10}
piece.colors = {"white", "black"}

function piece:new(x, y, type, color, hp, sp)
  local new_piece = {}
  new_piece.x = x
  new_piece.y = y
  if hp ~= nil then
    new_piece.hp = hp
  else
    new_piece.hp = 1
  end
  if sp ~= nil then
    new_piece.sp = sp
  else
    new_piece.sp = 0
  end

  piece:setPieceTypeColorSprite(new_piece, type, color)

  new_piece.sx = x*sprites_1.width-sprites_1.width
  new_piece.sy = y*sprites_1.height-sprites_1.height
  new_piece.sx2 = math.floor(new_piece.sx + board.x)
  new_piece.sy2 = math.floor(new_piece.sy + board.y)
  new_piece.possibleMoves = {}
  new_piece.moves = 0
  table.insert(level.objects.pieces, new_piece)
  if new_piece.color == "white" then
    table.insert(level.objects.playerPieces, new_piece)
  else
    table.insert(level.objects.enemyPieces, new_piece)
  end
  return new_piece
end

function piece:setPieceTypeColorSprite(the_piece, type, color)
  if type == nil then
    type = the_piece.type
  else
    the_piece.type = type
  end
  if color == nil then
    color = the_piece.color
  else
    the_piece.color = color
  end
  if color == "white" then
    for j = 1, #piece.types do
      if type == piece.types[j] then
        the_piece.sprite = sprites_1[board.color][j+95]
        the_piece.value = piece.values[j]
      end
    end
  elseif color == "black" then
    for j = 1, #piece.types do
      if type == piece.types[j] then
        the_piece.sprite = sprites_1[board.color][j+101]
        the_piece.value = piece.values[j]
      end
    end
  end
end

function piece:update(dt)
  for i = 1, #level.objects.pieces do
    level.objects.pieces[i].sx = (level.objects.pieces[i].x*sprites_1.width-sprites_1.width)+(level.objects.pieces[i].sx-(level.objects.pieces[i].x*sprites_1.width-sprites_1.width))/(1+dt*60)
    level.objects.pieces[i].sy = (level.objects.pieces[i].y*sprites_1.height-sprites_1.height)+(level.objects.pieces[i].sy-(level.objects.pieces[i].y*sprites_1.height-sprites_1.height))/(1+dt*60)

    level.objects.pieces[i].sx2 = math.floor(level.objects.pieces[i].sx + board.x + .5)
    level.objects.pieces[i].sy2 = math.floor(level.objects.pieces[i].sy + board.y + .5)
  end
end

function piece:draw()
  for i = 1, #level.objects.pieces do
    piece:drawPiece(i)
    piece:drawHealthGUI(i)
  end
  if level.objects.selectedPiece ~= nil then
    piece:drawSelectedGUI(level.objects.selectedPiece)
    piece:drawPossibleMovesGUI(level.objects.selectedPiece)
  end
end

function piece:drawPiece(_index)
  love.graphics.draw(sprite_sheet, level.objects.pieces[_index].sprite, level.objects.pieces[_index].sx2, level.objects.pieces[_index].sy2)
end

function piece:drawHealthGUI(_index)
  love.graphics.draw(sprite_sheet, sprites_1[board.color][107+level.objects.pieces[_index].hp], level.objects.pieces[_index].sx2, level.objects.pieces[_index].sy2)
  if level.objects.pieces[_index].sp > 0 then
    love.graphics.draw(sprite_sheet, sprites_1[board.color][116+level.objects.pieces[_index].sp], level.objects.pieces[_index].sx2, level.objects.pieces[_index].sy2)
  end
end

function piece:drawSelectedGUI(the_piece)
  love.graphics.draw(sprite_sheet, sprites_1[board.color][76], the_piece.sx2, the_piece.sy2)
end

function piece:drawPossibleMovesGUI(the_piece)
  for i = 1, #the_piece.possibleMoves do
    love.graphics.draw(sprite_sheet, sprites_1[board.color][77], the_piece.possibleMoves[i].sx, the_piece.possibleMoves[i].sy)
  end
end

function piece:findByCoords(x, y)
  for i = 1, #level.objects.pieces do
    if level.objects.pieces[i].x == x and level.objects.pieces[i].y == y then
      return level.objects.pieces[i]
    end
  end
  return nil
end

function piece:getIndex(the_piece)
  for i = 1, #level.objects.pieces do
    if level.objects.pieces[i].x == the_piece.x and level.objects.pieces[i].y == the_piece.y then
      return i
    end
  end
end

function piece:getPlayerIndex(the_piece)
  for i = 1, #level.objects.playerPieces do
    if level.objects.playerPieces[i].x == the_piece.x and level.objects.playerPieces[i].y == the_piece.y then
      return i
    end
  end
  return -1
end

function piece:getEnemyIndex(the_piece)
  for i = 1, #level.objects.enemyPieces do
    if level.objects.enemyPieces[i].x == the_piece.x and level.objects.enemyPieces[i].y == the_piece.y then
      return i
    end
  end
  return -1
end

function piece:capturePiece(piece_to_capture)
  --check if its a enemy and remove it
  local index = piece:getEnemyIndex(piece_to_capture)
  if index ~= -1 then
    table.remove(level.objects.enemyPieces, index)
  else
    --if its not a enemy, check if its a player and remove it
    index = piece:getPlayerIndex(piece_to_capture)
    if index ~= -1 then
      table.remove(level.objects.playerPieces, index)
    end
  end
  --on either case, remove it from the main table and add it to capturedPieces
  table.insert(level.objects.capturedPieces, table.remove(level.objects.pieces, piece:getIndex(piece_to_capture)))
end

function piece:damagePiece(piece_to_damage, damage)
  if piece_to_damage.sp > 0 then
    piece_to_damage.sp = piece_to_damage.sp - damage
    if piece_to_damage.sp < 0 then
      piece_to_damage.sp = 0
      return "sp broken"
    end
    return "sp damage"
  else
    piece_to_damage.hp = piece_to_damage.hp - damage
    if piece_to_damage.hp <= 0 then
      piece_to_damage.hp = 0
      piece:capturePiece(piece_to_damage)
      return "captured"
    end
    return "hp damage"
  end
end

--Takes a piece and one of its possible moves, then performs that move
function piece:move(piece_to_move, where_to_move)
  local piece_to_damage = piece:findByCoords(where_to_move.x, where_to_move.y)
  if piece_to_damage ~= nil then
    if piece:damagePiece(piece_to_damage, 1) == "captured" then
      piece_to_move.x = where_to_move.x
      piece_to_move.y = where_to_move.y
      piece_to_move.moves = piece_to_move.moves + 1
      if piece_to_move.type == "pawn" then
        piece:tryPromotingPawn(piece_to_move)
      end
    end
  else
    piece_to_move.x = where_to_move.x
    piece_to_move.y = where_to_move.y
    piece_to_move.moves = piece_to_move.moves + 1
    if piece_to_move.type == "pawn" then
      piece:tryPromotingPawn(piece_to_move)
    end
  end
end

function piece:getScoredMove(piece_to_move, where_to_move)
  local scored_move = {}
  scored_move.value = 0
  scored_move.x = where_to_move.x
  scored_move.y = where_to_move.y
  scored_move.piece = piece_to_move

  --checking if can capture something
  local piece_to_capture = piece:findByCoords(scored_move.x, scored_move.y)
  if piece_to_capture ~= nil then
    if piece_to_capture.color == "white" then
      scored_move.value = scored_move.value + piece_to_capture.value
    end
  end

  local player_possible_move
  local temp_x, temp_y
  --checking if it can capture a piece the next turn (if the player doesn't move)
  temp_x, temp_y = piece_to_move.x, piece_to_move.y
  piece_to_move.x, piece_to_move.y = scored_move.x, scored_move.y
  piece:calculatePossibleMoves(piece_to_move)
  for i = 1, #piece_to_move.possibleMoves do
    piece_to_capture = piece:findByCoords(piece_to_move.possibleMoves[i].x, piece_to_move.possibleMoves[i].y)
    if piece_to_capture ~= nil then
      if piece_to_capture.color == "white" then
        scored_move.value = scored_move.value + piece_to_capture.value/10
      end
    end
  end
  piece_to_move.x, piece_to_move.y = temp_x, temp_y
  piece:calculatePossibleMoves(piece_to_move)

  local player_piece
  if #level.objects.playerPieces > 0 then
    for i = 1, #level.objects.playerPieces do
      player_piece = level.objects.playerPieces[i]
      --checking if it can be captured right now
      piece:calculatePossibleMoves(player_piece)
      if #player_piece.possibleMoves > 0 then
        for j = 1, #player_piece.possibleMoves do
          player_possible_move = player_piece.possibleMoves[j]
          if player_possible_move.x == piece_to_move.x and player_possible_move.y == piece_to_move.y then
            scored_move.value = scored_move.value + piece_to_move.value
          end
        end
      end
      --checking if it can be captured where it's gonna move
      --to do that we need to calculate the player movements again, but without the piece we are trying to move
      temp_x, temp_y = piece_to_move.x, piece_to_move.y
      piece_to_move.x, piece_to_move.y = -1, -1
      piece:calculatePossibleMoves(player_piece)
      if #player_piece.possibleMoves > 0 then
        for j = 1, #player_piece.possibleMoves do
          player_possible_move = player_piece.possibleMoves[j]
          if player_possible_move.x == scored_move.x and player_possible_move.y == scored_move.y then
            scored_move.value = scored_move.value - piece_to_move.value
          end
        end
      end
      piece_to_move.x, piece_to_move.y = temp_x, temp_y
    end
  end

  return scored_move
end

function piece:calculateHorizontalVerticalMoves(the_piece, max_distance)
  local x = the_piece.x
  local y = the_piece.y
  local color = the_piece.color
  local blocked_path = false
  local x_aux = 1
  local y_aux = 1
  --moving left
  blocked_path = false
  while not blocked_path do
    local other_piece = piece:findByCoords(x - x_aux, y)
    if level.tileData[x - x_aux][y] == 1 then
      if other_piece ~= nil then
        if other_piece.color == color then
          blocked_path = true
          x_aux = 1
        else
          table.insert(the_piece.possibleMoves, tile:findByCoords(x - x_aux, y))
          blocked_path = true
          x_aux = 1
        end
      else
        table.insert(the_piece.possibleMoves, tile:findByCoords(x - x_aux, y))
        if max_distance == nil then
          x_aux = x_aux + 1
        elseif x_aux < max_distance then
          x_aux = x_aux + 1
        else
          blocked_path = true
          x_aux = 1
        end
      end
    else
      blocked_path = true
      x_aux = 1
    end
  end
  --moving right
  blocked_path = false
  while not blocked_path do
    local other_piece = piece:findByCoords(x + x_aux, y)
    if level.tileData[x + x_aux][y] == 1 then
      if other_piece ~= nil then
        if other_piece.color == color then
          blocked_path = true
          x_aux = 1
        else
          table.insert(the_piece.possibleMoves, tile:findByCoords(x + x_aux, y))
          blocked_path = true
          x_aux = 1
        end
      else
        table.insert(the_piece.possibleMoves, tile:findByCoords(x + x_aux, y))
        if max_distance == nil then
          x_aux = x_aux + 1
        elseif x_aux < max_distance then
          x_aux = x_aux + 1
        else
          blocked_path = true
          x_aux = 1
        end
      end
    else
      blocked_path = true
      x_aux = 1
    end
  end
  --moving up
  blocked_path = false
  while not blocked_path do
    local other_piece = piece:findByCoords(x, y - y_aux)
    if level.tileData[x][y - y_aux] == 1 then
      if other_piece ~= nil then
        if other_piece.color == color then
          blocked_path = true
          y_aux = 1
        else
          table.insert(the_piece.possibleMoves, tile:findByCoords(x, y - y_aux))
          blocked_path = true
          y_aux = 1
        end
      else
        table.insert(the_piece.possibleMoves, tile:findByCoords(x, y - y_aux))
        if max_distance == nil then
          y_aux = y_aux + 1
        elseif y_aux < max_distance then
          y_aux = y_aux + 1
        else
          blocked_path = true
          y_aux = 1
        end
      end
    else
      blocked_path = true
      y_aux = 1
    end
  end
  --moving down
  blocked_path = false
  while not blocked_path do
    local other_piece = piece:findByCoords(x, y + y_aux)
    if level.tileData[x][y + y_aux] == 1 then
      if other_piece ~= nil then
        if other_piece.color == color then
          blocked_path = true
          y_aux = 1
        else
          table.insert(the_piece.possibleMoves, tile:findByCoords(x, y + y_aux))
          blocked_path = true
          y_aux = 1
        end
      else
        table.insert(the_piece.possibleMoves, tile:findByCoords(x, y + y_aux))
        if max_distance == nil then
          y_aux = y_aux + 1
        elseif y_aux < max_distance then
          y_aux = y_aux + 1
        else
          blocked_path = true
          y_aux = 1
        end
      end
    else
      blocked_path = true
      y_aux = 1
    end
  end
end

function piece:calculateDiagonalMoves(the_piece, max_distance)
  local x = the_piece.x
  local y = the_piece.y
  local color = the_piece.color
  local blocked_path = false
  local x_aux = 1
  local y_aux = 1
  --moving diagonally left-up
  blocked_path = false
  while not blocked_path do
    local other_piece = piece:findByCoords(x - x_aux, y - y_aux)
    if level.tileData[x - x_aux][y - y_aux] == 1 then
      if other_piece ~= nil then
        if other_piece.color == color then
          blocked_path = true
          x_aux = 1
          y_aux = 1
        else
          table.insert(the_piece.possibleMoves, tile:findByCoords(x - x_aux, y - y_aux))
          blocked_path = true
          x_aux = 1
          y_aux = 1
        end
      else
        table.insert(the_piece.possibleMoves, tile:findByCoords(x - x_aux, y - y_aux))
        if max_distance == nil then
          x_aux = x_aux + 1
          y_aux = y_aux + 1
        elseif x_aux < max_distance then
          x_aux = x_aux + 1
          y_aux = y_aux + 1
        else
          blocked_path = true
          x_aux = 1
          y_aux = 1
        end
      end
    else
      blocked_path = true
      x_aux = 1
      y_aux = 1
    end
  end
  --moving diagonally right-up
  blocked_path = false
  while not blocked_path do
    local other_piece = piece:findByCoords(x + x_aux, y - y_aux)
    if level.tileData[x + x_aux][y - y_aux] == 1 then
      if other_piece ~= nil then
        if other_piece.color == color then
          blocked_path = true
          x_aux = 1
          y_aux = 1
        else
          table.insert(the_piece.possibleMoves, tile:findByCoords(x + x_aux, y - y_aux))
          blocked_path = true
          x_aux = 1
          y_aux = 1
        end
      else
        table.insert(the_piece.possibleMoves, tile:findByCoords(x + x_aux, y - y_aux))
        if max_distance == nil then
          x_aux = x_aux + 1
          y_aux = y_aux + 1
        elseif x_aux < max_distance then
          x_aux = x_aux + 1
          y_aux = y_aux + 1
        else
          blocked_path = true
          x_aux = 1
          y_aux = 1
        end
      end
    else
      blocked_path = true
      x_aux = 1
      y_aux = 1
    end
  end
  --moving diagonally left-down
  blocked_path = false
  while not blocked_path do
    local other_piece = piece:findByCoords(x - x_aux, y + y_aux)
    if level.tileData[x - x_aux][y + y_aux] == 1 then
      if other_piece ~= nil then
        if other_piece.color == color then
          blocked_path = true
          x_aux = 1
          y_aux = 1
        else
          table.insert(the_piece.possibleMoves, tile:findByCoords(x - x_aux, y + y_aux))
          blocked_path = true
          x_aux = 1
          y_aux = 1
        end
      else
        table.insert(the_piece.possibleMoves, tile:findByCoords(x - x_aux, y + y_aux))
        if max_distance == nil then
          x_aux = x_aux + 1
          y_aux = y_aux + 1
        elseif x_aux < max_distance then
          x_aux = x_aux + 1
          y_aux = y_aux + 1
        else
          blocked_path = true
          x_aux = 1
          y_aux = 1
        end
      end
    else
      blocked_path = true
      x_aux = 1
      y_aux = 1
    end
  end
  --moving diagonally right-down
  blocked_path = false
  while not blocked_path do
    local other_piece = piece:findByCoords(x + x_aux, y + y_aux)
    if level.tileData[x + x_aux][y + y_aux] == 1 then
      if other_piece ~= nil then
        if other_piece.color == color then
          blocked_path = true
          x_aux = 1
          y_aux = 1
        else
          table.insert(the_piece.possibleMoves, tile:findByCoords(x + x_aux, y + y_aux))
          blocked_path = true
          x_aux = 1
          y_aux = 1
        end
      else
        table.insert(the_piece.possibleMoves, tile:findByCoords(x + x_aux, y + y_aux))
        if max_distance == nil then
          x_aux = x_aux + 1
          y_aux = y_aux + 1
        elseif x_aux < max_distance then
          x_aux = x_aux + 1
          y_aux = y_aux + 1
        else
          blocked_path = true
          x_aux = 1
          y_aux = 1
        end
      end
    else
      blocked_path = true
      x_aux = 1
      y_aux = 1
    end
  end
end

function piece:calculateMove(the_piece, x_offset, y_offset, cannot_capture, can_only_capture)
  local x = the_piece.x
  local y = the_piece.y
  local color = the_piece.color
  local other_piece = piece:findByCoords(x + x_offset, y + y_offset)
  if level.tileData[x + x_offset][y + y_offset] == 1 then
    if other_piece ~= nil then
      if other_piece.color ~= color and not cannot_capture then
        table.insert(the_piece.possibleMoves, tile:findByCoords(x + x_offset, y + y_offset))
        return true
      end
    elseif not can_only_capture then
      table.insert(the_piece.possibleMoves, tile:findByCoords(x + x_offset, y + y_offset))
      return true
    end
  end
  return false
end

--returns a table with all the possible tiles the piece can move to
function piece:calculatePossibleMoves(the_piece)
  the_piece.possibleMoves = {}
  local type = the_piece.type
  local color = the_piece.color

  if type == "rook" then
    piece:calculateHorizontalVerticalMoves(the_piece)
  elseif type == "bishop" then
    piece:calculateDiagonalMoves(the_piece)
  elseif type == "queen" then
    piece:calculateHorizontalVerticalMoves(the_piece)
    piece:calculateDiagonalMoves(the_piece)
  elseif type == "king" then
    piece:calculateHorizontalVerticalMoves(the_piece, 1)
    piece:calculateDiagonalMoves(the_piece, 1)
  elseif type == "knight" then
    piece:calculateMove(the_piece, 1, 2)
    piece:calculateMove(the_piece, -1, 2)
    piece:calculateMove(the_piece, 1, -2)
    piece:calculateMove(the_piece, -1, -2)
    piece:calculateMove(the_piece, 2, 1)
    piece:calculateMove(the_piece, -2, 1)
    piece:calculateMove(the_piece, 2, -1)
    piece:calculateMove(the_piece, -2, -1)
  elseif type == "pawn" then
    if color == "white" then
      if piece:calculateMove(the_piece, 0, -1, true) and the_piece.moves == 0 then
        piece:calculateMove(the_piece, 0, -2, true)
      end
      piece:calculateMove(the_piece, 1, -1, false, true)
      piece:calculateMove(the_piece, -1, -1, false, true)
    else
      if piece:calculateMove(the_piece, 0, 1, true) and the_piece.moves == 0 then
        piece:calculateMove(the_piece, 0, 2, true)
      end
      piece:calculateMove(the_piece, 1, 1, false, true)
      piece:calculateMove(the_piece, -1, 1, false, true)
    end
  end

end

function piece:isPossibleMove(the_piece, x, y)
  for i = 1, #the_piece.possibleMoves do
    if x == the_piece.possibleMoves[i].x and y == the_piece.possibleMoves[i].y then
      return true
    end
  end
  return false
end

function piece:tryPromotingPawn(the_piece)
  if the_piece.color == "white" then
    if level.tileData[the_piece.x][the_piece.y-1] == 0 then
      piece:setPieceTypeColorSprite(the_piece, "queen")
    end
  else
    if level.tileData[the_piece.x][the_piece.y+1] == 0 then
      piece:setPieceTypeColorSprite(the_piece, "queen")
    end
  end
end

function piece:mouseClick(x, y)
  for i = 1, #level.objects.tiles do
    if x > level.objects.tiles[i].sx and y > level.objects.tiles[i].sy and x < level.objects.tiles[i].sx + sprites_1.width and y < level.objects.tiles[i].sy + sprites_1.height then
      local found_piece = piece:findByCoords(level.objects.tiles[i].x, level.objects.tiles[i].y)
      if found_piece ~= nil then
        if found_piece.color ~= "white" then
          found_piece = nil
        end
      end
      if level.objects.selectedPiece == nil then
        if found_piece ~= nil then
          level.objects.selectedPiece = found_piece
          piece:calculatePossibleMoves(level.objects.selectedPiece)
        end
      else
        if piece:isPossibleMove(level.objects.selectedPiece, level.objects.tiles[i].x, level.objects.tiles[i].y) then
          piece:move(level.objects.selectedPiece, level.objects.tiles[i])
          if level.objects.tiles[i].is_goal then
            --load de next level
            inventory:update()
            board.color = 2
            level:new(level.w, level.h)
            current_state = "player_turn"
          elseif #level.objects.enemyPieces > 0 then
            current_state = "enemy_turn"
          end
        end
        level.objects.selectedPiece = nil
      end
      return
    end
  end
  level.objects.selectedPiece = nil
end
