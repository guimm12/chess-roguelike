tile = {}

function tile:new(x, y, sprite, detail_sprite)
  local new_tile = {}
  new_tile.x = x
  new_tile.y = y
  new_tile.sprite = sprite
  new_tile.detail_sprite = detail_sprite
  new_tile.sx = math.floor(x*sprites_1.width-sprites_1.width + board.x)
  new_tile.sy = math.floor(y*sprites_1.height-sprites_1.height + board.y)
  table.insert(level.objects.tiles, new_tile)
  return new_tile
end

function tile:update()
  for i = 1, #level.objects.tiles do
    level.objects.tiles[i].sx = math.floor(level.objects.tiles[i].x*sprites_1.width-sprites_1.width + board.x + .5)
    level.objects.tiles[i].sy = math.floor(level.objects.tiles[i].y*sprites_1.height-sprites_1.height + board.y + .5)
  end
end

function tile:draw()
  for i = 1, #level.objects.tiles do
    if (level.objects.tiles[i].y*(sprites_1.height-6)-screen_height/scale < -board.y) and (level.objects.tiles[i].y*sprites_1.height > -board.y) and
    (level.objects.tiles[i].x*(sprites_1.width-6)-screen_width/scale < -board.x) and (level.objects.tiles[i].x*sprites_1.width > -board.x) then
      tile:drawTile(i)
    end
  end
end

function tile:drawTile(_index)
  love.graphics.draw(sprite_sheet, level.objects.tiles[_index].sprite, level.objects.tiles[_index].sx, level.objects.tiles[_index].sy)
  if level.objects.tiles[_index].detail_sprite ~= nil then
    love.graphics.draw(sprite_sheet, level.objects.tiles[_index].detail_sprite, level.objects.tiles[_index].sx, level.objects.tiles[_index].sy)
  end
end

function tile:findByCoords(x, y)
  for i = 1, #level.objects.tiles do
    if level.objects.tiles[i].x == x and level.objects.tiles[i].y == y then
      return level.objects.tiles[i]
    end
  end
  return nil
end
