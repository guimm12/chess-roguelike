require("resources/scripts/canvas")
require("resources/scripts/fonts")
require("resources/scripts/spriteSheet")
require("resources/scripts/board")
require("resources/scripts/level")
require("resources/scripts/tile")
require("resources/scripts/wall")
require("resources/scripts/piece")
require("resources/scripts/FSM")
require("resources/scripts/inventory")
Moonshine = require("libraries/moonshine")
--Rogue-like map generation
ROT = require ("libraries/rotLove/rot")
--Path Finding
Grid = require ("libraries/jumper.grid")
Pathfinder = require ("libraries/jumper.pathfinder")

debug_text = ""

function love.load()
  --Screen/Canvas Settings
  fullscreen = true
  scale = 2
  love.window.setMode(0, 0, {fullscreen = true, vsync = false})
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
  local width = screen_width / scale
  local height = screen_height / scale
  canvas_width = width
  canvas_height = height
  window_width = width * scale
  window_height = height * scale
  canvas = love.graphics.newCanvas(canvas_width, canvas_height)
  canvas:setFilter("nearest", "nearest")
  love.window.setMode(screen_width, screen_height, {resizable=true, vsync=false, minwidth=window_width, minheight=window_height})
  resizeCanvas(screen_width, screen_height)
  --Sprite Sheet Settings
  loadSpriteSheet()
  --Font Settings
  loadFonts()

  inventory:init()

  level:new(24, 16) --40, 22
end

function love.update(dt)
  game_states[current_state].update(dt)
end

function love.draw()
  love.graphics.setFont(font["mono16"])
  love.graphics.setCanvas(canvas) --Start drawing on canvas
  game_states[current_state].draw()
  love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  love.graphics.print(debug_text, 10, 20)
  love.graphics.setCanvas() --Stop drawing on canvas

  love.graphics.draw(canvas, draw_offset_horizontal, draw_offset_vertical, 0, draw_scale, draw_scale)
end

function love.keypressed(key)
  game_states[current_state].keypressed(key)
end

function love.resize(w, h)
  resizeCanvas(w, h)
end

function love.mousepressed(x, y, button)
  x = ((x - draw_offset_horizontal) / draw_scale)
  y = ((y - draw_offset_vertical) / draw_scale)
  game_states[current_state].mousepressed(x, y, button)
end
