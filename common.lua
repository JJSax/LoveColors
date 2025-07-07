
local common = {}

function common.clamp(x, min, max)
	if x > max then return max end
	if x < min then return min end
	return x
end

function common.lerp(a, b, f)
	return a + (b - a) * f
end

function common.testNumber(...)
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if type(v) ~= "number" then
			error("Expected number, got " .. type(v), 2)
		end
	end
end

return common