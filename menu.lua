-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local tracker = require("_externalModules.googleAnalitcs")
local userLib = require( 'lib.bussiness.user')
local config  = require( 'lib.config.config')
local global  = require( 'lib.models.global')

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn,runless,options

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	global.session.currentType = config.gameProgression.levels.defaultTypeLevelIndex 

	print('!!!  ',config.gameProgression.levels.defaultTypeLevelIndex)
    composer.removeScene( "menu", false )
	-- go to level1.lua scene
	composer.gotoScene( "levelsMen", "fade", 500 )

	return true	-- indicates successful touch
end

local function onOptionsBtnRelease()
	global.session.currentType = config.gameProgression.levels.defaultTypeLevelIndex 
    composer.removeScene( "menu", false )
	-- go to level1.lua scene
	composer.gotoScene( "levelsMen", "fade", 500 )

	return true	-- indicates successful touch
end

function scene:create( event )
	tracker.EnterScene("Initial Menu");
	local sceneGroup = self.view
	
	userLib.getUser();

	-- Called when the scene's view does not exist.
	--
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	local background = display.newImageRect( "background.jpg", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newImageRect( "logo.png", 264, 42 )
	titleLogo.x = display.contentWidth * 0.5
	titleLogo.y = 100

	playBtn = widget.newButton{
		defaultFile="assets/images/playButtonOver.png",
		overFile="assets/images/playButton.png",
		label="PLAY",
		labelColor = { default = {254,254,254},over = {143,145,167}},
		fontSize = 28,
		labelAlign = "center",
		width=200, height=100,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentWidth*0.5
	playBtn.y = display.contentHeight - (display.contentHeight /2)

	runless = widget.newButton{
		label="RUNLESS",
		labelColor = { default = {254,254,254},over = {143,145,167}},
		fontSize = 28,
		labelAlign = "center",
		defaultFile="assets/images/playButtonOver.png",
		overFile="assets/images/playButton.png",
		width=200, height=100,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	runless.x = display.contentWidth*0.5 
	runless.y = display.contentHeight - (display.contentHeight /2) + 90

	options = widget.newButton{
		label="OPTIONS",
		labelColor = { default = {254,254,254},over = {143,145,167}},
		fontSize = 28,
		labelAlign = "center",
		defaultFile="assets/images/playButtonOver.png",
		overFile="assets/images/playButton.png",
		width=200, height=100,
		onRelease = onOptionsBtnRelease	-- event listener function
	}
	options.x = display.contentWidth*0.5
	options.y = display.contentHeight - (display.contentHeight /2) + 180
	-- playBtn = display.newImage("assets/images/playButton.png",display.contentCenterX,display.contentCenterY+100)

	-- all display objects must be inserted into group
	sceneGroup:insert( background )
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( runless )
	sceneGroup:insert( options )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		--
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end
end

function scene:destroy( event )
	local sceneGroup = self.view

	-- Called prior to the removal of scene's "view" (sceneGroup)
	--
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.

	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
	--if scene then
	--	scene:removeSelf( )
		--scene = nil
	--end
  for i = 1, sceneGroup.numChildren do
      sceneGroup[1]:removeSelf()
    end

    sceneGroup:removeSelf( );
  
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
