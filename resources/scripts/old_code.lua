spriteSheets = {"sprite_sheet_black.png","sprite_sheet_green.png","sprite_sheet_pink.png","sprite_sheet_test.png","sprite_sheet_test2.png","sprite_sheet_test3.png"}

--takes the sprite sheet and divides it into quads
function loadSpriteSheet(i)
  --sprite_sheet = love.graphics.newImage("resources/sprites/sprite_sheet.png")
  sprite_sheet = love.graphics.newImage("resources/sprites/"..spriteSheets[i])
  sprite_sheet_image_data = love.image.newImageData("resources/sprites/"..spriteSheets[i])
  --sprite sheet is divided in 14x9px sprites
  --14x27px sprites for the first row and 14x9px sprites on the other
  sprites_medium = {} --14x27px

  --in case I decide to change tile proportions (width, height)
  sprites_medium.width = 22
  sprites_medium.height = 22
  y_draw_offset = 0

  for i = 0, sprite_sheet:getWidth()/sprites_medium.width  do
    table.insert(sprites_medium, love.graphics.newQuad(i*sprites_medium.width, 0, sprites_medium.width, sprites_medium.height, sprite_sheet:getDimensions()))
  end

  sprites_small = {} --14x9px

  --in case I decide to change tile proportions (width, height)
  sprites_small.width = 22
  sprites_small.height = 22

  for i = 0, sprite_sheet:getWidth()/sprites_small.width do
    table.insert(sprites_small, love.graphics.newQuad(i*sprites_small.width, sprites_medium.height, sprites_small.width, sprites_small.height, sprite_sheet:getDimensions()))
  end

  bg_color_r, bg_color_g, bg_color_b = sprite_sheet_image_data:getPixel(sprites_small.width*10, sprites_medium.height)
end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
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

        local up_up = tileData[col][row-2]

        if (left == 1 or up == 1 or right == 1 or down == 1) and up == 0 and (up_left == 1 or up_right == 1 or up_up == 1) then
          wall:new(col, row, sprites_1[board.color][17])
        elseif (left == 1 or up == 1 or right == 1 or down == 1) then
          wall:new(col, row, sprites_1[board.color][18])
        end
      end
    end
  end
end
