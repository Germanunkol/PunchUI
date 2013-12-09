
local PATH = (...) .. '.'

local class = require(PATH .. "middleclass")
local Screen = require(PATH .. "screen")

local UI = class("PunchUI")

local fallbackFont = love.graphics.newFont( 12 )

function UI:initialize()
	self.screens = {}
	self.actScreen = nil
end

function UI:newScreen( name, font )
	local scr = Screen:new( name, font or fallbackFont )
	table.insert(self.screens, scr)
	return scr
end

function UI:screenByName( name )
	for k, s in pairs( self.screens ) do
		if name == s.name then
			return s
		end
	end
end

function UI:setActiveScreen( scr )
	if type(name) == "string" then
		self.actScreen = self:screenByName( scr )
	else
		self.actScreen = scr
	end
end

function UI:keypressed( key, unicode )
	if self.actScreen then
		self.actScreen:keypressed( key, unicode )
	end
end

function UI:update( dt )
end

function UI:draw()
	if self.actScreen then
		self.actScreen:draw()
	end
end

-- only expose one single instance to the public:
return UI:new()
