ui = require("PunchUI")

function love.load()

	love.filesystem.setIdentity("PunchUI")
	
	mainMenu = ui:newScreen( "main" )

	mainMenu:addPanel( "centerPanel",
			love.graphics.getWidth()/2-100,
			love.graphics.getHeight()/2-120,
			200, 240 )

	mainMenu:addHeader( "centerPanel", "welcome", 0, 0, "Welcome" )
	mainMenu:addText( "centerPanel", "welcometxt", 10, 20, nil, 4, "Welcome to the {f}PunchUI{w}! Hit keys to test the functionality. \nCheck out the github site for explanations." )

	ui:setActiveScreen( mainMenu )

	mainMenu:addFunction( "centerPanel", "quit",0, 100, "Quit", "q", love.event.quit )
	mainMenu:addFunction( "centerPanel", "spawn",0, 113, "Spawn new panel", "s", spawnNewBox )
end

function love.draw()
	ui:draw()
end

function love.keypressed( key, unicode )
	ui:keypressed( key, unicode )
end

function spawnNewBox()
	mainMenu:addPanel( "newPanel", 10, 10, 200, 400 )
	mainMenu:addHeader( "newPanel", "header", 0, 0, "Text Input Test" )
	mainMenu:addText( "newPanel", "explanation", 10, 20, math.huge, 100, "Below is an input box. By typing the letter infront of it, you'll gain access to the content. Type some text, then press enter (accept) or escape (resets the text) to finish.") 

	mainMenu:addInput( "newPanel", "firstInput", 0, 143, nil, 4, "t" )
	mainMenu:addFunction( "newPanel", "close", 0, 340, "Close", "c", function() mainMenu:removePanel( "newPanel" ) end )
end
