local global = require('lib.models.global')
local config = require('lib.config.config')
local sheetInfo = require("assets.sprites.kiky-movement")

local sceneControl = {}

sceneControl.player = nil
sceneControl.game = nil
sceneControl.isStarted = false
sceneControl.functions = nil
sceneControl.impulse = -160
sceneControl.sideImpulseMax = 250
sceneControl.imp_left = -150
sceneControl.imp_rigth = 150
sceneControl.screenW = 0
sceneControl.screenH = 0


function sceneControl.init(screenW,screenH)
   sceneControl.screenW = screenW;
   sceneControl.screenH = screenH;
   return true;
end

function sceneControl.updatePlayer ()

end

function sceneControl.start(objectFuncs)
  if sceneControl.isStarted then
    print('scene control is already started')
  else
     if sceneControl.player == nil then
       --before sprite
       --## sprite
       local myImageSheet = graphics.newImageSheet( "assets/sprites/kiky-movement.png", sheetInfo:getSheet() )
       --local sprite = display.newImage( myImageSheet , sheetInfo:getFrameIndex("eating1"))
       local sequenceData = {
           {
             name="eating",                                -- name of the animation
             sheet=myImageSheet,                           -- the image sheet
             start=sheetInfo:getFrameIndex("eating1"),     -- first frame
             count=4,                                      -- number of frames
             time=500,                                    -- speed
             loopCount=0                                   -- repeat
           },
           {
             name="stop",                                -- name of the animation
             sheet=myImageSheet,                           -- the image sheet
             start=sheetInfo:getFrameIndex("eating1"),     -- first frame
             count=1,                                      -- number of frames
             time=0,                                    -- speed
             loopCount=0                                   -- repeat
           }
       }

       -- create sprite, set animation, play


       --end before sprite


        sceneControl.functions = objectFuncs
        sceneControl.game = display.newGroup();
        local w,h = global.getWithAndHeigthByPerc(sceneControl.screenW,sceneControl.screenH,config.gamePlayer.playerWidth ,config.gamePlayer.playerHeigth )
        --sceneControl.player= display.newImageRect( "assets/images/ping_64_64.png",w,h )
        sceneControl.player= display.newSprite( myImageSheet, sequenceData )
        sceneControl.player:setSequence("eating")
        sceneControl.player:play()
        sceneControl.player.height = h
        sceneControl.player.width = w
        sceneControl.player.anchorX = 0
        sceneControl.player.anchorY = 0
        sceneControl.player.x = 150
        sceneControl.player.name = 'user'
        sceneControl.player.collision = sceneControl.functions.collision
        sceneControl.player:addEventListener( "collision", sceneControl.player )
        sceneControl.player.y = (sceneControl.screenH)  - (sceneControl.screenH /2)
        sceneControl.player.rotation = 0
        sceneControl.player.angularVelocity = 0
        sceneControl.isStarted  = true;
      end
    end

end


function sceneControl.clear()

  if sceneControl.player ~= nil then
    sceneControl.player:removeEventListener("collision", sceneControl.functions.collision)
    sceneControl.functions.collision = nil
    sceneControl.functions = nil
    for i = 1, sceneControl.game.numChildren do
      sceneControl.game[1]:removeSelf()
    end
    sceneControl.player:removeSelf()
    sceneControl.player = nil
    sceneControl.isStarted  = false;
  end

end



function sceneControl.unrequire(m)
	package.loaded[m] = nil
	_G[m] = nil
end



return sceneControl
