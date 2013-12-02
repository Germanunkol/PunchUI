local Panel = class("Panel")

require("Scripts/UI/textBlock")

local INPUT_PADDING = 4

local COLOR = {
	KEY = {255, 120, 50, 255},
	TEXT = {255, 255, 255, 255},
	HEADER = {100, 160, 255, 255},
	BORDER = {255,128,0,255},
	PANEL = {32,16,0,190},
	INPUT_BG = {128,32,0,32},
	INPUT_TEXT = {128,128,128,255},
}
local COLOR_INACTIVE = {
	KEY = {255,120,50, 70},
	TEXT = {255, 255, 255, 128},
	HEADER = {100, 160, 255, 128},
	BORDER = {255,128,0, 70 },
	PANEL = {32,16,0,100},
	INPUT_BG = {128,32,0,32},
	INPUT_TEXT = {128,128,128,128},
}

function Panel:initialize( name, x, y, minWidth, minHeight, padding, font )
	self.funcList = {}
	self.headerList = {}
	self.inputList = {}
	self.textList = {}
	self.name = name or "unknown panel"
	self.x = x
	self.y = y
	self.minWidth = minWidth
	self.minHeight = minHeight
	self.padding = padding or 10
	-- initialize with the current minimum settings, since panel is still empty:
	self.width = minWidth or math.huge
	self.height = minHeight or math.huge
	self.font = font
end

function Panel:draw( active )
	local COLOR = COLOR
	if not active then
		COLOR = COLOR_INACTIVE
	end

	love.graphics.setColor( COLOR.PANEL )
	love.graphics.rectangle( "fill", self.x, self.y, self.width, self.height )
	love.graphics.setColor( COLOR.BORDER )
	love.graphics.rectangle( "line", self.x, self.y, self.width, self.height )
	love.graphics.push()
	love.graphics.translate( self.x + self.padding, self.y + self.padding )
	-- draw the headers texts:
	love.graphics.setColor( COLOR.HEADER )
	for k,v in pairs( self.headerList ) do
		love.graphics.print( v.name, v.x, v.y )
	end

	-- draw the keys of the functions:
	love.graphics.setColor( COLOR.KEY )
	for k,v in pairs( self.funcList ) do
		love.graphics.print( v.key, v.x, v.y )
	end
	-- .. and of the inputs:
	for k,v in pairs( self.inputList ) do
		love.graphics.print( v.key, v.x, v.y )
	end

	-- draw the names of the functions:
	love.graphics.setColor( COLOR.TEXT )
	for k,v in pairs( self.funcList ) do
		love.graphics.print( v.name, v.nameX, v.nameY )
	end

	love.graphics.setColor( COLOR.INPUT_BG )
	for k,v in pairs( self.inputList ) do
		love.graphics.rectangle( "fill", v.boxX, v.boxY, v.boxWidth, v.boxHeight )
	end

	for k,v in pairs( self.inputList ) do
		if v ~= self.curInput then
			love.graphics.setColor( COLOR.INPUT_TEXT )
		else
			love.graphics.setColor( COLOR.TEXT )
			love.graphics.rectangle( "line", v.boxX-1, v.boxY-1 , v.boxWidth+1 , v.boxHeight+1)
		end
		love.graphics.printf( v.txt, v.inputX, v.inputY, v.textWidth )
	end

	for k,v in pairs( self.textList ) do
		v.text:draw( v.x, v.y )
	end

	love.graphics.pop()

end

function Panel:setActiveInput( input )
	self.curInput = input
end

function Panel:addHeader( name, x, y, centered )
	local new = {}
	print(name, x, y, centered)
	new.width = self.font:getWidth( name )
	new.height = self.font:getHeight()
	if centered then
		x = x + new.width/2
		y = y + new.height/2
	end
	new.name = name or "unknown"
	new.x = x
	new.y = y
	self.headerList[new.name] = new
	self:calcDimensions()
end
function Panel:addFunction( name, x, y, centered, key, func, tooltip )
	local new = {}
	new.name = name or "unknown"
	new.key = string.lower( key ) or keys:generateKey()
	new.width = self.font:getWidth( name .. " " .. key )
	new.height = self.font:getHeight()
	if y < 1 then	-- if y is a fraction then it gives the number of the line it should be placed in!
		y = y*100*self.font:getHeight()
	end
	if centered then
		x = x + new.width/2
		y = y + new.height/2
	end
	new.x = x
	new.y = y
	new.nameX = self.font:getWidth( new.key .. " " ) + x
	new.nameY = y
	new.func = func
	new.tooltip = tooltip or ""
	self.funcList[new.name] = new
	self:calcDimensions()
end
function Panel:addInput( name, x, y, width, lines, key, initialText, forbidden )
	local new = {}
	if y < 1 then
		y = y*100*self.font:getHeight()
	end
	new.width = width + self.font:getWidth( key .. " " ) + INPUT_PADDING*2
	new.textWidth = width
	new.height = self.font:getHeight()*lines + INPUT_PADDING*2
	new.textHeight = self.font:getHeight()*lines
	if centered then
		x = x - new.width/2
		y = y - new.height/2
	end
	new.name = name or "unknown"
	new.x = x
	new.y = y
	new.boxX = x + self.font:getWidth( key .. " " )
	new.boxY = y
	new.boxWidth = new.textWidth + INPUT_PADDING*2
	new.boxHeight = new.textHeight + INPUT_PADDING*2
	new.inputX = new.boxX + INPUT_PADDING
	new.inputY = new.boxY + INPUT_PADDING
	new.lines = lines
	new.key = key
	new.content = ""
	new.txt = initialText
	new.txt1 = initialText
	new.txt2 = ""
	new.initialText = initialText
	new.active = false
	new.forbiddenChars = forbidden
	new.tooltip = "Press " .. key .. " to start typing!"
	self.inputList[new.name] = new
	self:calcDimensions()
end

function Panel:addText( name, x, y, width, text )
	local new = {}
	love.graphics.setFont( self.font )
	new.text = TextBlock:new( text, self.font, width )
	new.x = x
	if y < 1 then
		y = y*100*self.font:getHeight()
	end
	new.y = y
	new.width = width
	new.height = new.text:getHeight() --new.text.lines*self.font:getHeight()
	new.name = name or "unknown"
	self.textList[new.name] = new
	self:calcDimensions()
end

function Panel:calcDimensions()
	local maxX, maxY = 0, 0
	local currentX, currentY = 0, 0
	for i, list in pairs( {self.funcList, self.headerList, self.inputList, self.textList} ) do
		for k, v in pairs( list ) do
			currentX = v.x + v.width + 2*self.padding
			if currentX > maxX then
				maxX = currentX
			end
			currentY = v.y + 2*self.padding + v.height
			if currentY > maxY then
				maxY = currentY
			end
		end
	end
	self.width = math.max( maxX, self.minWidth )
	self.height = math.max( maxY, self.minHeight )
end

function Panel:getElemPos( name )
	for i,list in pairs( {self.funcList, self.headerList, self.inputList, self.textList} ) do
		for k, elem in pairs( list ) do
			if elem.name == name then
				return elem.x, elem.y, elem.width, elem.height
			end
		end
	end
end

return Panel
