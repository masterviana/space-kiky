local log = require('lib.bussiness.log')
local userLib =require('lib.bussiness.user')
local config = require('lib.config.config')

local levelAction = {}
levelAction.typeLevel = nil
levelAction.levelNumber = nil
levelAction.user = nil
levelAction.isStarted = false
levelAction.game = {}
levelAction.game.hp = 0
levelAction.game.totalHp = 1000 * 30  * 1 --config.gameProgression.levels[levelAction.typeLevel].maxTime
levelAction.game.bonus = 0
levelAction.game.totalBonus = 0
levelAction.game.initalTime = nil
levelAction.game.totalTime  = nil
levelAction.game.prevFrameTime  = 0
levelAction.game.deltaFrameTime  = 0
levelAction.events = {}
levelAction.events.finishLevel =nil


-- 1. call START -> To start all the timers and counter
-- 2. call STOP ->  To stop all the timer finish all logic and other things
-- 3. if user leave the level call clear
-- 4. call FINISH -> calc all the timer check if user beat the best time

	-- params : {
	-- 	initalTime :
	-- }
function levelAction.start(type,level,params,funcs)


	if levelAction.isStarted then
		log.info('level is already started')
    else
    	levelAction.typeLevel = type
    	levelAction.levelNumber = level
    	levelAction.game.initalTime = 0
      --define the duration of level
    	levelAction.game.hp = levelAction.game.totalHp  --config.gameProgression.levels[levelAction.typeLevel].maxTime
    	levelAction.isStarted = true
      levelAction.events.finishLevel = funcs.finishLevel
    end
end

function levelAction.updateTime(type,level,params,delta)

			local leftHp = 0
      levelAction.game.hp = levelAction.game.hp - delta
			leftHp = levelAction.game.totalHp - levelAction.game.hp

      if levelAction.game.hp <= 0 then
        if levelAction.events.finishLevel then
          levelAction.events.finishLevel()
        end
      end

      return levelAction.game.hp,leftHp
end


-- percentage you to know on this level lets say 33% or 66%
function levelAction.TotalLevelPossibleInPercentage(percentageValue)
  -- totalLevelPossibleValue = TotalTime + TotalBonus
	-- on this version i'm counting the bonus value
	local totalLevelPossibleValue = levelAction.game.totalHp + 0
	totalLevelPossibleValue = totalLevelPossibleValue * (percentageValue / 100)
	return totalLevelPossibleValue

end



function levelAction.getClassification()



	local totalPontuation = (levelAction.game.hp ) + (levelAction.game.bonus )
	local remaingPontuation = (levelAction.game.totalHp - levelAction.game.hp ) + ( levelAction.game.totalBonus - levelAction.game.bonus )

	local numberOfStars = 0

  local _1StarPerc = levelAction.TotalLevelPossibleInPercentage(33)
	local _2StarPerc = levelAction.TotalLevelPossibleInPercentage(66)

	if totalPontuation < _1StarPerc then
		 numberOfStars = 1
	end

	if totalPontuation > _1StarPerc and  totalPontuation < _2StarPerc then
		 numberOfStars = 2
	end

	if totalPontuation > _2StarPerc then
		 numberOfStars = 3
	end

	return totalPontuation, numberOfStars

end



function levelAction.stop(type,level,params)

	 if levelAction.isStarted == true then

     levelAction.game.initalTime = 0

		 local total , stars = levelAction.getClassification()
		 print("stars " ..stars.. "/3 total : "..total)

		 local user = userLib.getUser()
		 local levelData = user.data.gameProgression.levels[levelAction.typeLevel].data[levelAction.levelNumber]

		if params.params.winner == true then

			if levelData == nil then
					levelData = {}
					levelData.stars = 3
					levelData.topScore = 0
					levelData.numberWinners = 1
					levelData.id = levelAction.levelNumber
			end
				print("total : ")
				print(total)
				print("top score : ")
				print(levelData.topScore)
				if total > levelData.topScore then
					levelData.topScore = total
					levelData.stars = stars
				end


			if user.data.gameProgression.levels[levelAction.typeLevel].data[levelAction.levelNumber +1 ] == nil then
				user.data.gameProgression.levels[levelAction.typeLevel].data[levelAction.levelNumber +1 ] = {}
				user.data.gameProgression.levels[levelAction.typeLevel].data[levelAction.levelNumber +1 ].numberWinners = 1
				user.data.gameProgression.levels[levelAction.typeLevel].data[levelAction.levelNumber +1 ].topScore = 0
				user.data.gameProgression.levels[levelAction.typeLevel].data[levelAction.levelNumber +1 ].stars = 0
				user.data.gameProgression.levels[levelAction.typeLevel].data[levelAction.levelNumber +1 ].id = levelAction.levelNumber
			end

			levelData.numberWinners = levelData.numberWinners + 1

			print("updat user data object :: ")
			print(levelData)
			user.data.gameProgression.levels[levelAction.typeLevel].data[levelAction.levelNumber] = levelData

			log.debug(levelData)

			userLib.saveUser()

		end

		-- put that on clear in the future
		levelAction.isStarted = false

	end

end

function levelAction.clear(type,level,params)

	levelAction.game.hp = levelAction.game.totalHp  --config.gameProgression.levels[levelAction.typeLevel].maxTime
	levelAction.events.finishLevel = nil
  levelAction.isStarted = false

end

function levelAction.finish(type,level,params)
end

function levelAction.userHit(type,level,params)
end

function levelAction.userHitByEnemy(type,level,params)
end

function levelAction.pause(type,level,params)
end



return levelAction
