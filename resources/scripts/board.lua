--Board
board = {}
board.x = 0
board.y = 0
board.color = 2

function board:centerBoard(w, h)
  board.x = (canvas_width - (w+2)*sprites_1.width)/2
  board.y = (canvas_height - (h+2)*sprites_1.height)/2
end

function board:update(dt)
  local camera_speed = 440
  if love.keyboard.isDown("left") and love.keyboard.isDown("up") then
    board.x = board.x + (camera_speed / math.sqrt(2)) * dt
    board.y = board.y + (camera_speed / math.sqrt(2)) * dt
  elseif love.keyboard.isDown("right") and love.keyboard.isDown("up") then
    board.x = board.x - (camera_speed / math.sqrt(2)) * dt
    board.y = board.y + (camera_speed / math.sqrt(2)) * dt
  elseif love.keyboard.isDown("left") and love.keyboard.isDown("down") then
    board.x = board.x + (camera_speed / math.sqrt(2)) * dt
    board.y = board.y - (camera_speed / math.sqrt(2)) * dt
  elseif love.keyboard.isDown("right") and love.keyboard.isDown("down") then
    board.x = board.x - (camera_speed / math.sqrt(2)) * dt
    board.y = board.y - (camera_speed / math.sqrt(2)) * dt
  elseif love.keyboard.isDown("up") then
    board.y = board.y + camera_speed * dt
  elseif love.keyboard.isDown("down") then
    board.y = board.y - camera_speed * dt
  elseif love.keyboard.isDown("left") then
    board.x = board.x + camera_speed * dt
  elseif love.keyboard.isDown("right") then
    board.x = board.x - camera_speed * dt
  end
end
