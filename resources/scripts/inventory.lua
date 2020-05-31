inventory = {}

function inventory:init()
  inventory.pieces = {}

  for i = 1, 1 do
    table.insert(inventory.pieces, piece:new(0, 0, piece.types[love.math.random(5)+1], "white", love.math.random(9), love.math.random(3)-1))
  end
end

--not meant to be executed every frame, only when needed
function inventory:update()
  inventory.pieces = {}
  if #level.objects.playerPieces > 0 then
    for i = 1, #level.objects.playerPieces do
      table.insert(inventory.pieces, level.objects.playerPieces[i])
    end
  end
end

function inventory:draw()
  inventory:drawPieceListGUI()
end

function inventory:drawPieceListGUI()
  if #inventory.pieces > 0 then
    for i = 1, #inventory.pieces do
      love.graphics.draw(sprite_sheet, inventory.pieces[i].sprite, 10, i*sprites_1.height+30)
    end
  end
end
