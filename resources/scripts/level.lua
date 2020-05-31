level = {}
level.w = w
level.h = h
level.tileData = {}

level.objects = {}
level.objects.tiles = {}
level.objects.walls = {}
level.objects.pieces = {}
level.objects.playerPieces = {}
level.objects.enemyPieces = {}
level.objects.capturedPieces = {}

function level:new(w, h)
  level.w = w
  level.h = h
  level.tileData = {}

  level.objects = {}
  level.objects.tiles = {}
  level.objects.walls = {}
  level.objects.pieces = {}
  level.objects.playerPieces = {}
  level.objects.enemyPieces = {}
  level.objects.capturedPieces = {}

  board:centerBoard(w, h)

  --Roguelike map generator settings
  level.rogue_map = ROT.Map.Rogue(w, h, {cellWidth = math.floor(w/8), cellHeight = math.floor(h/4), roomWidth = {2,4}, roomHeight = {2,4}})

  level.tileData = level:generateTileData(level.tileData, w, h)

  level:spawnTiles(level.tileData)
  level:spawnWalls(level.tileData)
  level:spawnPieces(level.tileData)

  level.objects.selectedPiece = nil
end

function level:generateTileData(tileData, w, h)
  --creating a full tileData table
  for col = 1, w+2 do
    tileData[col] = {}
    for row = 1, h+2 do
      if col <= 2 or row <= 2 or col >= w-1 or row >= h-1 then
        tileData[col][row] = 0
      end
    end
  end

  local can_reach_goal = false
  while not can_reach_goal do

    level.rogue_map:create(callback)

    for x = 2, #tileData-2 do
      for y = 2, #tileData[1]-2 do
        if level.rogue_map.map[x-1][y-1] == 1 then
          tileData[x][y] = 0
        else
          tileData[x][y] = 1
        end
      end
    end

    --Path finding
    local grid = Grid(tileData)
    local myFinder = Pathfinder(grid, 'JPS', 1)

    local startX, startY, goalX, goalY
    local goal_is_tile = false
    while not goal_is_tile do
      startX, startY, goalX, goalY = love.math.random(level.w), love.math.random(level.h), love.math.random(level.w), love.math.random(level.h)
      if tileData[startX][startY] == 1 and tileData[goalX][goalY] == 1 then
        goal_is_tile = true
      end
    end

    level.goalX, level.goalY = goalX, goalY
    level.startX, level.startY = startX, startY

    local path = myFinder:getPath(startY, startX, goalY, goalX)
    if path then
      debug_text = ("Path's length: %.2f"):format(path:getLength())
      level.objects.walls = {}
      for node, count in path:nodes() do
        --wall:new(node:getY(), node:getX(), sprites_1[board.color][75])
      end
      if path:getLength() > 30 then --100 -30
        can_reach_goal = true
      end
    end
  end

  return tileData
end

function level:spawnTiles(tileData)
  --creating the tiles using the level tile data
  --also alternating the tiles (black/white)
  local alt = .5
  for col = 1, #tileData do
    alt = alt * -1
    for row = 1, #tileData[1] do
      alt = alt * -1
      if tileData[col][row] ~= 0 then
        local left = tileData[col-1][row]
        local up = tileData[col][row-1]
        local right = tileData[col+1][row]
        local down = tileData[col][row+1]

        local up_left = tileData[col-1][row-1]
        local up_right = tileData[col+1][row-1]
        local down_left = tileData[col-1][row+1]
        local down_right = tileData[col+1][row+1]

        --choses if it has extra detail (like pebbles) or not
        local detail_sprite = nil
        if love.math.random(100)<20 then
          detail_sprite = sprites_1[board.color][78+alt+love.math.random(8)*2+.5]
        end

        if level.goalX == col and level.goalY == row then
          local goal_tile = tile:new(col, row, sprites_1[board.color][tileData[col][row]+alt+77.5])
          goal_tile.is_goal = true
        elseif up_right == 1 and right == 0 and up == 0 then
          tile:new(col, row, sprites_1[board.color][tileData[col][row]+alt+14.5], detail_sprite)
        elseif up_right == 1 and right == 0 then
          tile:new(col, row, sprites_1[board.color][tileData[col][row]+alt+12.5], detail_sprite)
        elseif up_right == 1 and up == 0 then
          tile:new(col, row, sprites_1[board.color][tileData[col][row]+alt+10.5], detail_sprite)
        elseif right == 1 and up == 1 and up_right == 0 then
          tile:new(col, row, sprites_1[board.color][tileData[col][row]+alt+8.5], detail_sprite)
        elseif right == 0 and up == 0 then
          tile:new(col, row, sprites_1[board.color][tileData[col][row]+alt+6.5], detail_sprite)
        elseif right == 0 then
          tile:new(col, row, sprites_1[board.color][tileData[col][row]+alt+4.5], detail_sprite)
        elseif up == 0 then
          tile:new(col, row, sprites_1[board.color][tileData[col][row]+alt+2.5], detail_sprite)
        else
          tile:new(col, row, sprites_1[board.color][tileData[col][row]+alt+.5], detail_sprite)
        end
      end
    end
  end
end

function level:spawnWalls(tileData)
  --creating the walls arround the tiles (with the correct sprites)
  for col = 1, #tileData do
    for row = 1, #tileData[1] do
      if tileData[col][row] == 0 and not(col == 1 or row == 1 or col == #tileData or row == #tileData[1]) then
        local left = tileData[col-1][row]
        local up = tileData[col][row-1]
        local right = tileData[col+1][row]
        local down = tileData[col][row+1]

        local up_left = tileData[col-1][row-1]
        local up_right = tileData[col+1][row-1]
        local down_left = tileData[col-1][row+1]
        local down_right = tileData[col+1][row+1]

        if left == 1 and up == 1 and right == 1 and down == 1 then
          wall:new(col, row, sprites_1[board.color][18])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_left == 1 and up_right == 1 and down_left == 1 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][54])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_left == 0 and up_right == 1 and down_left == 1 and down_right == 0 then
          wall:new(col, row, sprites_1[board.color][63])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_left == 1 and up_right == 0 and down_left == 0 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][64])
        elseif right == 0 and up == 0 and left == 1 and down == 0 and up_right == 1 and down_right == 0 then
          wall:new(col, row, sprites_1[board.color][55])
        elseif right == 0 and up == 0 and left == 1 and down == 0 and up_right == 0 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][56])
        elseif right == 1 and up == 0 and left == 0 and down == 0 and up_left == 1 and down_left == 0 then
          wall:new(col, row, sprites_1[board.color][57])
        elseif right == 1 and up == 0 and left == 0 and down == 0 and up_left == 0 and down_left == 1 then
          wall:new(col, row, sprites_1[board.color][58])
        elseif right == 0 and up == 1 and left == 0 and down == 0 and down_left == 1 and down_right == 0 then
          wall:new(col, row, sprites_1[board.color][59])
        elseif right == 0 and up == 1 and left == 0 and down == 0 and down_left == 0 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][60])
        elseif right == 0 and up == 0 and left == 0 and down == 1 and up_left == 1 and up_right == 0 then
          wall:new(col, row, sprites_1[board.color][61])
        elseif right == 0 and up == 0 and left == 0 and down == 1 and up_left == 0 and up_right == 1 then
          wall:new(col, row, sprites_1[board.color][62])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_left == 1 and up_right == 1 and down_left == 0 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][50])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_left == 1 and up_right == 1 and down_left == 1 and down_right == 0 then
          wall:new(col, row, sprites_1[board.color][51])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_left == 0 and up_right == 1 and down_left == 1 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][52])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_left == 1 and up_right == 0 and down_left == 1 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][53])
        elseif right == 0 and up == 0 and left == 1 and down == 0 and up_right == 1 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][46])
        elseif right == 1 and up == 0 and left == 0 and down == 0 and up_left == 1 and down_left == 1 then
          wall:new(col, row, sprites_1[board.color][47])
        elseif right == 0 and up == 1 and left == 0 and down == 0 and down_right == 1 and down_left == 1 then
          wall:new(col, row, sprites_1[board.color][48])
        elseif right == 0 and up == 0 and left == 0 and down == 1 and up_right == 1 and up_left == 1 then
          wall:new(col, row, sprites_1[board.color][49])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_right == 1 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][42])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_left == 1 and down_left == 1 then
          wall:new(col, row, sprites_1[board.color][43])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and down_right == 1 and down_left == 1 then
          wall:new(col, row, sprites_1[board.color][44])
        elseif right == 0 and up == 0 and left == 0 and down == 0 and up_right == 1 and up_left == 1 then
          wall:new(col, row, sprites_1[board.color][45])
        elseif left == 1 and right == 1 and up == 0 and down == 0 then
          wall:new(col, row, sprites_1[board.color][40])
        elseif up == 1 and down == 1 and left == 0 and right == 0 then
          wall:new(col, row, sprites_1[board.color][41])
        elseif right == 1 and up == 1 and left == 1 and down == 0 then
          wall:new(col, row, sprites_1[board.color][36])
        elseif right == 1 and up == 1 and left == 0 and down == 1 then
          wall:new(col, row, sprites_1[board.color][37])
        elseif right == 1 and up == 0 and left == 1 and down == 1 then
          wall:new(col, row, sprites_1[board.color][38])
        elseif right == 0 and up == 1 and left == 1 and down == 1 then
          wall:new(col, row, sprites_1[board.color][39])
        elseif right == 0 and down == 0 and down_right == 1 and left == 1 and up == 1 then
          wall:new(col, row, sprites_1[board.color][32])
        elseif left == 0 and down == 0 and down_left == 1 and up == 1 and right == 1 then
          wall:new(col, row, sprites_1[board.color][33])
        elseif up == 0 and right == 0 and up_right == 1 and left == 1 and down == 1 then
          wall:new(col, row, sprites_1[board.color][34])
        elseif up == 0 and left == 0 and up_left == 1 and down == 1 and right == 1 then
          wall:new(col, row, sprites_1[board.color][35])
        elseif right == 0 and down == 0 and down_right == 1 then
          wall:new(col, row, sprites_1[board.color][28])
        elseif left == 0 and down == 0 and down_left == 1 then
          wall:new(col, row, sprites_1[board.color][29])
        elseif up == 0 and right == 0 and up_right == 1 then
          wall:new(col, row, sprites_1[board.color][30])
        elseif up == 0 and left == 0 and up_left == 1 then
          wall:new(col, row, sprites_1[board.color][31])
        elseif left == 1 and up == 1 then
          wall:new(col, row, sprites_1[board.color][24])
        elseif up == 1 and right == 1 then
          wall:new(col, row, sprites_1[board.color][25])
        elseif left == 1 and down == 1 then
          wall:new(col, row, sprites_1[board.color][26])
        elseif down == 1 and right == 1 then
          wall:new(col, row, sprites_1[board.color][27])
        elseif left == 1 then
          wall:new(col, row, sprites_1[board.color][20])
        elseif up == 1 then
          wall:new(col, row, sprites_1[board.color][21])
        elseif right == 1 then
          wall:new(col, row, sprites_1[board.color][22])
        elseif down == 1 then
          wall:new(col, row, sprites_1[board.color][23])
        end
      end
    end
  end
end

function level:spawnPieces(tileData)
  if #inventory.pieces > 0 then
    for i = 1, #inventory.pieces do
      inventory.pieces[i].x = level.startX
      inventory.pieces[i].y = level.startY
      piece:setPieceTypeColorSprite(inventory.pieces[i])
      table.insert(level.objects.pieces, inventory.pieces[i])
      table.insert(level.objects.playerPieces, inventory.pieces[i])
    end
  end
  for x = 1, #tileData do
    for y = 1, #tileData[1] do
      if tileData[x][y] == 1 and love.math.random(100)<4 then
        piece:new(x, y, piece.types[love.math.random(5)+1], "black")
      end
    end
  end
end
