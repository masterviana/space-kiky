local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )

-- Require "global" data table (https://coronalabs.com/blog/2013/05/28/tutorial-goodbye-globals/)
-- This will contain relevant data like the current level, max levels, number of stars earned, etc.
local myData = require( "mydata" )
local userScore = require( "_controls.levels-score-manager" )
local tracker = require("_externalModules.googleAnalitcs")
local userLib   = require("lib.bussiness.user");
local levelAction = require("lib.bussiness.levelsAction")

local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local sceneGroup = nil

function resetLevel()
  composer.removeScene( "finishLevel", false )
  composer.gotoScene( "level1", { effect="crossFade", time=500 } )
end

function nextLevel()
  composer.removeScene( "finishLevel", false )
  userScore.currentLevel=userScore.currentLevel + 1
  composer.gotoScene( "level1", { effect="crossFade", time=500 } )
end


function scene:create (event)
  tracker.EnterScene("Finish Level");
  local params = event.params
  local user = userLib.getUser();


  local sceneGroup = self.view

  local o = display.newRect( 0, 0, display.contentWidth / 2, display.contentHeight )
  o.anchorX = 0
  o.anchorY = 0
  o.x =  (display.contentWidth / 2) - (o.width /2)
  o.y = 0
  o:setFillColor( 0.7 )

  local message = display.newText(1, 0, 0, native.systemFontBold, 40 )
  message.anchorX = 0
  message.anchorY = 0
  message.text =params.message
  message.x = (screenW /2) - message.width /2
  message.y = (screenH/2) - 200
  message:setTextColor(0,0,255)

  local scoreLabel = display.newText( "Your Score", 0, 0, native.systemFontBold, 35 )
  scoreLabel.anchorX = 0
  scoreLabel.anchorY = 0
  scoreLabel.x = (screenW /2) - scoreLabel.width /2
  scoreLabel.y = (screenH/2) - 100
  scoreLabel:setTextColor( 0, 0, 0, 255 )

  local score = display.newText( params.total.." stars : "..params.stars.."/3", 0, 0, native.systemFont, 30 )
  score.anchorX = 0
  score.anchorY = 0
  score.x = (screenW /2) - score.width /2
  score.y = (screenH/2) - 50
  score:setTextColor( 0, 0, 0, 255 )



  local recordLabel = display.newText( "Your Best", 0, 0, native.systemFontBold, 35 )
  recordLabel.anchorX = 0
  recordLabel.anchorY = 0
  recordLabel.x = (screenW /2) - recordLabel.width /2
  recordLabel.y = (screenH/2)
  recordLabel:setTextColor( 0, 0, 0, 255 )

  -- local best = tostring(user.data.gameProgression.levels[params.currentType].data[params.currentLevel].bestTime)

  local record = display.newText( "nil", 0, 0, native.systemFont, 30 )
  record.anchorX = 0
  record.anchorY = 0
  record.x = (screenW /2) - record.width /2
  record.y = (screenH/2) +50
  record:setTextColor( 0, 0, 0, 255 )


  local next= widget.newButton
    {
        id = "button1",
        width = 100,
        height = 100,
        defaultFile = "assets/images/next_level.png",
        overFile = "assets/images/next_level.png",
        label = "",
        onEvent = nextLevel
    }
    next.x = (screenW / 2) + 100
    next.y = (screenH / 2) + 200

    local reset= widget.newButton
      {
          id = "button1",
          width = 100,
          height = 100,
          defaultFile = "assets/images/reset.png",
          overFile = "assets/images/reset.png",
          label = "",
          onEvent = resetLevel
      }
      reset.x = (screenW / 2)
      reset.y = (screenH / 2) + 200


  sceneGroup:insert(o)
  sceneGroup:insert(message)
  sceneGroup:insert(scoreLabel)
  sceneGroup:insert(score)
  sceneGroup:insert(recordLabel)
  sceneGroup:insert(record)
  sceneGroup:insert(next)
  sceneGroup:insert(reset)

end

-- On scene show...
function scene:show( event )
    local sceneGroup = self.view

    if ( event.phase == "did" ) then
    end
end

-- On scene hide...
function scene:hide( event )

   local sceneGroup = self.view
    if ( event.phase == "will" ) then
      -- sceneGroup:removeSelf()
    end
end

-- On scene destroy...
function scene:destroy( event )
  local sceneGroup = self.view
  for i = 1, sceneGroup.numChildren do
      sceneGroup[1]:removeSelf()
    end
    sceneGroup:removeSelf();
    sceneGroup = nil

end

-- Composer scene listeners
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
