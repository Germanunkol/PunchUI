ui = require("PunchUI")

function love.load()

	love.filesystem.setIdentity("PunchUI")
	
	mainMenu = ui:newScreen( "main" )

	mainMenu:addPanel( "centerPanel",
			love.graphics.getWidth()/2-100,
			love.graphics.getHeight()/2-120,
			200, 240 )

	mainMenu:addHeader( "centerPanel", "welcome", 0, 0, "Welcome" )
	mainMenu:addText( "centerPanel", "welcometxt", 10, 20, nil, 4, "Welcome to the {f}PunchUI{w}! Hit keys indicated below to test the functionality. \nCheck out the github site for explanations." )

	ui:setActiveScreen( mainMenu )
	local y = 120
	mainMenu:addFunction( "centerPanel", "login",0,y, "Login", "1", spawnLoginBox )
	y = y + 13
	mainMenu:addFunction( "centerPanel", "spawn",0, y, "Spawn new panel", "2", spawnNewBox )
	y = y + 13
	mainMenu:addFunction( "centerPanel", "quit",0, y, "Quit", "q", quit )

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
	mainMenu:addText( "newPanel", "explanation", 10, 20, math.huge, 100, "Below is an input box. By typing the letter infront of it, you'll gain access to the content. Type some text!") 

	mainMenu:addInput( "newPanel", "firstInput", 0, 100, nil, 50, "t" )
	mainMenu:addText( "newPanel", "explanation", 10, 200, math.huge, 100, "While typing, other functions are disabled. Finish typing by pressing enter (accept) or escape (reset content).") 
	mainMenu:addFunction( "newPanel", "close", 0, 340, "Close", "c", function() mainMenu:removePanel( "newPanel" ) end )
end

function spawnLoginBox()
	mainMenu:addPanel( "login", love.graphics.getWidth()/2 + 150, 10, 150, 150)
	mainMenu:addHeader( "login", "header", 0, 0, "Username:")
	mainMenu:addInput( "login", "username", 10, 14, nil, 20, "u" )

	mainMenu:addHeader( "login", "header2", 0, 26, "Password:")
	mainMenu:addPassword( "login", "password", 10, 40, nil, 20, "p" )
end

function quit()
	local commands = {}
	commands[1] = { txt = "yes", key = "y", event = love.event.quit }
	commands[2] = { txt = "no", key = "n" }
	mainMenu:newMsgBox( "Really quit?", "Answering yes will close the app.", nil, nil, nil, commands)
end
