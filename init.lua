local iMap = { r = 1, g = 2, b = 3, a = 4 }

---@class Colors
---@field r number
---@field g number
---@field b number
---@field a number
---@field color boolean
local colors = {}
colors.__index = function(t, key)
	return iMap[key] and t[iMap[key]] or colors[key]
end
colors.__newindex = function(t, key, value)
	rawset(t, iMap[key] or key, value)
end

colors._VERSION = "1.1.1"
colors.range = 1

local function clamp(x, min, max)
	if x > max then return max end
	if x < min then return min end
	return x
end

local function lerp(a, b, f)
	return a * (1 - f) + (b * f)
end

local function testNumber(...)
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if type(v) ~= "number" then
			error("Expected number, got " .. type(v), 2)
		end
	end
end

---@param r number|table{ number, number, number, number? } Red value or {r,g,b[,a]}
---@param g? number Green value
---@param b? number Blue value
---@param a? number Alpha value
---@return Colors
function colors.new(r, g, b, a)
	local self = setmetatable({}, colors)
	if r and g and b then
		testNumber(r, g, b)
		self[1] = r
		self[2] = g
		self[3] = b
		self[4] = a or colors.range
	elseif type(r) == "table" then
		testNumber(r[1], r[2], r[3])
		self[1] = r[1]
		self[2] = r[2]
		self[3] = r[3]
		self[4] = r[4] or colors.range
	end
	assert(self[1], "Improper color passed.")
	self.color = true
	return self
end

---@param intensity number float 0-1 of how much to desaturate
function colors:desaturate(intensity)
	local i = (self.r + self.g + self.b) / 3
	local dr, dg, db = i - self.r, i - self.g, i - self.b
	return colors.new(
		self.r + dr * intensity,
		self.g + dg * intensity,
		self.b + db * intensity,
		self.a
	)
end

---@param amount number float 0-1 of how much to lighten
function colors:lighten(amount)
	assert(type(amount) == "number", "amount must be a number")
	return colors.new(
		clamp(self[1] + amount * self.range, 0, self.range),
		clamp(self[2] + amount * self.range, 0, self.range),
		clamp(self[3] + amount * self.range, 0, self.range),
		self[4]
	)
end

---@param amount number float 0-1 of how much to darken
function colors:darken(amount)
	assert(type(amount) == "number", "amount must be a number")
	return colors.new(
		clamp(self[1] - amount * self.range, 0, self.range),
		clamp(self[2] - amount * self.range, 0, self.range),
		clamp(self[3] - amount * self.range, 0, self.range),
		self[4]
	)
end

--- Interpolates between two colors
---@param b Colors The color to interpolate to
---@param f number 0-1f To determine how close to the start or end point
---@return Colors The result of the interpolation
function colors:lerp(b, f)
	return colors.new(
		lerp(self[1], b[1], f),
		lerp(self[2], b[2], f),
		lerp(self[3], b[3], f),
		self.a
	)
end

---@param amount number float 0-1 of how much to alpha
function colors:alpha(amount)
	assert(type(amount) == "number", "amount must be a number")
	return colors.new(
		self[1],
		self[2],
		self[3],
		clamp(amount * self.range, 0, self.range)
	)
end

---@param color Colors Unpack table into individual elements.
---@return number, number, number, number # The R, G, B, A values
function colors.unpack(color)
	return color[1], color[2], color[3], color[4]
end

---@param a Colors
---@param b Colors
---@return Colors
function colors.__add(a, b)
	return colors.new(a[1] + b[1], a[2] + b[2], a[3] + b[3], a[4] + b[4])
end

---@param a Colors
---@param b Colors
---@return Colors
function colors.__sub(a, b)
	return colors.new(a[1] - b[1], a[2] - b[2], a[3] - b[3], a[4] - b[4])
end

---@param a Colors
---@param b Colors
---@return Colors
function colors.__mul(a, b)
	if type(a) == "number" then
		return colors.new(a * b[1], a * b[2], a * b[3], a * b[4])
	elseif type(b) == "number" then
		return colors.new(b * a[1], b * a[2], b * a[3], b * a[4])
	else
		return colors.new(a[1] * b[1], a[2] * b[2], a[3] * b[3], a[4] * b[4])
	end
end

---@param a Colors
---@param b Colors
---@return Colors
function colors.__div(a, b)
	return colors.new(a[1] / b, a[2] / b, a[3] / b, a[4] / b)
end

---@param a Colors
---@param b Colors
---@return boolean
function colors.__eq(a, b)
	for i = 1, 4 do
		if a[i] ~= b[i] then
			return false
		end
	end
	return a.color and b.color
end

---@param a Colors
---@param b Colors
---@return Colors
function colors.average(a, b)
	return colors.new((a[1] + b[1]) / 2, (a[2] + b[2]) / 2, (a[3] + b[3]) / 2, (a[4] + b[4]) / 2)
end

---@param alpha? number alpha to get color.
---@return Colors
function colors.random(alpha)
	return colors.new(math.random(), math.random(), math.random(), alpha or 1)
end

--- Clones a color
---@param a Colors
---@return Colors
function colors.clone(a)
	return colors.new(a:unpack())
end

---@param a Colors
---@return boolean
function colors.isValid(a)
	if type(a) ~= "table" then return false end
	for i = 1, 4 do
		if type(a[i]) ~= "number" then
			return false
		end
	end
	return a.color == true -- ensure boolean return, not nil
end


--[[
	HSL and HSV reference
	https://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
	adapted from http://en.wikipedia.org/wiki/HSL_color_space
	adapted from http://en.wikipedia.org/wiki/HSV_color_space
]]

---Converts an RGB color value to HSL. Conversion formula
---assumes r, g, and b are between 0 and colors.range
---returns h, s, and l in range between 0 and 1f
---@param r number The red color value
---@param g number The green color value
---@param b number The blue color value
---@return table #The HSL representation
function colors.rgbToHsl(r, g, b)
	r, g, b = r / colors.range, g / colors.range, b / colors.range
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h = (max + min) / 2
	local s, l = h, h

	if (max == min) then
		return { 0, 0, l } -- achromatic
	end

	local d = max - min
	s = l > 0.5 and d / (2 - max - min) or d / (max + min)
	if max == r then h = (g - b) / d + (g < b and 6 or 0) end
	if max == g then h = (b - r) / d + 2 end
	if max == b then h = (r - g) / d + 4 end

	return { h / 6, s, l }
end

function colors:hsl()
	return colors.rgbToHsl(self.r, self.g, self.b)
end

local function hue2rgb(p, q, t)
	if t < 0   then t = t + 1 end
	if t > 1   then t = t - 1 end
	if t < 1/6 then return p + (q - p) * 6 * t end
	if t < 1/2 then return q end
	if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
	return p
end


---Converts an HSL color value to RGB. Conversion formula
---assumes h, s, and l are between 0 and 1
---@param h number Hue
---@param s number Saturation
---@param l number Lightness
---@return Colors #The RGB representation
function colors.hslToRgb(h, s, l)
	if s == 0 then
		return colors.new(l * colors.range, l * colors.range, l * colors.range)
	end

	local q = l < 0.5 and l * (1 + s) or l + s - l * s
	local p = 2 * l - q
	local r = hue2rgb(p, q, h + 1/3)
	local g = hue2rgb(p, q, h)
	local b = hue2rgb(p, q, h - 1/3)
	return colors.new(r * colors.range, g * colors.range, b * colors.range)
end


---Converts an RGB color value to HSV. Conversion formula
---Assumes r, g, and b are between 0 and colors.range
---@param r number The red color value
---@param g number The green color value
---@param b number The blue color value
---@return table The HSV representation; Values 0-1f
function colors.rgbToHsv(r, g, b)
	r, g, b = r / colors.range, g / colors.range, b / colors.range
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, v = max, max, max

	local d = max - min
	s = max == 0 and 0 or d / max

	if (max == min) then
		h = 0 -- achromatic
	else
		if max == r then h = (g - b) / d + (g < b and 6 or 0) end
		if max == g then h = (b - r) / d + 2 end
		if max == b then h = (r - g) / d + 4 end
		h = h / 6
	end

	return { h, s, v }
end

function colors:hsv()
	return colors.rgbToHsv(self.r, self.g, self.b)
end


--- Converts an HSV color value to RGB. Conversion formula
--- Assumes h, s, and v are contained in the set [0, 1]
---@param h number Hue
---@param s number Saturation
---@param v number Value
---@return Colors? #The RGB representation
function colors.hsvToRgb(h, s, v)
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s) * colors.range
	local q = v * (1 - f * s) * colors.range
	local t = v * (1 - (1 - f) * s) * colors.range
	v = v * colors.range

	i = i % 6
	if(i == 0) then return colors.new(v, t, p) end
	if(i == 1) then return colors.new(q, v, p) end
	if(i == 2) then return colors.new(p, v, t) end
	if(i == 3) then return colors.new(p, q, v) end
	if(i == 4) then return colors.new(t, p, v) end
	if(i == 5) then return colors.new(v, p, q) end
end



-- colors in order from wikipedia web colors
colors.white = colors.new(1, 1, 1)
colors.silver = colors.new(0.75, 0.75, 0.75)
colors.gray = colors.new(0.5, 0.5, 0.5)
colors.black = colors.new(0, 0, 0)
colors.red = colors.new(1, 0, 0)
colors.maroon = colors.new(0.5, 0, 0)
colors.yellow = colors.new(1, 1, 0)
colors.olive = colors.new(0.5, 0.5, 0)
colors.lime = colors.new(0, 1, 0)
colors.green = colors.new(0, 0.5, 0)
colors.aqua = colors.new(0, 1, 1)
colors.teal = colors.new(0, 0.5, 0.5)
colors.blue = colors.new(0, 0, 1)
colors.navy = colors.new(0, 0, 0.5)
colors.fuchsia = colors.new(1, 0, 1)
colors.purple = colors.new(0.5, 0, 0.5)

-- extras

--
colors.tan = colors.new(0.82, 0.7, 0.55)
colors.orange = colors.new(1, 0.5, 0)
colors.cyan = colors.new(0, 1, 1)
colors.magenta = colors.new(1, 0, 1)
colors.lightGray = colors.new(0.827451, 0.827451, 0.827451)
colors.darkGray = colors.new(0.25, 0.25, 0.25)
colors.gold = colors.new(1, 0.84, 0)
colors.lightRed = colors.new(1, 0.5, 0.5)
colors.pink = colors.lightRed
colors.lightGreen = colors.new(0.5, 1, 0.5)
colors.lightBlue = colors.new(0.5, 0.5, 1)
colors.lightYellow = colors.new(1, 1, 0.5)
colors.lightCyan = colors.new(0.5, 1, 1)
colors.lightMagenta = colors.new(1, 0.5, 1)
colors.darkRed = colors.new(0.5, 0, 0)
colors.darkGreen = colors.new(0, 0.3, 0)
colors.darkBlue = colors.new(0, 0, 0.5)
colors.darkYellow = colors.new(0.5, 0.25, 0)
colors.brown = colors.new(0.5, 0.25, 0)
colors.darkSlateGray = colors.new(0.184314, 0.309804, 0.309804)
colors.slateGray = colors.new(0.439216, 0.513725, 0.513725)

if love and love.graphics then

	-- Only if using love and the graphics is enabled
	function colors:set()
		love.graphics.setColor(self)
	end

end

return colors
