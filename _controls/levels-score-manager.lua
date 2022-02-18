local json = require "json"
local loadSave = require("_controls.loadSave")

local Levels = {}
Levels.levels = {}
Levels.levels.unlockedLevels = 1;
Levels.levels.maxLevels = 10
Levels.levels.data = {}
Levels.isLoaded = false;
Levels.currentLevel = 1;


function Levels.loadLevels()
	if Levels.isLoaded == false then
        local dataLevels  = Levels.load("_dataStore/savedLevels.json")
        if dataLevels == nil then
        	print('its first loaded will create empty file')
        else
        	Levels.levels  = dataLevels
        end
        Levels.isLoaded = true;
	else
		print('cache hit on levels settings')
	end
end

function Levels.getLevelInfo(levelNumber)
	if Levels.isLoaded == false then
		Levels.loadLevels()
	end

	if levelNumber > Levels.levels.maxLevels then
		return nil
	else
		local levelData = Levels.levels[levels];
		return levelData;
	end
end

 -- Data format is :  
 -- params = {
 --                time    = totalTime,
 --                timeText = timeText.text,
 --                hp = 100,
 --                bonus = 20,
 --                winner = true,
 --                message = "You win!"
 --            }
function Levels.saveLevel(number,data)
	 print("vai graver o nivel ",number )
	if tonumber(number) > 0 and tonumber(number)  <= Levels.levels.maxLevels then
		print('vai gravar o nivel')
		Levels.levels.data[number] = {}
		Levels.levels.data[number].stars = math.random( 1,3 )
		Levels.levels.data[number].score = math.random( 1,20 )
		Levels.levels.data[number].time =0
		Levels.levels.unlockedLevels = Levels.levels.unlockedLevels + 1;

		Levels.save("_dataStore/savedLevels.json",Levels.levels);
	end
end


function Levels.clear ()
	Levels.isLoaded = false;
end


return Levels