
local HERE = ... == "init" and "" or ...
local Collection = {
	colors = require(HERE .. ".rgba"),
	hsla = require(HERE .. ".hsla"),
	hsva = require(HERE .. ".hsva"),
}
Collection.rgba = Collection.colors
Collection._VERSION = "2.0.3"


-------------------------------------
--- Cross Compatability Functions ---
-------------------------------------

local rgba = Collection.rgba
local hsla = Collection.hsla
local hsva = Collection.hsva

hsla.init(rgba)
rgba.init(hsla)





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

return Collection
