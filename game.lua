-- Include modules/libraries
local composer = require( 'composer' )
local berry = require( 'ldurniat.berry' )

-- Create a new Composer scene
local scene = composer.newScene()

-- This function is called when scene is created
function scene:create( event )

	local sceneGroup = self.view  -- Add scene display objects to this group

	-- Load our map
	map = berry.new( 'map/level.json', 'map' )
	scene.view:insert( map )

end

-- This function is called when scene comes fully on screen
function scene:show( event )

	local phase = event.phase
	if phase == 'will' then
		
	elseif phase == 'did' then
		-- Start playing wind sound
		-- For more details on options to play a pre-loaded sound, see the Audio Usage/Functions guide:
		-- https://docs.coronalabs.com/guide/media/audioSystem/index.html
	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )

	local phase = event.phase
	if phase == 'will' then
		
	elseif phase == 'did' then
		
	end
end

-- This function is called when scene is destroyed
function scene:destroy( event )
	
end

scene:addEventListener( 'create' )
scene:addEventListener( 'show' )
scene:addEventListener( 'hide' )
scene:addEventListener( 'destroy' )

return scene
