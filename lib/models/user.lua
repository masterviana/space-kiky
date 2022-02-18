
local user = {}
user.name = system.getInfo("environment");
user.deviceId = system.getInfo("deviceID");
user.data = {}
user.data.fileDataId = user.name .. '_' .. user.deviceId
user.data.settings = {}
user.data.settings.sound = true;
user.data.xp = 0;
user.data.profileLevel =1;
user.data.gameProgression = {};
user.data.gameProgression.levels  = {}
-- Game progression levels sample object
-- with levels
-- config.gameProgression.levels  = {}
-- config.gameProgression.levels['easy'] = {}
-- config.gameProgression.levels['easy'].max = 20
-- config.gameProgression.levels['easy'].unlock = 1
-- config.gameProgression.levels['easy'].data = {}
-- config.gameProgression.levels['easy'].data[i] = {}
-- config.gameProgression.levels['easy'].data[i].stars = 3
-- config.gameProgression.levels['easy'].data[i].score = 20
-- config.gameProgression.levels['easy'].data[i].bestTime  = 1231231231
-- config.gameProgression.levels['regular'] = {}
-- config.gameProgression.levels['regular'].max = 20
-- config.gameProgression.levels['regular'].unlock = 1
-- config.gameProgression.levels['regular'].data = {}
-- config.gameProgression.levels['regular'].data[i] = {}
-- config.gameProgression.levels['regular'].data[i].stars = 3
-- config.gameProgression.levels['regular'].data[i].score = 20
-- config.gameProgression.levels['regular'].data[i].bestTime  = 1231231231
user.data.gameProgression.runless  = {}
-- in runless mode
user.data.gameProgression.runless = {}
user.data.gameProgression.runless.locked = false
user.data.gameProgression.runless.bestTime =0
user.data.gameProgression.runless.score =0
user.data.gameProgression.runless.bestTotalEnemiesKilled =0

-- ANALITICAL DATA
-- analitical data just for checking users performance!!
-- i did know what i'll did with this yet! but its nice save some data, to create leader boards and achivements
user.data.analytics = {}
user.data.analytics.levels = {}
-- sample of data using!
-- user.data.analytics.levels['easy'] = {}
-- user.data.analytics.levels['easy'].totalPlayed = 0
-- user.data.analytics.levels['easy'].totalWinner = 0
-- user.data.analytics.levels['easy'].totalLoser = 0
-- user.data.analytics.levels['easy'].accumaledXp = 0
-- user.data.analytics.levels['easy'].data = {}
-- user.data.analytics.levels['easy'].data[i].clearLevelAtFirst = 0
-- user.data.analytics.levels['easy'].data[i].totalPlayed = 0
-- user.data.analytics.levels['easy'].data[i].totalWinner = 0
-- user.data.analytics.levels['easy'].data[i].totalLoser = 0
-- user.data.analytics.levels['easy'].data[i].accumaledXp = 0

user.data.analytics.runless = {}
user.data.analytics.runless.totalGames = 0
user.data.analytics.runless.accTime = 0
user.data.analytics.runless.accLosedXp = 0
user.data.analytics.runless.totalEnemiesKilled = 0
user.data.analytics.runless.totalXpOnBonus = 0
user.data.analytics.runless.totalBonusItens = 0





return user;