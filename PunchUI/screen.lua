
local PATH = (...):match("(.-)[^%.]+$")

local class = require(PATH .. "middleclass")
local Panel = require(PATH .. "panel")
local Screen = class("PunchUiScreen")

function Screen:initialize( name, font )
	self.name = name or ""
	self.font = font

	self.panels = {}
	self.msgBox = nil
end

function Screen:addPanel( name, x, y, minWidth, minHeight, font, padding )

	-- no duplicate panels allowed!
	local old = self:panelByName( name )
	if old then
		self:removePanel( name )
	end
	print( "new panel:", name, font, self.font)
	local pan = Panel:new( name, x, y, minWidth, minHeight, font or self.font, padding )
	table.insert( self.panels, pan )
	return pan
end

function Screen:removePanel( name )
	for k, p in ipairs( self.panels ) do
		if p.name == name then
			table.remove( self.panels, k )
			return
		end
	end
end

function Screen:panelByName( name )
	for k,p in ipairs(self.panels) do
		if p.name == name then
			return p
		end
	end
end

function Screen:addInput( panelName, name, x, y, width, height, key )
	local p = self:panelByName( panelName )
	i = p:addInput( name, x, y, width, height, key )
	return i
end
function Screen:addPassword( panelName, name, x, y, width, height, key )
	local p = self:panelByName( panelName )
	i = p:addInput( name, x, y, width, height, key, true )
	return i
end
function Screen:addText( panelName, name, x, y, width, height, txt )
	local p = self:panelByName( panelName )
	t = p:addText( name, x, y, width, height, txt )
	return t 
end

function Screen:addHeader( panelName, name, x, y, txt )
	local p = self:panelByName( panelName )
	h = p:addHeader( name, x, y, txt )
	return h
end

function Screen:draw()
	for k,p in ipairs(self.panels) do
		p:draw()
	end
	
	if self.msgBox then
		self.msgBox:draw()
	end
end

function Screen:addFunction( panelName, name, x, y, txt, key, event )
	local p = self:panelByName( panelName )
	f = p:addFunction( name, x, y, txt, key, event )
	return f
end

function Screen:keypressed( key, unicode )
	if self.msgBox then
		self.msgBox:keypressed( key, unicode )
	else
		for k, p in pairs( self.panels ) do
			if p.activeInput then
				p:enterText( key, unicode )
				return
			end
		end
		for k, p in pairs( self.panels ) do
			-- allow only one panel to react to the input:
			if p:keypressed( key, unicode ) then
				return
			end
		end
	end
end

function Screen:newMsgBox( header, msg, x, y, width, commands )

	width = width or love.graphics.getWidth()/4 + 40
	x = x or (love.graphics.getWidth() - width)/2
	y = y or 2*love.graphics.getHeight()/5
	local msgBox = Panel:new( "msgBox", x, y, width, 100, self.font, 20 )
	local curY = 0
	msgBox:addHeader( "header", curY, 0, header )
	curY = curY + self.font:getHeight()
	local t, height = msgBox:addText( "text", 10, curY, nil, 1, msg )
	curY = curY + height + 10
	
	for k, c in ipairs( commands ) do
		msgBox:addFunction( tostring(k), 10, curY, c.txt, c.key, 
							function()
								self:removeMsgBox()
								if c.event then
									c.event()
								end
							end )
		curY = curY + self.font:getHeight()
	end

	msgBox.h = (#commands+2)*self.font:getHeight() + height + 30
	self.msgBox = msgBox
end

function Screen:removeMsgBox()
	self.msgBox = nil
end

return Screen
