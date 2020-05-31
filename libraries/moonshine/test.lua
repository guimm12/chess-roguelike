return function(moonshine)
  local shader = love.graphics.newShader[[
		extern number intensity = .1;
		extern number aspeed = .1;
		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
			vec2 speed = vec2(aspeed, 0.0);
			vec2 offset = intensity * speed;
			vec4 c = vec4(0.);
			number inc = 0.1;
			number weight = 0.;
			for (number i = 0.; i <= .3; i += inc)
			{
				c += Texel(texture, texture_coords + i * offset).rgba;
				weight += 1.;
			}
			c /= weight;
			return c;
		}
	]]

  local defaults = {

  }

  return moonshine.Effect{
    name = "test",
    shader = shader,
    setters = setters,
    defaults = defaults
  }
end
