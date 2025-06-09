# LoveColors
A simple and useful color library for Lua.

Has a special extension that is automatically added if using [Love2d](https://www.love2d.org/).

To begin using this library you must first require it.

```lua
local colors = require "LoveColors" -- Replace LoveColors with your location
```

## Settings

### range (default: 1)
The color range.  rgba color values should be in this range.
Another common range would be 255.


## Pre-Made colors
There are several built in colors.  You can see them all near the bottom of the file.


## Methods
### colors.new(r[, g, b[, a]])
The entry point for this library.  
returns a new color object with the given r, g, b, a values.

```lua
local OffWhite = colors.new(0.9804, 0.9765, 0.9647)
-- notice the alpha color was not passed.
-- alpha will default to colors.range if not passed.
local OffWhiteAlpha = colors.new(0.9804, 0.9765, 0.9647, 0.5)
```

### colors:desaturate(intensity)
Desaturates a color by intensity amount. 
Intensity should be 0-1 to represent the percent to desaturate the color.

```lua
colors.cyan:desaturate(0.5)
```

### colors:lighten(amount)
Simply lightens a color.  amount should be passed 0-1

### colors:darken(amount)
Simply darkens a color.  amount should be passed 0-1

### colors:lerp(b, f)
Interpolates a color linearly between two colors.
``` lua
local percentFromBlue = 0.25 -- mostly blue but shift 25% towards red
local blueToRed = colors.blue:lerp(colors.red, percentFromBlue)
```

### colors:alpha(amount)
Changes the alpha value of a color to the percent value of amount.
This value must be in the range 0-1.  Translation to colors.range happens internally.

### colors.unpack(color)
Unpacks values from the object into it's 4 parts.
```lua
local r, g, b, a = colors.red:unpack()
```

### colors.average(...)
Returns a color with the linear average of each r, g, b, and a values individually.

This is faster than using [averageHue](#colors.averageHue(...)) but can lead to less intuitive outcomes.
```lua
-- using Love2d to visualize
local c = colors.new(0, 1, 0, 0)
for i = 1, 10 do
	local n = {}
	table.insert(n, c) -- Start the example color as black
	for j = 1, i do
		table.insert(n, colors.purple) -- Make it more purple as i gets higher
	end

	local nc = colors.average(unpack(n))
	nc:set()
	lg.rectangle("fill", 40, i * 20, 30, 20)

	-- Note: The following will not produce exactly the same colors as the above
	--  Because one averages them all at once which slightly changes the math.
	c = c:average(colors.purple) -- You can still call it with metamethods!
	c:set()
	lg.rectangle("fill", 0, i * 20, 30, 20)
end
```

### colors.averageHue(...)
Takes color objects and averages their hsl color rotation.  
This is more intensive than [colors.average](#colors.average(...))

### colors.random(alpha)
Just spits out a random color.  That's all.

### colors.clone(a)
Takes a color object, and returns a brand new identical one.

### colors.isValid(a)


### colors.rgbToHsl(r, g, b)
Transforms a Colors object into an HSL table
alias: colors:hsl()

### colors.hslToRgb(h, s, l)
Transforms h,s,l to a Colors object

### colors.rgbToHsv(r, g, b)
Transforms a Colors object into an HSV table
alias: colors:hsv()

### colors.hsvToRgb(h, s, v)
Transforms h,s,v to a Colors object


## Love2d methods
The following work just like the love.graphics versions, but with direct support for LoveColors

```lua
colors:set()
colors:setBackgroundColor()
colors:getColor()
colors:getBackgroundColor()
```



## MetaMethods
Adds the following simple metamethod support.
### colors.__add(a, b)
Adds each r,g,b,a value from a to b and returns a new Colors object

### colors.__sub(a, b)
Subtracts each r,g,b,a value from a to b and returns a new Colors object

### colors.__mul(a, b)
multiplies b to a.  b can be a number or another color.

```lua
local a = colors.white * 0.5
print(a:unpack()) -- 0.5, 0.5, 0.5, 0.5

local b = colors.new(1, 1, 0.3, 1)
local c = colors.new(0.3, 1, 0.3)
local out = b * c
print(out:unpack()) -- 0.3, 1, 0.1, 1
```

### colors.__div(a, b)
Divides each color channel by b and returns a new Colors object

### colors.__eq(a, b)
Returns boolean if the two colors are the same color.  This returns true whether or not `a` and `b` have the same memory address.

# Todo
I intend to make better use of HSL and HSV functions and make them have their own metatables