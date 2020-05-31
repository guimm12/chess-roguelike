function resizeCanvas(w, h)
  window_width = w
  window_height = h

  local aspect_game = canvas_width / canvas_height
  local aspect_window = window_width / window_height

  local sw, sh = window_width / canvas_width, window_height / canvas_height
  if aspect_window >= aspect_game then
  	draw_scale = sh
  else
  	draw_scale = sw
  end

  local hSpace = window_width - (canvas_width * draw_scale)
  local vSpace = window_height - (canvas_height * draw_scale)
  draw_offset_horizontal = hSpace / 2
  draw_offset_vertical = vSpace / 2
end
