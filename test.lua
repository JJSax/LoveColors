package.path = "../?.lua;" .. package.path
local Colors = require "init" -- must be loaded from same folder.
local colors = Colors.rgba
local hsla = Colors.hsla
local epsilon = 4.57e-15

local totalTests = 0
local passes = 0
local fails = 0
local errors = 0

local function test(name, func, expected)
	local function errorHandler(err)
		errors = errors + 1
		fails = fails + 1
		local trace = debug.traceback("", 2)
		local line = trace:match(":(%d+): in function") or "unknown"
		print(string.format("[ERROR] Test '%s' failed on line %s: %s", name, line, tostring(err)))
	end

	totalTests = totalTests + 1
	local ok, result = xpcall(func, errorHandler)

	if ok then
		if result ~= expected then
			local info = debug.getinfo(2, "Sl")
			local line = info and info.currentline or "unknown"
			print(string.format("[FAIL] Test '%s' on line %s: expected '%s', got '%s'", name, line, tostring(expected),
				tostring(result)))
			fails = fails + 1
		else
			print(string.format("[PASS] Test '%s'", name))
			passes = passes + 1
		end
	end
end

local function same(a, b)
	return math.abs(a - b) < epsilon
end

local function moe(a, b)
	local diff = 1/254 -- 255 for more flexibility
	return math.abs(a - b) < diff
end

test("new1", function()
		local c = colors.red
		return c[1] == 1 and c[2] == 0 and c[3] == 0 and c[4] == 1
	end,
	true
)
test("new2", function()
		local c = colors.new(1, 0, 0, 1)
		return c[1] == 1 and c[2] == 0 and c[3] == 0 and c[4] == 1
	end,
	true
)
test("new3", function()
		local c = colors.new(1, 0, 0)
		return c[1] == 1 and c[2] == 0 and c[3] == 0 and c[4] == 1
	end,
	true
)
test("new4", function()
		local c = colors.new({1, 0, 0})
		return c[1] == 1 and c[2] == 0 and c[3] == 0 and c[4] == 1
	end,
	true
)
test("new5", function()
		local c = colors.new({1, 0, 0, 1})
		return c[1] == 1 and c[2] == 0 and c[3] == 0 and c[4] == 1
	end,
	true
)
test("rgbIndexing", function()
		local c = colors.red
		return c.r == 1 and c.g == 0 and c.b == 0 and c.a == 1
	end,
	true
)

test("rgbIndexing", function()
		local c = colors.red
		return c.r == 1 and c.g == 0 and c.b == 0 and c.a == 1
	end,
	true
)

-- Need to see if I can prevent direct alterations to predefined colors
-- test("alteration", function()
-- 		local c = colors.red
-- 		c.r = 0
-- 		return colors.red.r == 1 and c.g == 0 and c.b == 0 and c.a == 1
-- 	end,
-- 	true
-- )

test("valid color", function ()
		local c = colors.red
		return c:isValid()
	end,
	true
)
test("invalid color", function ()
		local c = {1,1,1,1}
		return colors.isValid(c)
	end,
	false
)

test("__add", function()
		local a = colors.new(0.1, 0.1, 0.1, 0.1)
		local b = colors.new(0.1, 0.1, 0.1, 0.1)
		local c = a + b

		return c.r == 0.2 and c.g == 0.2 and c.b == 0.2 and c.a == 0.2
	end,
	true
)

test("__sub", function()
		local a = colors.new(0.1, 0.1, 0.1, 0.1)
		local b = colors.new(0.1, 0.1, 0.1, 0.1)
		local c = a - b

		return c.r == 0 and c.g == 0 and c.b == 0 and c.a == 0
	end,
	true
)

test("__mul1", function()
		local a = colors.new(0.1, 0.1, 0.1, 0.1)
		local b = colors.new(2, 2, 2, 2)
		local c = a * b

		return c.r == 0.2 and c.g == 0.2 and c.b == 0.2 and c.a == 0.2
	end,
	true
)

test("__mul2", function()
		local a = colors.new(0.1, 0.1, 0.1, 0.1)
		local b = 2
		local c = a * b

		return c.r == 0.2 and c.g == 0.2 and c.b == 0.2 and c.a == 0.2
	end,
	true
)

test("__div1", function()
		local a = colors.new(0.4, 0.4, 0.4, 0.4)
		local b = colors.new(2, 2, 2, 2)
		local c = a / b

		return c.r == 0.2 and c.g == 0.2 and c.b == 0.2 and c.a == 0.2
	end,
	true
)

test("__div2", function()
		local a = colors.new(0.4, 0.4, 0.4, 0.4)
		local b = 2
		local c = a / b

		return c.r == 0.2 and c.g == 0.2 and c.b == 0.2 and c.a == 0.2
	end,
	true
)

test("__eq", function()
		local a = colors.new(0.4, 0.4, 0.4, 0.4)
		local b = colors.new(0.4, 0.4, 0.4, 0.4)

		return a == b
	end,
	true
)

test("unpack", function ()
		local r,g,b,a = colors.red:unpack()
		return r == 1 and g == 0 and b == 0 and a == 1
	end,
	true
)

test("desaturate", function ()
		local r, g, b, a = colors.purple:desaturate(0.3):unpack()
		return same(r, 0.45) and same(g, 0.1) and same(b, 0.45) and same(a, 1)
	end,
	true
)

test("lighten", function ()
		local r, g, b, a = colors.purple:lighten(0.3):unpack()
		return same(r, 0.8) and same(g, 0.3) and same(b, 0.8) and same(a, 1)
	end,
	true
)

test("darken", function ()
		local r, g, b, a = colors.cyan:darken(0.3):unpack()
		return same(r, 0) and same(g, 0.7) and same(b, 0.7) and same(a, 1)
	end,
	true
)

test("lerp", function ()
		local r, g, b, a = colors.black:lerp(colors.white, 0.3):unpack()
		return same(r, 0.3) and same(g, 0.3) and same(b, 0.3) and same(a, 1)
	end,
	true
)

test("alpha", function ()
		local r, g, b, a = colors.red:alpha(0.3):unpack()
		return same(r, 1) and same(g, 0) and same(b, 0) and same(a, 0.3)
	end,
	true
)

test("fast average", function()
		local r, g, b, a = colors.red:average(colors.blue):unpack()
		return same(r, 0.5) and same(g, 0) and same(b, 0.5) and same(a, 1)
	end,
	true
)

test("clone", function()
		local c = colors.new(0.1, 0.2, 0.3, 0.4)
		local b = c:clone()
		return c[1] == b[1] and c[2] == b[2] and c[3] == b[3] and c[4] == b[4]
		and colors.isValid(c) and colors.isValid(b)
	end,
	true
)

test("newClone", function()
		local c = colors.new(0.1, 0.2, 0.3, 0.4)
		local b = colors.new(c)
		return c[1] == b[1] and c[2] == b[2] and c[3] == b[3] and c[4] == b[4]
			and colors.isValid(c) and colors.isValid(b)
	end,
	true
)

test("random", function()
		-- three to make chances even lower that two would be the same.
		return (colors.random() ~= colors.random())
			or (colors.random() ~= colors.random())
			or (colors.random() ~= colors.random())
	end,
	true
)

test("hsl angle", function()
		local r,g,b,a = hsla.new(0, 1, 0.5, 1):toRgb():unpack()
		return same(r, 1) and same(g, 0) and same(b, 0) and same(a, 1)
	end,
	true
)

test("hsl verify colors", function()
		-- verifying color conversion; colors collected from colorpicker.dev
		local function rgb(r,g,b)
			return colors.new(r/255, g/255, b / 255)
		end

		local function hsl(h,s,l)
			return hsla.new(h/360*math.pi*2, s / 100, l / 100)
		end

		local conversions = {
			{hsl(0, 58.6, 45.5), rgb(184, 48, 48)},
			{hsl(106, 31, 77.5), rgb(188, 215, 180)},
			{hsl(243, 46.9, 43.7), rgb(64, 59, 164)},
			{hsl(314, 100, 77.5), rgb(255, 140, 228)},
			{hsl(193, 71.8, 55.2), rgb(59, 187, 223)},
			{hsl(95, 71.8, 55.2), rgb(127, 223, 59)},
			{hsl(292, 100, 55.2), rgb(225, 27, 255)},
			{hsl(61, 100, 55.2), rgb(251, 255, 27)},
			{hsl(161, 100, 55.2), rgb(27, 255, 183)},
			{hsl(212, 100, 20.7), rgb(0, 49, 106)},
			{hsl(316, 28.4, 20.7), rgb(68, 38, 60)},
			{hsl(123, 28.4, 20.7), rgb(38, 68, 39)},
			{hsl(237, 58.5, 42.3), rgb(45, 51, 171)},
			{hsl(96, 71.6, 37.8), rgb(83, 165, 27)},
			{hsl(360, 71.6, 37.8), rgb(165, 27, 27)}
		}

		local success = true
		for i, v in ipairs(conversions) do
			local r, g, b, a = v[1]:toRgb():unpack()
			local rgb = v[2]
			if not (moe(r, rgb.r) and moe(g, rgb.g) and moe(b, rgb.b)) then
				local s = string.format("Wrong color %d: %.10f %.10f %.10f %.10f -> %.10f %.10f %.10f %.10f", i,r,g,b,a, rgb:unpack())
				print(s)
				success = false
			end
		end

		return success

	end,
	true
)

test("hsl average", function()
		local r, g, b, a = colors.red:averageHue(colors.blue):unpack()
		return same(r, 1) and same(g, 0) and same(b, 1) and same(a, 1)
	end,
	true
)

test("hsl average 2", function()
		local r, g, b, a = colors.averageHue(colors.red, colors.blue):unpack()
		return same(r, 1) and same(g, 0) and same(b, 1) and same(a, 1)
	end,
	true
)

test("colorToHSL", function()
		local hc = colors.red:toHsl()
		local h, s, l, a = hc:unpack()
		return same(h, 0) and same(s, 1) and same(l, 0.5) and same(a, 1)
	end,
	true
)

test("hsl", function()
		local c = hsla.new(0.5, 1, 1, 1)
		return same(c.h, 0.5) and c.s == 1 and c.l == 1 and c.a == 1 and getmetatable(c) == hsla
	end,
	true
)

test("HSLToRGB", function()
		local c = colors.red:toHsl():toRgb()
		local r, g, b, a = c:unpack()
		return same(r, 1) and same(g, 0) and same(b, 0) and same(a, 1)
	end,
	true
)

-------------------------------------------


print("\nRESULTS:")
if fails > 0 then
	print(" -> One or more tests failed!")
else
	print(" -> All Tests Passed")
end

print("Tests ran: " .. totalTests)
print("Tests passed: "..passes)
print("Tests failed: " .. fails)
print("Tests that errored: " .. errors)