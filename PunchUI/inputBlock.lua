
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
	self.maxLines = lines
end

function InputBlock:keypressed( key, unicode )
	if key == "backspace" then
		local len = #self.front
		if len > 0 then
			self.front = self.front:sub(1, len-1)
			self:setText( self.front .. self.back )
			self.cursorX, self.cursorY = self:getCharPos( #self.front )
		end
	elseif key == "escape" then
		self.front = self.fullContent
		self:setText( self.front )
		self.back = ""
		return "stop"
	elseif key == "return" then
		self.fullContent = self.front .. self.back
		return "stop"
	elseif unicode >= 32 and unicode < 127 then
		local chr = string.char(unicode)
		self.front = self.front .. chr
		self:setText( self.front .. self.back )
		self.cursorX, self.cursorY = self:getCharPos( #self.front )
	elseif key == "left" then
		local len = #self.front
		if len > 0 then
			self.back = self.front:sub( len,len ) .. self.back
			self.front = self.front:sub(1, len-1)
			self:setText( self.front .. self.back )
			self.cursorX, self.cursorY = self:getCharPos( #self.front )
		end
	elseif key == "right" then
		local len = #self.back
		if len > 0 then
			self.front = self.front .. self.back:sub(1,1)
			self.back = self.back:sub(2,len)
			self:setText( self.front .. self.back )
			self.cursorX, self.cursorY = self:getCharPos( #self.front )
		end
	elseif key == "delete" then
		local len = #self.back
		if len > 0 then
			self.back = self.back:sub(2,len)
			self:setText( self.front .. self.back )
			self.cursorX, self.cursorY = self:getCharPos( #self.front )
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
