-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local scene = composer.newScene()
local tracker = require("_externalModules.googleAnalitcs")
local userLib = require( 'lib.bussiness.user')
local global = require( 'lib.models.global')
local log = require('lib.bussiness.log' )
local userLevels = require( "_controls.levels-score-manager" )

-- include Corona's "widget" library
local widget = require "widget"


 local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

--------------------------------------------

  display.setStatusBar( display.HiddenStatusBar )
-- forward declarations and other locals
local playBtn,runless,options

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease(event)
	  userLevels.currentLevel = event.target.id
    global.session.currentType =  1
    global.session.currentLevel = event.target.id
	  composer.removeScene( "levelsMen", false )
        -- Go to the game scene
      composer.gotoScene( "level1", { effect="crossFade", time=333 } )
	return true	-- indicates successful touch
end

function scene:create( event )
	tracker.EnterScene("Menu Levels");

	log.error("width : "  .. tostring(screenW));
	log.error("heith : "  .. tostring(screenH));

	local sceneGroup = self.view

	local user = userLib.getUser();

	-- display a background image
	local background = display.newImageRect( "background.jpg", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0
 	sceneGroup:insert( background )


	local typeLevels = user.data.gameProgression.levels[global.session.currentType]


	local title= display.newText( typeLevels.titleLabel, 0, 0, native.systemFontBold, 32 )
	title.anchorX =0
	title.anchorY =0
	title.x = display.contentWidth / 2 - (title.width / 2)
	title.y = 25
	title:setFillColor( 1, 0, 0 )

	-- log.error('with '..tostring(screenW).. ' heigth '..tostring(screenH))

	local levels = {}
	-- put at 160px calculated percentage is 160 * 100 / witdh
	local xOffset = global.getXbyPerc(screenW,nil,15,false)
	-- put at 140px calculated percentage is 140 * 100 / heigth
    local yOffset = global.getXbyPerc(screenH,nil,21,false)
    local cellCount = 1

    log.error(typeLevels.unlock);
	for i = 1, typeLevels.max do
		local defaultImage,overImage,label = nil
		local levelAvailable = false

		if typeLevels.data[i] == nil then
				-- this case represente the unlock but empty levels
			if i  > typeLevels.unlock then
				defaultImage = "assets/images/levels/lock_level.png"
				overImage = "assets/images/levels/lock_level.png"
				label = ""
				levelAvailable = false
			else
				defaultImage = "assets/images/levels/lock_empty.png"
				overImage = "assets/images/levels/lock_empty.png"
				label = tostring( i )
				levelAvailable = true
			end
		else
			if typeLevels.data[i].stars == 1 then
				defaultImage = "assets/images/levels/level_1_star.png"
				overImage = "assets/images/levels/level_1_star.png"
				label = tostring( i )
				levelAvailable = true
			elseif typeLevels.data[i].stars ==  2 then
				defaultImage = "assets/images/levels/level_2_star.png"
				overImage = "assets/images/levels/level_2_star.png"
				label = tostring( i )
				levelAvailable = true
			elseif typeLevels.data[i].stars == 3 then
				defaultImage = "assets/images/levels/level_3_star.png"
				overImage = "assets/images/levels/level_3_star.png"
				label = tostring( i )
				levelAvailable = true
			else
				defaultImage = "assets/images/levels/lock_empty.png"
				overImage = "assets/images/levels/lock_empty.png"
				label = tostring( i )
				levelAvailable = true
			end

		end

		-- levels[i] =  display.newImageRect(sceneGroup,"assets/images/levels/level_1_star.png", 120, 100 )
		-- with in percentage is 10 and heigth is 17.2 for level selector icon
		local with,heigth = global.getWithAndHeigthByPerc(screenW,screenH,10,17.2)
		levels[i] = widget.newButton{
				label=label,
				labelColor = { default = {254,254,254},over = {143,145,167}},
				fontSize = 28,
				labelYOffset = -15 ,
				-- emboss = true,
				font = native.systemFontBold,
            	fillColor = { default={ 0, 0.5, 1, 1 }, over={ 0.5, 0.75, 1, 1 } },
	            strokeColor = { default={ 0, 0, 1, 1 }, over={ 0.333, 0.667, 1, 1 } },
	            strokeWidth = 2,
				defaultFile =defaultImage,
				overFile    =overImage,
				width=with,
				height=heigth,
				onRelease = onPlayBtnRelease	-- event listener function
			}

		levels[i].anchorX = 0
		levels[i].anchorY = 0
		levels[i].id = i
		levels[i].x = xOffset
		levels[i].y = yOffset
		levels[i]:setEnabled( levelAvailable )
		if levelAvailable then
			levels[i].alpha = 1.0
		else
			levels[i].alpha = 0.6
		end

		sceneGroup:insert(levels[i])

		xOffset = xOffset + levels[i].width + global.getXbyPerc(screenW,nil,2.2,false)
        cellCount = cellCount + 1
        if ( cellCount > 6 ) then
            cellCount = 1
            xOffset = global.getXbyPerc(screenW,nil,15,false)
            yOffset = yOffset + levels[i].height + global.getYbyPerc(screenH,nil,5,false)
        end


	end

	sceneGroup:insert( title )

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
