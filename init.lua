
local unpack = table.unpack or unpack -- Adjust for lua unpack changes

local HERE = ... == "init" and "" or ...
local Collection = {
	colors = require(HERE .. ".rgba"),
	hsla = require(HERE .. ".hsla"),
	hsva = require(HERE .. ".hsva"),
}
Collection.rgba = Collection.colors
Collection._VERSION = "2.0.2"


-------------------------------------
--- Cross Compatability Functions ---
-------------------------------------

local rgba = Collection.rgba
local hsla = Collection.hsla
local hsva = Collection.hsva

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
		local angle = h * 2 * math.pi
		x = x + math.cos(angle)
		y = y + math.sin(angle)
	end
	local avg_angle = math.atan2(y, x)
	if avg_angle < 0 then avg_angle = avg_angle + 2 * math.pi end
	return avg_angle / (2 * math.pi)
end

---Converts an RGB color value to HSL. Conversion formula
---assumes r, g, and b are between 0 and colors.range
---returns h, s, and l in range between 0 and 1f
---@return HSLAColor #The HSL representation
function rgba:toHsl()
	local r, g, b, a = self:unpack()
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h = (max + min) / 2
	local s, l = h, h

	if (max == min) then
		return hsla.new( 0, 0, l, a ) -- achromatic
	end

	local d = max - min
	s = l > 0.5 and d / (2 - max - min) or d / (max + min)
	if max == r then h = (g - b) / d + (g < b and 6 or 0) end
	if max == g then h = (b - r) / d + 2 end
	if max == b then h = (r - g) / d + 4 end

	return hsla.new(h / 6, s, l, a)
end

---Takes a list of RGB colors and averages hues to be more accurate to human perception.<br>
---Slower than just taking the simple colors.average.
---@param ... Colors
---@return Colors
function rgba.averageHue(...)
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
function rgba.interpolate(colorArray, index)
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
---@return Colors #The RGB representation
function hsla:toRgb()
	if self.s == 0 then
		return rgba.new(self.l * rgba.range, self.l * rgba.range, self.l * rgba.range, self.a)
	end

	local q = self.l < 0.5 and self.l * (1 + self.s) or self.l + self.s - self.l * self.s
	local p = 2 * self.l - q
	local r = hue2rgb(p, q, self.h + 1/3)
	local g = hue2rgb(p, q, self.h)
	local b = hue2rgb(p, q, self.h - 1/3)
	return rgba.new(r * rgba.range, g * rgba.range, b * rgba.range, self.a)
end




---Converts an RGB color value to HSV. Conversion formula
---Assumes r, g, and b are between 0 and colors.range
---@param r number The red color value
---@param g number The green color value
---@param b number The blue color value
---@return table The HSV representation; Values 0-1f
function rgba.rgbToHsv(r, g, b)
	r, g, b = r / rgba.range, g / rgba.range, b / rgba.range
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

function rgba:hsv()
	return rgba.rgbToHsv(self.r, self.g, self.b)
end

--- Converts an HSV color value to RGB. Conversion formula
--- Assumes h, s, and v are contained in the set [0, 1]
---@param h number Hue
---@param s number Saturation
---@param v number Value
---@return Colors? #The RGB representation
function rgba.hsvToRgb(h, s, v)
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s) * rgba.range
	local q = v * (1 - f * s) * rgba.range
	local t = v * (1 - (1 - f) * s) * rgba.range
	v = v * rgba.range

	i = i % 6
	if(i == 0) then return rgba.new(v, t, p) end
	if(i == 1) then return rgba.new(q, v, p) end
	if(i == 2) then return rgba.new(p, v, t) end
	if(i == 3) then return rgba.new(p, q, v) end
	if(i == 4) then return rgba.new(t, p, v) end
	if(i == 5) then return rgba.new(v, p, q) end
end



if love and love.graphics then

	local lg = love.graphics

	-- Only if using love and the graphics is enabled
	function rgba:set()
		lg.setColor(self)
	end

	function rgba:setBackgroundColor()
		lg.setBackgroundColor(self)
	end

	function rgba:getColor()
		return rgba.new(lg.getColor())
	end

	function rgba:getBackgroundColor()
		return rgba.new(lg.getBackgroundColor())
	end

	function hsla:set()
		lg.setColor(self:toRgb())
	end

end

-- rgba.hsl = hsla

return Collection
