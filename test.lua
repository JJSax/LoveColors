
local colors = require "init" -- must be loaded from same folder.
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

test("hsl average", function()
		local r, g, b, a = colors.red:averageHue(colors.blue):unpack()
		return same(r, 1) and same(g, 0) and same(b, 1) and same(a, 1)
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

test("random", function()
		-- three to make chances even lower that two would be the same.
		return (colors.random() ~= colors.random())
			or (colors.random() ~= colors.random())
			or (colors.random() ~= colors.random())
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