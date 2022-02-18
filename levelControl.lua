
local global = require('lib.models.global')
local config = require('lib.config.config')

local control = {}
  control.enemies = {}
  control.game = nil
  control.totalEnemies  = 0
  control.isStarted = false
  control.impulse = -160
  control.sideImpulseMax = 250
  control.imp_left = -150
  control.imp_rigth = 150
  control.screenW = 0;
  control.screenH = 0;
  control.animateEnemies = nil;
  control.animateBonus = nil;
  control.finishBonus = nil;
  control.bonus = nil

local function checkMemory()
   collectgarbage( "collect" )
   local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
   local str = string.format(memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ))
   --performanceMonitor.text = str
   print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
end


-- Calculate x and y based on percentage
function control.getXAndYByPerc(object,calculedWithMiddle,xPercentage,yPercentage)
  local xCalculed = control.screenW * (xPercentage / 100 ) --  - (object.width / 2)
  local yCalculed = control.screenH * (yPercentage / 100 ) - (object.height / 2)
   if calculedWithMiddle == true then
  	xCalculed = xCalculed - (object.width / 2)
   end
  return xCalculed, yCalculed
end

-- calculate width and heigth based on percentage
function control.getWithAndHeigthByPerc(widthPercentage,heigthPercentage)
  local widthCalculed = control.screenW * (widthPercentage / 100 )
  -- print("total with ",screenW, " total heigth ",screenH)
  local heightCalculed = control.screenH * (heigthPercentage / 100 )
  return widthCalculed, heightCalculed

end


-- adding enemies based on levels configs
function control.addEnemies (object,objectX,objectY,enemy)

	if enemy ~= nil then
		control.totalEnemies = control.totalEnemies + 1
		local xCalculed = object.width * (enemy.x / 100 )
		local yCalculed = objectY - (object.height / 2) - (enemy.heigth/2)
    local w,h = global.getWithAndHeigthByPerc(control.screenW,control.screenH,config.gamePlayer.opponentWidth ,config.gamePlayer.opponentHeigth )
		local enemyT = display.newImageRect( enemy.image, enemy.width, enemy.heigth )
    enemyT.anchorX = 0
		enemyT.anchorY = 0
    control.game:insert( enemyT )
		enemyT.name = 'enemy'
		enemyT.id = control.totalEnemies
		enemyT.x, enemyT.y = objectX+xCalculed - (enemy.width/2), yCalculed
		enemyT.angularVelocity = 0
    table.insert (control.enemies , control.totalEnemies, enemyT)
		--enemies[Control.totalEnemies] = enemyT
		physics.addBody(enemyT, { density=9.0, friction=0.5, bounce=0.1 })
    enemyT = nil
  end
  object = nil
  return true
end

-- load all level from config file!
function control.loadLevelObjects(level)
 	-- now i'm trying to load the collidable objects!!
	local data = level.data;
	local item = nil
	local x,y,width,height = nil
	local object = nil
	local player = nil
		for i = 1, #data do
			item = data[i]
			width,height = control.getWithAndHeigthByPerc(item.with,item.heigth)
			object = display.newImageRect( item.image, width, height )
      control.game:insert( object )
			x,y = control.getXAndYByPerc(object,item.calculedWithMiddle,item.x,item.y)
			object.anchorX = 0
			object.anchorY = 0
			object.x, object.y =  x,y
			physics.addBody(object, 'static')

			for p = 1,#item.players do
				player = item.players[p]
				if player.type == 'enemy' then
					control.addEnemies(object,x,y,player)
				end
			end
	end
  data,level = nil
  x,y,width,height = nil
  player =nil
  return true;
end

-- Timer to animate the players and enemies
--
function control.timer( event )
    -- checkMemory();
  math.randomseed( os.time() )
    local len = #control.enemies
    -- print('timer is callled ...',len)
    local i= 1
    while i <= len do
    	local opponent = control.enemies[i]
    	if  opponent then
			-- print("id is ",i, " enemy is",opponent.id)

    		local enemy1_up = math.random( 1,10 );
		    local enemy1_left = math.random( 1,10 );
		    local vx, vy = opponent:getLinearVelocity()

		    if enemy1_up > 5 then
		    	if enemy1_left > 5 then
		    		opponent:setLinearVelocity(control.imp_left, control.impulse)
		    	else
		    		opponent:setLinearVelocity(control.imp_rigth, control.impulse)
		    	end
		    else
		    	if enemy1_left > 5 then
		    		opponent:setLinearVelocity(control.imp_left, vy)
		    	else
		    		opponent:setLinearVelocity(control.imp_rigth, vy)
		    	end
		    end
		    	if( (opponent.x - opponent.contentWidth / 2) <= 0) then
				opponent.x = (control.screenW - opponent.contentWidth / 2) -3
			end

			if( opponent.x  < 0) then
        opponent.x = screenW - (opponent.width / 2)
      elseif ( opponent.x > control.screenW) then
        opponent.x =  (opponent.width / 2)
      end
			opponent.rotation = 0;
			opponent.isFixedRotation = true
    	end
		i=i+1
	end

end



function control.removeEnemy(enemy)
  --print('remove one enemy ',enemy.id, " total enemis was ", control.totalEnemies)
  control.totalEnemies = control.totalEnemies - 1;
  --print('o tamanho da lista dos inimigos é ',#control.enemies)
  control.enemies[enemy.id] = nil;
  -- print('removed enemy is ' , removeEnemy.id , 'total in array is ' , #control.enemies)
  -- removeEnemy:removeSelf();
  display.remove(enemy);
end

function control.finishBouns()
 timer.cancel( control.finishBonus )
 control.bonus:removeSelf( );
 control.finishBonus = nil
 control.bonus = nil
 control.animateBonus = timer.performWithDelay( math.random( 1000 * 4 , 1000 * 15 ), control.putBonuesOnSide , 1)

end

function control.putBonuesOnSide()
  math.randomseed( os.time() )
  timer.cancel( control.animateBonus )
  control.animateBonus = nil
  control.bonus  = display.newImageRect( "assets/images/bonus.png", 50, 50)
  control.game:insert( control.bonus  )
  control.bonus.name = "bonus";
  control.bonus.anchorX = 0;
  control.bonus.anchorY = 0;
  control.bonus.x = math.random(0,control.screenW);
  control.bonus.y = math.random(0,control.screenH);
  control.finishBonus = timer.performWithDelay( math.random( 1000 * 2 , 1000 * 8 ), control.finishBouns , 1)
end

function control.start(level)
  if control.isStarted then
      print('level is already started..')
  else
    math.randomseed( os.time() )
    control.enemies = {}
    control.game = display.newGroup();
    control.totalEnemies  = 0
    control.loadLevelObjects(level);
    -- control.animateEnemies= timer.performWithDelay( 500, control.timer , -1)
    control.animateBonus  = timer.performWithDelay( math.random( 1000 * 4 , 1000 * 15 ), control.putBonuesOnSide , 1)
    control.isStarted = true;
  end
end

function control.clear()

  if control.isStarted then
    -- timer.cancel(control.animateEnemies)
    if control.animateBonus ~= nil then
      timer.cancel(control.animateBonus)
    end
    if control.finishBonus ~= nil then
      timer.cancel(control.finishBonus)
    end
    control.animateEnemies = nil
    for i = 1, control.game.numChildren do
      control.game[1]:removeSelf()
    end
    control.game:removeSelf();
    control.totalEnemies =0;

    for i = 1, #control.enemies do
       local tmp  = control.enemies[i]
       --tmp:removeSelf();
       control.enemies[i] = nil;
    end
    control.animateEnemies = nil
    control.animateBonus = nil
    control.finishBonus = nil
    control.enemies = nil;
    control.game = nil
    control.isStarted = false;
  end
end

function control.init(screenW,screenH)
   control.screenW = screenW;
   control.screenH = screenH;
end

return control
