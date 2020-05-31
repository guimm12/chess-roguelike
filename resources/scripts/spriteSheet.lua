--takes the sprite sheet and divides it into quads
function loadSpriteSheet()
  sprite_sheet = love.graphics.newImage("resources/sprites/sprite_sheet.png")
  sprite_sheet_image_data = love.image.newImageData("resources/sprites/sprite_sheet.png")

  sprites_1 = {}
  bg_color_r = {}
  bg_color_g = {}
  bg_color_b = {}

  --in case I decide to change tile proportions (width, height)
  sprites_1.width = 22
  sprites_1.height = 22
  y_draw_offset = 0

  for y = 0, (sprite_sheet:getHeight()/22)-1  do
    sprites_1[y+1] = {}
    bg_color_r[y+1], bg_color_g[y+1], bg_color_b[y+1] = sprite_sheet_image_data:getPixel(sprites_1.width*18, sprites_1.height*y) -- 1, 1, 1
    for x = 0, (sprite_sheet:getWidth()/22)-1 do
      sprites_1[y+1][x+1] = love.graphics.newQuad(x*sprites_1.width, y*sprites_1.height, sprites_1.width, sprites_1.height, sprite_sheet:getDimensions())
    end
  end
end
