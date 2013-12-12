
local PATH = (...):match("(.-)[^%.]+$")

local class = require(PATH .. "middleclass")
local Panel = require(PATH .. "panel")
local Screen = class("PunchUiScreen")

function Screen:initialize( name, font )
	self.name = name or ""
	self.font = font

	self.panels = {}
end

function Screen:addPanel( name, x, y, minWidth, minHeight, font, padding )

	-- no duplicate panels allowed!
	local old = self:panelByName( name )
	if old then
		self:removePanel( name )
	end

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
end

function Screen:addFunction( panelName, name, x, y, txt, key, event )
	local p = self:panelByName( panelName )
	f = p:addFunction( name, x, y, txt, key, event )
	return f
end

function Screen:keypressed( key, unicode )
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

return Screen
