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

colors._VERSION = "1.0.4"
colors.range = 1

local function clamp(x, min, max)
	if x > max then return max end
	if x < min then return min end
	return x
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

---@param alpha number alpha to get color.
---@return Colors
function colors.random(alpha)
    return colors.new(math.random(), math.random(), math.random(), alpha or 1)
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
colors.darkGreen = colors.new(0, 0.5, 0)
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
