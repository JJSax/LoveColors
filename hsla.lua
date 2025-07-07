local HERE = (...):match("(.-)[^%.]+$")
local common = require(HERE .. ".common")
local testNumber = common.testNumber
local lerp = common.lerp

--!Note HSL and HSV are in beta and will be subject to changes
--[[
	HSL and HSV reference
	https://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
	adapted from http://en.wikipedia.org/wiki/HSL_color_space
	adapted from http://en.wikipedia.org/wiki/HSV_color_space
]]

---@class HSLAColor
---@field h number
---@field s number
---@field l number
---@field a number
local hsl = {}
local hslIMap = { h = 1, s = 2, l = 3, a = 4 }
hsl.__index = function(t, key)
	return hslIMap[key] and t[hslIMap[key]] or hsl[key]
end
hsl.__newindex = function(t, key, value)
	rawset(t, hslIMap[key] or key, value)
end

function hsl.new(h, s, l, a)
	local self = setmetatable({}, hsl)
	if h and s and l then
		testNumber(h, s, l)
		self[1] = h
		self[2] = s
		self[3] = l
		self[4] = a or 1
	elseif type(h) == "table" then
		testNumber(h[1], h[2], h[3])
		self[1] = h[1]
		self[2] = h[2]
		self[3] = h[3]
		self[4] = h[4] or 1
	end
	assert(self[1], "Improper color passed.")
	return self
end

-- Interpolate between two hues
function hsl.lerpHue(h1, h2, t)
	local delta = (h2 - h1) % 1
	if delta > 0.5 then
		delta = delta - 1
	end
	return (h1 + delta * t) % 1
end

-- Interpolate between two HSL colors
function hsl.lerpHSL(hsl1, hsl2, t)
	return hsl.new {
		hsl.lerpHue(hsl1.h, hsl2.h, t),
		lerp(hsl1.s, hsl2.s, t),
		lerp(hsl1.l, hsl2.l, t),
		lerp(hsl1.a, hsl2.a, t)
	}
end

function hsl:unpack()
	return self.h, self.s, self.l, self.a
end

return hsl