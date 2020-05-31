function loadFonts()
  font = {}

  font["mono16"] = love.graphics.newImageFont("resources/fonts/font1.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 :-!.,\"?>_", 0)
  font["mono16"]:setLineHeight(1)

  love.graphics.setFont(font["mono16"])
end
