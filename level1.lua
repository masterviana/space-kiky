
  local levelLoader = require("configLevelsControl")
  --  https://github.com/robmiracle/Simple-Table-Load-Save-Functions-for-Corona-SDK
  local myData = require( "mydata" )
  local global = require('lib.models.global')
  local sceneControl = require("sceneControl")
  local enemyControl = require("levelControl")
  local composer = require( "composer" )
  local widget = require( "widget" )
  local levelConfig = require("_controls.levels-score-manager")
  local tracker = require("_externalModules.googleAnalitcs")
  local levelAction = require('lib.bussiness.levelsAction')
  local config = require('lib.config.config')
  local log = require('lib.bussiness.log')



  local scene = composer.newScene()

  -- include Corona's "physics" library
  local physics = require "physics"
  -- physics.setDrawMode('hybrid')
  physics.setReportCollisionsInContentCoordinates( true )
  physics.setAverageCollisionPositions( true )
  physics.start(); physics.pause()

  display.setStatusBar( display.HiddenStatusBar )
  physics.setTimeStep( 0 )

  --------------------------------------------
  -- forward declarations and other locals
  local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

  -- initalize my modules
  sceneControl.init(screenW,screenH)
  enemyControl.init(screenW,screenH)

  local impulse = -160
  local sideImpulseMax = 250

  --local swipeLayer = nil
  local controlsfill =  0

  local timeText
  local performanceMonitor
  local hpLabel

  local prevFrameTime, currentFrameTime --both nil
  local deltaFrameTime = 0
  local totalTime = 0

  local memoryTimer

  -- load sp'ounds
  local userLose = audio.loadSound( "sounds/explosion.wav" )
  local enemyHit = audio.loadSound( "sounds/hit1.wav" )

  -- send back to level selection menu
  local function handleCancelButtonEvent( event )
      if ( "ended" == event.phase ) then
          levelAction.clear(global.session.currentType,global.session.currentLevel,nil)
  			  composer.removeScene( "level1", false )
          composer.gotoScene( "levelsMen", { effect="crossFade", time=333 } )
      end
  end

  local function tempHandler( event )
      if ( "ended" == event.phase ) then
        composer.removeScene( "level1", true )
        composer.gotoScene( "finishLevel", { effect="crossFade", time=333 } )
      end
  end

   -- check memory function
  local function checkMemory()
     collectgarbage( "collect" )
     local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
     local str = string.format(memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ))
     performanceMonitor.text = str
    --  print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
  end

  -- convert time to human
  local milliToHuman = function (milliseconds)
    local totalseconds = math.floor(milliseconds / 1000)
    milliseconds = milliseconds % 1000
    local seconds = totalseconds % 60
    local minutes = math.floor(totalseconds / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes % 60
    -- return string.format("%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds)
    return string.format("%02d:%02d:%03d", minutes, seconds, milliseconds)
  end

  -- define some thing on player on player
  local function adjustPlayer(event)
    if sceneControl.player then
      local vx, vy = sceneControl.player:getLinearVelocity()
      sceneControl.player.isFixedRotation = true
      sceneControl.player.rotation = 0;
      if( sceneControl.player.x  < 0) then
        sceneControl.player.x = screenW - (sceneControl.player.width / 2)
      elseif ( sceneControl.player.x > screenW) then
        sceneControl.player.x =  (sceneControl.player.width / 2)
      end
    end
  end

  -- scene enter frame to increment the time!
  function scene:enterFrame(event)

      local currentFrameTime = system.getTimer()
      --if this is still nil, then it is the first frame
      --so no need to perform calculation
      if prevFrameTime then
          --calculate how many milliseconds since last frame
          deltaFrameTime = currentFrameTime - prevFrameTime
       end
      local upTime,leftTime = levelAction.updateTime(global.currentType,global.currentLevel,{totalTime =totalTime },deltaFrameTime)

      prevFrameTime = currentFrameTime
      --this is the total time in milliseconds
      totalTime = totalTime + deltaFrameTime

      --multiply by 0.001 to get time in seconds
      -- timeText.text = totalTime * 0.001
      -- timeText.text = math.floor(totalTime / 100)
      if config.debug then
        timeText.text = string.format(milliToHuman(totalTime))
        checkMemory()
      end

      hpLabel.text = string.format( upTime )

      adjustPlayer()
  end



local detectIfGameIsClearAndWinner = function (enemy,user,userHitEnemy)
    if userHitEnemy then
      print('user hit enemy')
      enemyControl.removeEnemy(enemy)
      audio.play( enemyHit )
          -- user won the game!
      if enemyControl.totalEnemies <= 0 then
        Runtime:removeEventListener("enterFrame", scene)
        tracker.SendOption("levelFinish [WIN::"..levelConfig.currentLevel.. ']',"WIN");
        physics.pause()
        composer.removeScene( "level1", false )

        local finalPoints,stars = levelAction.getClassification()
        local options =
        {
            effect = "crossFade",
            time = 400,
            params = {
                total = finalPoints,
                stars = stars ,
                winner = true,
                message = "You win!",
                currentType = global.session.currentType,
                currentLevel = global.session.currentLevel
            }
        }
        levelAction.stop(global.session.currentType,global.session.currentLevel,options)
        composer.gotoScene( "finishLevel", options )
      end

  else
      tracker.SendOption("levelFinish [loose:: " ..levelConfig.currentLevel .. ']')
      Runtime:removeEventListener("enterFrame", scene)
      audio.play( userLose )
      composer.removeScene( "level1", true )

      physics.pause()
      local finalPoints,stars = levelAction.getClassification()

      local options =
        {
            effect = "crossFade",
            time = 400,
            params = {
                total = finalPoints,
                stars = stars,
                winner = false,
                message = "Game Over",
                currentType = global.session.currentType,
                currentLevel = global.session.currentLevel
            }
        }
      levelAction.stop(global.session.currentType,global.session.currentLevel,options)

      composer.gotoScene( "finishLevel", options )
    end
end

  -- Detect collision only betwen user and enemies
  -- with other object is not important for code
  -- formula for on player lose
  -- enemy.y <= ( user.y - user.heigth )
  function  playerCollision (self,event)
    local value = 0;
  	 -- print ("was a collitsion ",event.target.name, " other type  ", event.other.name)

     if (event.phase == "began" ) then
       sceneControl.player:setSequence("eating")
       sceneControl.player:play()

     end

  	if ( event.phase == "ended" ) then
  		if event.target.name == "user" and event.other.name =="enemy" then
        local user = event.target
        local enemy = event.other
        -- print('enemyY ',enemy.y,' userY ', user.y)
  			if (enemy.y + enemy.height /2)   <= ( user.y - (user.height /2 )  ) then
          value = 1;
        end
  			if (user.y + user.height/2)  <= (enemy.y-(enemy.height /2)  ) then
          value = 2;
  			end
        if value ==1 then
          print('user hitted by enemy')
          detectIfGameIsClearAndWinner(user,enemy,false)
        end
        if value == 2 then
          print('user hit enemy')
          detectIfGameIsClearAndWinner(enemy,user,true)
        end

  		end
  	end

  end


  local moveHorizontal = function (player,swipeLength,isLeft)
  	local impulse = 0
  	local vx, vy = player:getLinearVelocity()
  	if isLeft == true then
  		impulse = vx - swipeLength
  		if impulse <  sideImpulseMax * -1 then
  			impulse = sideImpulseMax * -1
  		end
  	end
  	 if isLeft == false then
  	 	impulse = vx + swipeLength
  	 	if impulse >  sideImpulseMax  then
  			impulse = sideImpulseMax
  		end
  	end

  	 player:setLinearVelocity(impulse, vy)
  end

-- make the user goes up!
function playerUp(event,timpulse)
      if timpulse ~= nil then
        if timpulse > impulse then
          timpulse = impulse
        end
        local vx, vy = sceneControl.player:getLinearVelocity()
        sceneControl.player:setLinearVelocity(vx, timpulse)
      else
      local vx, vy = sceneControl.player:getLinearVelocity()
      sceneControl.player:setLinearVelocity(vx, impulse)
    end

  end

function finishLevel(endTime)
     detectIfGameIsClearAndWinner(user,enemy,false)
end

   function startDrag(event)
  			local swipeLength = math.abs(event.x - event.xStart)
        local verticalSwipeLength = math.abs(event.y - event.yStart)

  			local t = event.target
  			local phase = event.phase
  			if "began" == phase then
  				return true
  			elseif "moved" == phase then
      elseif "ended" == phase or "cancelled" == phase then
  				local vx, vy = sceneControl.player:getLinearVelocity()
  				local innerLeftImpulse = imp_left
  				if event.xStart > event.x and swipeLength > 10 then
  					-- print("click left")
  				 moveHorizontal(sceneControl.player,swipeLength,true)
  		        elseif event.xStart < event.x and swipeLength > 10 then
  							-- print("swipe rigth")
  					       moveHorizontal(sceneControl.player,swipeLength,false)
  				end
          if event.yStart > event.y and  verticalSwipeLength > 20 then
            playerUp(nil,verticalSwipeLength)
          end
  			end
  		end


  --reset all elements from level
  local function initalizeLocals()
    -- calcule the impulse based on heigth percetage
    local x,y = global.getWithAndHeigthByPerc( screenW,screenH,1,21)
    impulse = y * -1

    local x,y = global.getWithAndHeigthByPerc( screenW,screenH,18.7,1)
    sideImpulseMax = x

    physics.start()
  end

  function scene:create( event )
    tracker.EnterScene("game scene [LEVEL:"..levelConfig.currentLevel..']')
    tracker.SendOption("levelStart [LEVEL:" ..levelConfig.currentLevel.. ']')

    print("WIDTH "..screenW.." HEIGTH "..screenH)

    initalizeLocals();

    local levelData = levelLoader.getLevel(levelConfig.currentLevel)
   	enemyControl.start(levelData)
    local funcs = {}
    funcs.collision = playerCollision
    sceneControl.start(funcs)


  	local sceneGroup = self.view

    sceneGroup.anchorX =0
    sceneGroup.anchory =0

  	local swipeLayer = display.newRect(0, 0, display.contentWidth, display.contentHeight )
  	swipeLayer.anchorX = 0;
  	swipeLayer.anchorY = 0;
  	swipeLayer.alpha= controlsfill --make it transparent
  	swipeLayer.isHitTestable = true
  	swipeLayer:addEventListener("touch", startDrag)
    swipeLayer:addEventListener("tap", playerUp)

  	local topLimit = display.newRect( 0, 0, screenW, 1 )
  	topLimit.anchorX = 0
  	topLimit.anchorY = 0
  	topLimit:setFillColor(1)


  	local bottomLimit = display.newRect( 0, screenH , screenW + 15, 1 )
  	bottomLimit.anchorX = 0
  	bottomLimit.anchorY = 0
  	bottomLimit:setFillColor(1)

    if config.debug then
      timeText = display.newText( totalTime, 0, 0, native.systemFont, 30 )
      timeText.anchorX = 0
      timeText.anchorY = 0
      timeText.x = (screenW /2 ) - (timeText.width )
      timeText.y = 50
    	timeText:setTextColor(0,0,0)

      performanceMonitor = display.newText( totalTime, 0, 0, native.systemFont, 30 )
      performanceMonitor.x = screenW / 2 - (performanceMonitor.width )
      performanceMonitor.y = 25
      performanceMonitor:setTextColor(255,255,0)

    end


    hpLabel = display.newText( "9999", 0, 0, native.systemFont, 30 )
    hpLabel.anchorX = 0
    hpLabel.anchorY = 0
    hpLabel.x = 10
    hpLabel.y = 20
    hpLabel:setTextColor(0,0,0)

  	local background = display.newImageRect( sceneGroup,"background.jpg", screenW, screenH )
  	background.anchorX = 0
  	background.anchorY = 0
  	background:setFillColor( 0.7 )

  	physics.addBody(sceneControl.player,{ density=9.0, friction=0.2, bounce=0.4} )
  	physics.addBody(topLimit, 'static')
  	physics.addBody(bottomLimit, 'static')


    local doneButton= widget.newButton
      {
          id = "button1",
          width = 100,
          height = 100,
          defaultFile = "assets/images/pause.png",
          overFile = "assets/images/pause.png",
          label = "",
          onEvent = handleCancelButtonEvent
      }

  	doneButton.x = screenW - 60
  	doneButton.y = 60

    sceneGroup:insert( background )
    sceneGroup:insert( doneButton )
    sceneGroup:insert( sceneControl.player )
    sceneGroup:insert( topLimit )
    sceneGroup:insert( bottomLimit )
    sceneGroup:insert( swipeLayer )
    sceneGroup:insert( hpLabel )

    if config.debug then
      sceneGroup:insert( timeText )
      sceneGroup:insert( performanceMonitor )
    end

    levelAction.start(global.session.currentType,global.session.currentLevel,nil,{finishLevel = finishLevel})
    Runtime:addEventListener("enterFrame", scene)

  end


  function scene:show( event )
  	local sceneGroup = self.view
  	local phase = event.phase

  	if phase == "will" then
  		-- Called when the scene is still off screen and is about to move on screen
      physics.start()
  	elseif phase == "did" then
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
     Runtime:removeEventListener("enterFrame", scene)

  	elseif phase == "did" then
  		-- Called when the scene is now off screen
  	end

  end

  function scene:destroy( event )

    Runtime:removeEventListener("enterFrame", scene)
  	local sceneGroup = self.view

    sceneGroup:removeSelf()
    for i = 1, sceneGroup.numChildren do
      sceneGroup[1]:removeSelf()
      end

    totalTime =0
    -- hpLabel = nil
    -- performanceMonitor = nil

    -- memoryTimer = nil
    prevFrameTime = nil
    currentFrameTime = nil
    deltaFrameTime =0

    sceneControl.clear()
    enemyControl.clear()
    --levelAction.stop(global.session.currentType,global.currentLevel,nil)
    physics.pause()
  	-- package.loaded[physics] = nil
  	-- physics = nil
  end


  ---------------------------------------------------------------------------------
  -- Listener setup
  scene:addEventListener( "create", scene )
  scene:addEventListener( "enter", scene )
  scene:addEventListener( "show", scene )
  scene:addEventListener( "hide", scene )
  scene:addEventListener( "destroy", scene )

  -----------------------------------------------------------------------------------------

  return scene
