
local PATH = (...):match("(.-)[^%.]+$")
local class = require( PATH .. "middleclass" )

local TextBlock = require( PATH .. "textBlock" )
local InputBlock = require( PATH .. "inputBlock" )
local COLORS = require(PATH .. "colors")

local Panel = class("PunchUiPanel")

function Panel:initialize( name, x, y, w, h, font, padding )
	self.name = name or ""
	self.x = x or 0
	self.y = y or 0
	--width and height:
	self.w = w
	self.h = h
	self.font = font
	self.padding = padding or 10

	self.texts = {}
	self.events = {}
	self.inputs = {}

	self.lines = {}

	self.activeInput = nil
end

function Panel:addText( name, x, y, width, height, txt )

	for k, t in ipairs(self.texts) do
		if t.name == name then
			table.remove(self.texts, k)
		end
	end
	-- if the width is not given, make sure text does not
	-- move outside of panel:
	print( name, x, y, width, height, txt )
	x = x + self.padding
	y = y + self.padding
	local maxWidth = self.w - x - self.padding
	
	width = math.min( width or math.huge, maxWidth )
	local t = TextBlock:new( name, x, y, width, height, txt, self.font, true )
	table.insert( self.texts, t )
	return t, t.trueWidth or t.width, t.height
end

function Panel:addHeader( name, x, y, txt )
	return self:addText( name, x, y, math.huge, 1, COLORS.HEADER.ID ..txt )
end

function Panel:draw( inactive )
	love.graphics.push()
	love.graphics.translate( self.x, self.y )
	love.graphics.setColor( COLORS.PANEL_BG )
	love.graphics.rectangle( "fill", 0, 0, self.w, self.h )
	if inactive then
		love.graphics.setColor( COLORS.BORDER_IN )
		love.graphics.rectangle( "line", 0, 0, self.w, self.h )
	else
		love.graphics.setColor( COLORS.BORDER )
		love.graphics.rectangle( "line", 0, 0, self.w, self.h )
	end
	for k, l in ipairs( self.lines ) do
		love.graphics.line( l.x1, l.y1, l.x2, l.y2 )
	end
	for k, v in ipairs( self.texts ) do
		v:draw()
	end
	for k, v in ipairs( self.inputs ) do
		v:draw()
	end
	love.graphics.pop()
end

function Panel:addFunction( name, x, y, txt, key, event )
	local fullTxt = COLORS.FUNCTION.ID .. string.upper(key) .. " "
	fullTxt = fullTxt .. COLORS.PLAIN_TEXT.ID .. txt
	local t, w, h = self:addText( name, x, y, math.huge, 1, fullTxt )
	local newEvent = {
		name = name,
		key = key,
		event = event,
	}
	table.insert( self.events, newEvent )
	return newEvent, w, h
end

function Panel:addInput( name, x, y, width, height, key, returnEvent, password )
	-- add a function which will set the new input box to active:
	-- add the key infront of the input box:
	local event = function()
		self.activeInput = self:inputByName( name )
		self.activeInput:setActive( true )
	end
	self:addFunction( name, x, y, "", key, event )

	x = x + self.padding
	y = y + self.padding
	local maxWidth = self.w - x - self.padding
	local keyWidth = self.font:getWidth( key .. " " )
	
	width = math.min( width or math.huge, maxWidth )

	local i = InputBlock:new( name, x + keyWidth, y, width-keyWidth, height, self.font, returnEvent, password )

	table.insert(self.inputs, i)
	return i
end


function Panel:inputByName( name )
	for k, i in ipairs( self.inputs ) do
		if i.name == name then
			return i
		end
	end
end

function Panel:keypressed( key, unicode )
	if not self.activeInput then
		for k, f in pairs( self.events ) do
			if f.key == key then
				if f.event then
					f.event()
				end
				return true
			end
		end
	end
end

function Panel:enterText( key, unicode )
	if self.activeInput then
		-- type the key into the current input box:
		local re = self.activeInput:keypressed( key, unicode )
		-- if "esc" was pressed (or similar), stop:
		if re == "stop" then
			self.activeInput:setActive(false)
			self.activeInput = nil
		end
	end
end

function Panel:addLine( x1, y1, x2, y2 )
	self.lines[#self.lines+1] = {x1=x1, y1=y1, x2=x2, y2=y2 }
end

return Panel
