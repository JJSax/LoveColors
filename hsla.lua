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
local hsla = {}
local hslIMap = { h = 1, s = 2, l = 3, a = 4 }
hsla.__index = function(t, key)
	return hslIMap[key] and t[hslIMap[key]] or hsla[key]
end
hsla.__newindex = function(t, key, value)
	rawset(t, hslIMap[key] or key, value)
end

function hsla.new(h, s, l, a)
	local self = setmetatable({}, hsla)
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
function hsla.lerpHue(h1, h2, t)
	local delta = (h2 - h1) % common.TAU
	if delta > math.pi then
		delta = delta - common.TAU
	end
	return (h1 + delta * t) % common.TAU
end

-- Interpolate between two HSL colors
function hsla.lerpHSL(hsl1, hsl2, t)
	return hsla.new {
		hsla.lerpHue(hsl1.h, hsl2.h, t),
		lerp(hsl1.s, hsl2.s, t),
		lerp(hsl1.l, hsl2.l, t),
		lerp(hsl1.a, hsl2.a, t)
	}
end

function hsla:unpack()
	return self.h, self.s, self.l, self.a
end

function hsla.interpolate(hslArray, index)
	assert(#hslArray > 0, "hslArray must not be empty")

	if index <= 0 then
		return hslArray[1]
	elseif index >= #hslArray then
		return hslArray[#hslArray]
	end

	local scaled = index * (#hslArray - 1) / #hslArray
	local i0 = math.floor(scaled)
	local frac = scaled - i0

	local colorA = hslArray[i0 + 1]
	local colorB = hslArray[i0 + 2]

	if not colorB then
		return colorA -- if index is at the end
	end

	return hsla.lerpHSL(colorA, colorB, frac)
end

function hsla.radiansToUnit(h) return (h % common.TAU) / common.TAU end
function hsla.unitToRadians(u) return (u % 1) * common.TAU end

return hsla