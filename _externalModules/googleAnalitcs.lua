-- https://bitbucket.org/Jonjonsson/google-analytics-for-corona-sdk/
local ga = require("GoogleAnalytics.ga")

local ControlGa = {}


ga.init({ -- Only initialize once, not in every file
    isLive = false, -- REQUIRED
    testTrackingID = "UA-61775216-1", -- REQUIRED Tracking ID from Google
    debug = false, -- Recomended when starting
    appName = "Dawn of Penguins (dev)",
    appID  = "com.stormStudio.kiky",
    clientID = system.getInfo("deviceID"),
    userID = system.getInfo("name"),
    appVersion = "0.0.8",
    cd1 = "RegularVersion"


})

--added after init as the create for this order!
ga.enableStoryBoardScenes()

-- ga.event("Settings", "Sound", "Off") -- Example user turning off sound

function ControlGa.EnterScene (sceneName)
	ga.enterScene(sceneName)
end

function ControlGa.SendOption(key,value)
	ga.event("Options",key,value)
end

function ControlGa.Social(key,value)
	ga.social("Facebook",key, value)
end


function ControlGa.Logger(message,fatal)
    ga.error(message, fatal)
end

function ControlGa.Error(message,fatal)
	ga.error(message,fatal)
end



return ControlGa
