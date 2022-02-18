local M = {}
M.maxLevels = 20
M.settings = {}
M.settings.currentLevel = 1
M.settings.unlockedLevels = 3
M.settings.soundOn = true
M.settings.musicOn = true
M.settings.levels = {}
M.settings.message =""
M.settings.time =""

-- These lines are just here to pre-populate the table.
-- In reality, your app would likely create a level entry when each level is unlocked and the score/stars are saved.
-- Perhaps this happens at the end of your game level, or in a scene between game levels.
M.settings.levels = {}
M.settings.levels[1] = {}
M.settings.levels[1].stars = 3
M.settings.levels[1].score = 3833
M.settings.levels[1].time =0
M.settings.levels[2] = {}
M.settings.levels[2].stars = 2
M.settings.levels[2].score = 4394
M.settings.levels[3] = {}
M.settings.levels[3].stars = 1
M.settings.levels[3].score = 8384
M.settings.levels[4] = {}
M.settings.levels[4].stars = 0
M.settings.levels[4].score = 10294
M.settings.levels[5] = {}
M.settings.levels[5].stars = 0
M.settings.levels[5].score = 10294
-- levels data members:
--      .stars -- Stars earned per level
--      .score -- Score for the level

function M:saveLevelData (level,time,score)

end

function M:LoadLevelData(level)

end

return M
