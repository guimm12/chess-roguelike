wall = {}

function wall:new(x, y, sprite)
  local new_wall = {}
  new_wall.x = x
  new_wall.y = y
  new_wall.sprite = sprite
  new_wall.sx = math.floor(x*sprites_1.width-sprites_1.width + board.x)
  new_wall.sy = math.floor(y*sprites_1.height-sprites_1.height + board.y)
  table.insert(level.objects.walls, new_wall)
end

function wall:update()
  for i = 1, #level.objects.walls do
    level.objects.walls[i].sx = math.floor(level.objects.walls[i].x*sprites_1.width-sprites_1.width + board.x + .5)
    level.objects.walls[i].sy = math.floor(level.objects.walls[i].y*sprites_1.height-sprites_1.height + board.y + .5)
  end
end

function wall:draw()
  for i = 1, #level.objects.walls do
    if (level.objects.walls[i].y*(sprites_1.height-6)-screen_height/scale < -board.y) and (level.objects.walls[i].y*sprites_1.height > -board.y) and
    (level.objects.walls[i].x*(sprites_1.width-6)-screen_width/scale < -board.x) and (level.objects.walls[i].x*sprites_1.width > -board.x) then
      wall:drawWall(i)
    end
  end
end

function wall:drawWall(_index)
  love.graphics.draw(sprite_sheet, level.objects.walls[_index].sprite, level.objects.walls[_index].sx, level.objects.walls[_index].sy)
end
