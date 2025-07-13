local HERE = (...):match("(.-)[^%.]+$")
local common = require(HERE .. ".common")
local testNumber = common.testNumber
local lerp = common.lerp
local clamp = common.clamp
local unpack = table.unpack or unpack -- Adjust for lua unpack changes

local iMap = { r = 1, g = 2, b = 3, a = 4 }

---@class Colors
---@field r number
---@field g number
---@field b number
---@field a number
local colors = {}
colors.__index = function(t, key)
	return iMap[key] and t[iMap[key]] or colors[key]
end
colors.__newindex = function(t, key, value)
	rawset(t, iMap[key] or key, value)
end

colors._VERSION = "2.0.2"
colors.range = 1

local hsla
function colors.init(HSLA)
	hsla = HSLA

	colors.init = nil
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
	return self
end

---@param a Colors
---@return boolean
function colors.isValid(a)
	return getmetatable(a) == colors
end

---Converts an RGB color value to HSL. Conversion formula
---assumes r, g, and b are between 0 and colors.range
---returns h, s, and l in range between 0 and 1f
---@return HSLAColor #The HSL representation
function colors:toHsl()
	local r, g, b, a = self:unpack()
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h = (max + min) / 2
	local s, l = h, h

	if (max == min) then
		return hsla.new(0, 0, l, a) -- achromatic
	end

	local d = max - min
	s = l > 0.5 and d / (2 - max - min) or d / (max + min)
	if max == r then h = (g - b) / d + (g < b and 6 or 0) end
	if max == g then h = (b - r) / d + 2 end
	if max == b then h = (r - g) / d + 4 end

	return hsla.new((h / 6) * common.TAU, s, l, a)
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
		clamp(self[1] * (1 - amount * self.range), 0, self.range),
		clamp(self[2] * (1 - amount * self.range), 0, self.range),
		clamp(self[3] * (1 - amount * self.range), 0, self.range),
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

---@param ... Colors
---@return Colors
function colors.average(...)
	local el = { ... }
	local c = colors.new(0, 0, 0, 0)
	for _, v in ipairs(el) do
		c = c + v
	end
	local t = #el
	return colors.new(c[1] / t, c[2] / t, c[3] / t, c[4] / t)
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

local function linearAverage(list)
	local t = 0
	for _, v in ipairs(list) do
		t = t + v
	end
	return t / #list
end

local function averageHue(hues)
	local x, y = 0, 0
	for _, h in ipairs(hues) do
		x = x + math.cos(h)
		y = y + math.sin(h)
	end
	local avg_angle = math.atan2(y, x)
	if avg_angle < 0 then avg_angle = avg_angle + 2 * math.pi end
	return avg_angle
end


---Takes a list of RGB colors and averages hues to be more accurate to human perception.<br>
---Slower than just taking the simple colors.average.
---@param ... Colors
---@return Colors
function colors.averageHue(...)
	local colorsList = { ... }
	local hList, sList, lList, aList = {}, {}, {}, {}

	for _, c in ipairs(colorsList) do
		---@diagnostic disable-next-line: undefined-field LLS Please!
		local h, s, l = unpack(c:toHsl())
		table.insert(hList, h)
		table.insert(sList, s)
		table.insert(lList, l)
		table.insert(aList, c[4])
	end

	local avgH = averageHue(hList)
	local avgS = linearAverage(sList)
	local avgL = linearAverage(lList)
	local avgA = linearAverage(aList)
	return hsla.new(avgH, avgS, avgL, avgA):toRgb()
end

-- Given a float index and array of Colors, interpolate using HSL
function colors.interpolate(colorArray, index)
	assert(#colorArray > 0, "colorArray must not be empty")

	if index <= 0 then
		return colorArray[1]
	elseif index >= #colorArray then
		return colorArray[#colorArray]
	end

	local scaled = index * (#colorArray - 1) / #colorArray
	local i0 = math.floor(scaled)
	local frac = scaled - i0

	local colorA = colorArray[i0 + 1]
	local colorB = colorArray[i0 + 2]

	local hslA = colorA:toHsl()
	local hslB = colorB:toHsl()

	local hslResult = hsla.lerpHSL(hslA, hslB, frac)
	return hslResult:toRgb()
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
	if type(b) == "number" then
		return colors.new(a[1] / b, a[2] / b, a[3] / b, a[4] / b)
	else
		return colors.new(a[1] / b[1], a[2] / b[2], a[3] / b[3], a[4] / b[4])
	end
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
	return colors.isValid(a) and colors.isValid(b)
end

if love and love.graphics then
	local lg = love.graphics

	-- Only if using love and the graphics is enabled
	function colors:set()
		lg.setColor(self)
	end

	function colors:setBackgroundColor()
		lg.setBackgroundColor(self)
	end

	function colors:getColor()
		return colors.new(lg.getColor())
	end

	function colors:getBackgroundColor()
		return colors.new(lg.getBackgroundColor())
	end
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

return colors