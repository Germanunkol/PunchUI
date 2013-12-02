class = require("Scripts/middleclass")
require("Scripts/UI/ui")	-- creates class "UI"

function love.load()
	myUI = UI:new( "testUI" )

	myUI:newPanel( "topPanel", 10, 10, 500, 20, 10 )
	myUI:newPanel( "bottomPanel", 10, love.graphics.getHeight() - 100, 500, 90 )

	myUI:newHeader( "topPanel", "header", 0, 0, false)
	myUI:newFunction( "topPanel", "move this box", 0, 0.02, false, "m",
						function() myUI:movePanel( "topPanel", math.random(500), math.random(500)) end,
						"Use to randomly move this panel." )
	myUI:newFunction( "topPanel", "remove this box, please!", 0, 0.03, false, "r",
						function() myUI:removePanel( "topPanel") end,
						"Use to remove this panel." )
	myUI:newInput( "bottomPanel", "test", 200, 0, 100, 3, "t", "type text in here", "" )
	local quitFkt = function()
		myUI:newMsgBox( "Really quit?", "Are you sure you want to leave this awesome app?",
			{
		{name = "yes", func = love.event.quit, key = "y"},
		{name = "no", key = "n"}
			}
		)
	end
	myUI:newFunction( "bottomPanel", "Quit", 0, 0, false, "q", quitFkt, "Close window" )
	myUI:newText( "topPanel", "testText", 0, 0.06, 250, "A text with {r}red{w} and {g}green{w} words. And a few lines, of course. {r}red{w}white{w}{g}green{w}.")

end

function love.update( dt )
	myUI:update( dt )
end

function love.draw()
	myUI:draw()
end

function love.keypressed( key, unicode )
	myUI:keypressed( key, unicode )
end
