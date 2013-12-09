
local PATH = (...):match("(.-)[^%.]+$")
local class = require( PATH .. "middleclass" )
local TextBlock = require( PATH .. "textBlock" )
local COLORS = require(PATH .. "colors")

local InputBlock = TextBlock:subclass("InputBlock")

function InputBlock:initialize( name, x, y, width, height, font )
	TextBlock.initialize( self, name, x, y, width, height, "", font, false )
	self.fullContent = ""
	self.front = ""
	self.back = ""
	self.cursorX = 0
	self.cursorY = 0
	self.maxLines = math.floor(height/self.font:getHeight())
end

function InputBlock:keypressed( key, unicode )
	-- back up text incase anything goes wrong:
	local front, back = self.front, self.back
	local changed = false

	if key == "backspace" then
		local len = #self.front
		if len > 0 then
			self.front = self.front:sub(1, len-1)
			changed = true
		end
	elseif key == "escape" then
		self.front = self.fullContent
		self.back = ""
		changed = true
		return "stop"
	elseif key == "return" then
		self.fullContent = self.front .. self.back
		return "stop"
	elseif unicode >= 32 and unicode < 127 then
		local chr = string.char(unicode)
		self.front = self.front .. chr
		changed = true
	elseif key == "left" then
		local len = #self.front
		if len > 0 then
			self.back = self.front:sub( len,len ) .. self.back
			self.front = self.front:sub(1, len-1)
			changed = true
		end
	elseif key == "right" then
		local len = #self.back
		if len > 0 then
			self.front = self.front .. self.back:sub(1,1)
			self.back = self.back:sub(2,len)
			changed = true
		end
	elseif key == "delete" then
		local len = #self.back
		if len > 0 then
			self.back = self.back:sub(2,len)
			changed = true
		end
	elseif key == "home" then
		self.back = self.front .. self.back
		self.front = ""
		self.cursorX, self.cursorY = self:getCharPos( #self.front )
	elseif key == "end" then
		self.front = self.front .. self.back
		self.back = ""
		self.cursorX, self.cursorY = self:getCharPos( #self.front )
	end

	if changed then
		local lines = self.lines
		local original = self.original
		local plain = self.plain

		-- is the new text not too long?
		local success = self:setText( self.front .. self.back )
		if success then
			self.cursorX, self.cursorY = self:getCharPos( #self.front )
		else
			-- change back because text was too long
			self.lines = lines
			self.original = original
			self.plain = plain
			self.front = front
			self.back = back
		end
	end
end

function InputBlock:setActive( bool )
	self.active = bool
	self.cursorX, self.cursorY = 0,0
end

function InputBlock:draw()
	love.graphics.setColor( COLORS.INPUT_BG )
	love.graphics.rectangle( "fill", self.x, self.y, self.width, self.height )
	TextBlock.draw( self )
	if self.active then
		love.graphics.print("|", self.x + self.cursorX, self.y+self.cursorY )
	end
end

return InputBlock
