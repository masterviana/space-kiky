
local config = {}
-- saved things are only changed when need to change something on app
config.debug = true
config.gameDataStoreProvider = 'local'
config.logLevel = 3;
config.systemLanguage = system.getPreference( "locale", "language" );
print("language : " ..system.getPreference( "locale", "language" ))
print(system.getPreference( "locale", "language" ))
config.gameProgression = {}
config.gameProgression.runless = {}
config.gameProgression.runless.locked = true
config.gameProgression.levels  = {}
config.gameProgression.levels.defaultTypeLevelMax = 3
config.gameProgression.levels.defaultTypeLevelIndex = 1
config.gameProgression.levels[1] = {}
config.gameProgression.levels[1].max = 18
config.gameProgression.levels[1].type = 1
config.gameProgression.levels[1].locked = false
config.gameProgression.levels[1].maxTime = 18000
config.gameProgression.levels[1].titleLabel = "Easy Levels"
config.gameProgression.levels[2] = {}
config.gameProgression.levels[2].max = 18
config.gameProgression.levels[2].type = 2
config.gameProgression.levels[2].locked = true
config.gameProgression.levels[2].maxTime = 18000
config.gameProgression.levels[2].titleLabel = "Regular levels"
config.gameProgression.levels[3] = {}
config.gameProgression.levels[3].max = 18
config.gameProgression.levels[3].type = 3
config.gameProgression.levels[3].maxTime = 18000
config.gameProgression.levels[3].locked = true
config.gameProgression.levels[3].titleLabel = "Impossible Levels"

config.gamePlayer = {}
config.gamePlayer.playerWidth = 4.5
config.gamePlayer.playerHeigth = 8
config.gamePlayer.opponentWidth = 4.5
config.gamePlayer.opponentHeigth = 8

config.gamePlayer.verticalImpulse = 21
config.gamePlayer.horizontalImpulse = 18.7


return config
