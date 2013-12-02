
-- Takes a string of text and wraps it at a certain width.
-- Takes into account colours, newlines, font type.
-- Returns a table of line fragments.

local COLORS = {
	RED = { ID = "{r}", col = {255,0,0,255} },
	WHITE = { ID = "{w}", col = {255,255,255,255} },
	GREEN = { ID = "{g}", col = {0,255,0,255} },
}


class = require("Scripts/middleclass")
TextBlock = class("TextBlock2")

function TextBlock:initialize( text, font, width )

	self.width = width or 100
	self.font = font
	self.original = text or ""
	
	self.plain = self.original:gsub("{.-}", "")
	self.lines = self:wrap()

	self.fragments = self:colorSplit()

	self.height = #self.lines*self.font:getHeight()

	self:render()

	return self.width, self.height
end

function TextBlock:wrap()
	local lines = {}
	self.plain = self.plain .. "\n"
	for line in self.plain:gmatch( "([^\n]-\n)" ) do
		table.insert( lines, line )
	end

	local wLines = {}	-- lines that have been wrapped
	local shortLine
	local restLine
	local word = "[^ ]* "	-- not space followed by space
	local tmpLine
	local letter = "."

	for k, line in ipairs(lines) do
		if self.font:getWidth( line ) <= self.width then
			table.insert( wLines, line )
		else
			restLine = line .. " " -- start with full line
			while #restLine > 0 do
				local i = 1
				local breakingCondition = false
				tmpLine = nil
				shortLine = nil
				repeat		-- look for spaces!
					tmpLine = restLine:match( word:rep(i) )
					if tmpLine then
						if self.font:getWidth(tmpLine) > self.width then
							breakingCondition = true
						else
							shortLine = tmpLine
						end
					else
						breakingCondition = true
					end
					i = i + 1
				until breakingCondition
				if not shortLine then -- if there weren't enough spaces then:
					breakingCondition = false
					i = 1
					repeat			-- ... look for letters:
						tmpLine = restLine:match( letter:rep(i) )
						if tmpLine then
							if self.font:getWidth(tmpLine) > self.width then
								breakingCondition = true
							else
								shortLine = tmpLine
							end
						else
							breakingCondition = true
						end
						i = i + 1
					until breakingCondition
				end
				table.insert( wLines, shortLine )
				restLine = restLine:sub( #shortLine+1 )
			end
		end
	end

	return wLines
end

function TextBlock:colorSplit()

	-- if the text doesn't start with a color,
	-- then start it with white:
	local startsWithCol = false
	for k,col in pairs(COLORS) do
		if self.original:find( col.ID ) == 1 then
			startsWithCol = true
			break
		end
	end
	if not startsWithCol then
		self.original = COLORS.WHITE.ID .. self.original
	end
	
	local split = {}
	-- look for all occurances of the id of all colors in the text:
	for k,col in pairs(COLORS) do
		for s,e in self.original:gmatch( "()" .. col.ID .. "()" ) do
			table.insert( split, {start = s, color = col.col} )
		end
	end

	table.sort( split, function( a, b)
							return a.start < b.start
						end )

	for k,s in ipairs(split) do
		s.start = s.start - (k-1)*3
		if split[k-1] then
			split[k-1].finish = s.start - 1
		end
	end
	split[#split].finish = #self.plain

	local fragments = {}
	local curColor = split[1].color
	local x = 0
	local y = 0
	local curPos = 0
	local curSplit = split[1]
	local cur
	local txt
	local start
	for k,l in ipairs( self.lines ) do
		start = curPos + 1
		x = 0
		y = (k-1)*self.font:getHeight()
		for i,s in ipairs( split ) do
			-- full line is same color?
			if s.start <= start and s.finish >= start + #l then
				table.insert(fragments, {x=x, y=y, color=s.color, txt = l } )
				break
			-- overlapping from left?
			elseif s.start <= start and s.finish <= start + #l and s.finish >= start then
				txt = l:sub(1, s.finish-start + 1 )
				table.insert(fragments, {x=x, y=y, color=s.color, txt=txt } )
				x = x + self.font:getWidth( txt )
			-- fully inside:
			elseif s.start >= start and s.finish <= start + #l then
				txt = l:sub(s.start - start +1, s.finish - start + 1)
				table.insert(fragments, {x=x, y=y, color=s.color, txt=txt } )
				x = x + self.font:getWidth( txt )
			-- overlapping from right:
			elseif s.start >= start and s.finish >= start + #l and s.start <= start + #l then
				txt = l:sub( s.start - start + 1 )
				table.insert(fragments, {x=x, y=y, color=s.color, txt=txt } )
				x = x + self.font:getWidth( txt )
			end
		end
		curPos = curPos + #l
	end

	return fragments
end

function TextBlock:render()
	self.canvas = love.graphics.newCanvas( self.width, self.height )
	love.graphics.setCanvas( self.canvas )
	love.graphics.setFont( self.font )
	for k, f in ipairs(self.fragments) do
		love.graphics.setColor( f.color )
		love.graphics.print( f.txt, f.x, f.y )
	end
	love.graphics.setCanvas()
end

function TextBlock:draw( x, y )
	love.graphics.setColor( 255, 255, 255, 255 )
	local prevMode = love.graphics.getBlendMode()
	love.graphics.setBlendMode("premultiplied")

	love.graphics.draw( self.canvas, x, y )

	love.graphics.setBlendMode( prevMode )
end

function TextBlock:getHeight()
	return self.height
end
