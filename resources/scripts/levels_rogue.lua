levels = {}

rooms = {
  [1] = { {2,2,2,2,2,2,2},
          {2,1,1,1,1,1,2},
          {2,1,1,1,1,1,2},
          {2,1,1,1,1,1,2},
          {2,2,2,2,2,2,2}},
  [2] = { {2,2,2,2,2},
          {2,1,1,1,2},
          {2,1,1,1,2},
          {2,1,1,1,2},
          {2,2,2,2,2}},
  [3] = { {2,2,2,2,2,2,2},
          {2,2,1,1,1,2,2},
          {2,1,1,1,1,1,2},
          {2,1,1,1,1,1,2},
          {2,2,1,1,1,2,2},
          {2,2,2,2,2,2,2}},
  [4] = { {2,2,2,2,2,2},
          {2,1,1,1,1,2},
          {2,1,1,2,1,2},
          {2,1,1,1,1,2},
          {2,2,2,2,2,2}},
  [5] = { {2,2,2,2,2,2,2},
          {2,1,1,1,1,1,2},
          {2,2,1,1,1,2,2},
          {2,1,1,1,1,1,2},
          {2,1,1,1,1,1,2},
          {2,2,2,2,2,2,2}},
}

empty_tile = 2

function levels:new(w, h)
  local new_level = {}
  new_level.w = w
  new_level.h = h
  new_level.tileData = {}

  board:centerBoard(w, h)

  --creating a clean level with no tileData
  for col = 1, w do
    new_level.tileData[col] = {}
    for row = 1, h do
      new_level.tileData[col][row] = empty_tile
    end
  end

  --starter room
  --levels:fillRect(new_level, w/2-2, h/2-1, w/2+3, h/2+1, 1)
  levels:fillRect(new_level, 2, 2, 3, 3, 1)

  --adding rooms
  for i = 1, 1000 do
    --picking a wall
    local is_wall = false
    while not is_wall do
      local random_tile = {x = love.math.random(2, w-1), y = love.math.random(2, h-1)}
      if  new_level.tileData[random_tile.x][random_tile.y] == empty_tile and
          (new_level.tileData[random_tile.x+1][random_tile.y] == 1 or
          new_level.tileData[random_tile.x][random_tile.y+1] == 1 or
          new_level.tileData[random_tile.x-1][random_tile.y] == 1 or
          new_level.tileData[random_tile.x][random_tile.y-1] == 1)
      then
        is_wall = true
        --choosing a room
        new_room = rooms[love.math.random(#rooms)]
        --checking if the new room can fit
        if levels:hasSpaceForRoom(new_level, random_tile.x, random_tile.y-2, new_room) then
          --draw the room
          levels:drawRoom(new_level, random_tile.x, random_tile.y-2, new_room)
          --making the wall a entrance for the new room
          new_level.tileData[random_tile.x][random_tile.y] = 1
        elseif levels:hasSpaceForRoom(new_level, random_tile.x-2, random_tile.y, new_room) then
          --draw the room
          levels:drawRoom(new_level, random_tile.x-2, random_tile.y, new_room)
          --making the wall a entrance for the new room
          new_level.tileData[random_tile.x][random_tile.y] = 1
        elseif levels:hasSpaceForRoom(new_level, random_tile.x-3, random_tile.y, new_room) then
          --draw the room
          levels:drawRoom(new_level, random_tile.x-3, random_tile.y, new_room)
          --making the wall a entrance for the new room
          new_level.tileData[random_tile.x][random_tile.y] = 1
        end
      end
    end
  end

  --creating the tiles using the level tile data
  for col = 1, w do
    for row = 1, h do
      if new_level.tileData[col][row] ~= 0 then
        tiles:new(col, row, sprites_small[new_level.tileData[col][row]])
      end
    end
  end

  table.insert(levels, new_level)
end

function levels:fillRect(level, x1, y1, x2, y2, n)
  for col = x1, x2 do
    for row = y1, y2 do
      level.tileData[col][row] = n
    end
  end
end

function levels:isEmpty(level, x1, y1, x2, y2)
  for col = x1, x2 do
    for row = y1, y2 do
      if level.tileData[col][row] ~= empty_tile then
        return false
      end
    end
  end
  return true
end

function levels:hasSpaceForRoom(level, x, y, room)
  if not (x + #room[1] > level.w or y + #room > level.h or x < 1 or y < 1) and levels:isEmpty(level, x, y, x + #room[1], y + #room) then
    return true
  end
  return false
end

function levels:drawRoom(level, x1, y1, room)
  local x2 = x1 + #room[1] - 1
  local y2 = y1 + #room - 1
  for col = x1, x2 do
    for row = y1, y2 do
      level.tileData[col][row] = room[row-y1+1][col-x1+1]
    end
  end
end
