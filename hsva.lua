local HERE = (...):match("(.-)[^%.]+$")
local common = require(HERE .. ".common")
local testNumber = common.testNumber
local lerp = common.lerp
local clamp = common.clamp
local hsvIMap = { h = 1, s = 2, v = 3, a = 4 }
local unpack = table.unpack or unpack -- Adjust for lua unpack changes

--! WIP