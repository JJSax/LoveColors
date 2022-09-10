local modules = (...):gsub('%.[^%.]+$', '') .. "."
local color = require(modules.."colors")
local lg = love.graphics

function color:set()
	lg.setColor(self)
end


return color
