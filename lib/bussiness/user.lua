local user    = require('lib.models.user')
local config  = require('lib.config.config');
local log     = require('lib.bussiness.log');
local global  = require('lib.models.global');
local data    = require('lib.providers.provider');

local b = {}
b.isDirty = true


-- GET function
function b.getUser()
	local returnUser;
	if b.isDirty then
		log.debug('user data is isDirty need to make the load from physical data file');
		local userData =  data.load(data.getUserDataFiles(user));
		-- log.info(userData.fileDataId);
		if (userData == nil ) or (userData.fileDataId == nil )or (userData.fileDataId ~= user.name .. '_' .. user.deviceId) then
			log.debug("Is the first running for user, need to create this!");
			global.isFirstRun = true;
			for i = 1,#config.gameProgression.levels do
				local levelType = config.gameProgression.levels[i].type
				user.data.gameProgression.levels[levelType] = {}
				user.data.gameProgression.levels[levelType].max = config.gameProgression.levels[i].max
				user.data.gameProgression.levels[levelType].unlock = 1
				user.data.gameProgression.levels[levelType].data   = {}
				user.data.gameProgression.levels[levelType].type   = levelType
				user.data.gameProgression.levels[levelType].locked   = config.gameProgression.levels[i].locked
				user.data.gameProgression.levels[levelType].titleLabel   = config.gameProgression.levels[i].titleLabel

				--start initialization the analitical for levels
				user.data.analytics.levels[levelType] = {}
				user.data.analytics.levels[levelType].totalPlayed =0;
				user.data.analytics.levels[levelType].totalWinner =0;
				user.data.analytics.levels[levelType].totalLoser =0;
				user.data.analytics.levels[levelType].accumaledXp =0;
				user.data.analytics.levels[levelType].data ={}
			end
			user.data.gameProgression.runless = {}
			user.data.gameProgression.runless.locked = config.gameProgression.runless.locked
			user.data.gameProgression.runless.bestTime =0
			user.data.gameProgression.runless.score =0
			user.data.gameProgression.runless.bestTotalEnemiesKilled =0
			--start initialization the analitical for runless mode
			user.data.analytics.runless = {}
			user.data.analytics.runless.totalGames = 0
			user.data.analytics.runless.accTime = 0
			user.data.analytics.runless.accLosedXp = 0
			user.data.analytics.runless.totalEnemiesKilled = 0

			b.saveUser();
		else
			user.data = userData;
			-- returnUser =userData;
		end

	else
		log.error('dont load data');
		returnUser = user;
	end
	return user;
end

function b.updateLevel(type,number,data)
	--after the update of data, i'll save the data on file and put isDirty=true, so that way next time user is getted need to loaded from file!

end

function b.saveUser()

		local result = data.save(data.getUserDataFiles(user),user.data);
		if result then
			b.isDirty = true
		else
			log.error("user model unable to save");
		end

end


return b;
