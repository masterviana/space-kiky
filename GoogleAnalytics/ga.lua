--[[

Google Analytics module for Corona SDK.
See module function comments below for usage and readme.txt for more information.

--]]


local M = {}; 

-- All settings should be set in the init function in the main.lua.
local _url = "http://google-analytics.com/collect"
local _htmlFileLocation = "GoogleAnalytics/ua.html" -- html file for user agent work around
local _timeOut = 10 -- Timeout in seconds when payload gets moved to be offline to be sent later
local _defaultParams -- Params sent with all events, set in init function
local _sessionParams -- Additional session level params. Set in init.
local _currentScene -- If known it will be sent with all events
local _pending = {} -- Payloads that are currently sending to Google
local _offline = {} -- Payloads that have failed to send and will be sent later

local debug = {}
debug.enabled = false -- Set in init function as a param

M.disabled = false -- Set ga.disabled = true to stop sending payloads to Google

-- Private functions
local send
local networkListener
local trimFromFront
local setUserAgentFromWebView
local copyTable
local getPayloadID
local mergeTables
local paramsToString
local fileExists

-- User agent workaround for iOS. See readme.txt for more information.
local _isApple = false
if string.sub(system.getInfo("model"), 1, 2) == "iP" then
    _isApple = true -- This is an apple device and we must use the user agent workaround
end
local _userAgent


-- See readme.txt how to init.
M.init = function(params)
    
    if _defaultParams then assert(false, "Google Analytics should only be initialized once"); return end
    
    local testTrackingID        = params.testTrackingID or assert(false, "Google Analytics fatal error. Test tracking ID is required.")
    local productionTrackingID  = params.productionTrackingID
    local isLive                = params.isLive
    debug.enabled               = params.debug
    
    if isLive ~= true and isLive ~= false then
        assert(false, "Google Analytics fatal error. isLive parameter is required. Set to true or false")
    elseif isLive and not productionTrackingID then
        assert(false, "Google Analytics fatal error. Production tracking ID is required when Live.")
    end
    
    local trackingID = testTrackingID
    if isLive then
        if system.getInfo("environment") == "simulator" then
            print("Google Analytics: We are doing it live but simulator still uses test tracking ID, device uses production ID.")
        else
            trackingID = productionTrackingID
        end
    end

    local defaultUrlParameters = {
        tid = trackingID, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#tid
        v   = params.protocolVersion or 1, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#v
        cid = params.clientID or system.getInfo("deviceID"), -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cid
        uid = params.userID or nil, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#uid
        an  = params.appName or system.getInfo("appName"), -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#an
        aid = params.appID or nil, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#aid
        av  = params.appVersion or system.getInfo("appVersionString"), -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#av
        sr  = math.floor(display.pixelWidth).."x"..math.floor(display.pixelHeight), -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#sr
        vp  = math.floor(display.contentWidth).."x"..math.floor(display.contentHeight), -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#vp
        ul  = system.getPreference("locale", "language"), -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ul
    }

    defaultUrlParameters = mergeTables(defaultUrlParameters, params.additionalDefaultParams)
    _defaultParams = paramsToString(defaultUrlParameters)
    debug.p(defaultUrlParameters, "Default parameters sent with all events")

    _sessionParams = params.sessionParams -- Params sent at beginning of every session
    
    if _isApple then -- Only Apple devices need iOS workaround
        setUserAgentFromWebView()
    end 
    
end


--[[
Register an event
https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#event
@param string category Required. Specifies the event category.
@param string action   Required. Specifies the event action. 
@param string label    Optional. Descriptor that you can use to provide further 
granularity such as "on" or "off" for a button click.
@param int value       Optional. Event value. Values must be non-negative.                 
@param table additionalParams Optional. Extra parameters you want to include. 
--]]
M.event = function(category, action, label, value, additionalParams)

    local params = {
        t = "event", -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t
        ec = category, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ec
        ea = action, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ea
        el = label, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#el
        ev = value -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ev
    }
    
    send(mergeTables(params, additionalParams))
        
end


--[[
User purchase event
For each transaction there should be an item hit. Hence there are 2 payloads 
in this function. See urls for additional params you might want to use:
https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#ecom
https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ecomm
@param string transactionID  Required. Unique transaction ID
@param string itemName       Required. 
@param string itemCategory   Optional. 
@param string itemCode       Optional. Example com.myCompany.products.extraLife
@param currency price        Optional. Example 1.99
@param string currencyCode   Optional. Example USD 
@param trable additionalParamsItem Optional.
@param trable additionalParamsTransaction Optional.
--]]
M.purchase = function(transactionID, itemName, itemCategory, itemCode, price, currencyCode, additionalParamsItem, additionalParamsTransaction)
    
    -- Item Hit
    local itemParams = {
        t = "item", -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t
        ti = transactionID, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ti
        ip = price, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ip
        cu = currencyCode, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cu
        ic = itemCode, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ic
        iv = itemCategory, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#iv
    }
    
    itemParams["in"] = itemName -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#in -- 'in' is a reserved Lua name, so have to put it in quotation marks.
    
    send(mergeTables(itemParams, additionalParamsItem))    
    
    -- Transaction Hit
    local transActionParams = {
        t = "transaction", -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t
        ti = transactionID, -- transaction ID. Required.
        tr = price, -- Transaction revenue.
        cu=currencyCode -- Currency code.
    }

    send(mergeTables(transActionParams, additionalParamsTransaction))    
        
end


--[[
Timed event. 
https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#usertiming
@param int milliseconds Optional.
@param string category  Optional.
@param string variable  Optional.
@param string label     Optional.
@param table additionalParams Optional. Extra parameters you want to include. 
 --]]
M.time = function(milliseconds, category, variable, label, additionalParams)
    
    milliseconds = tonumber(milliseconds) or 0
    
    local params = {
        t = "timing", -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t
        utt = math.floor(milliseconds), -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#utt
        utc = category, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#utc
        utv = variable, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#utv
        utl = label, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#utl
    }
    
    send(mergeTables(params, additionalParams))
    
end

--[[
Social event
https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#social
@param string socialNetwork Required. The social network with which the user is 
    interacting (e.g. Facebook, Google+, Twitter, etc.).
@param string target Required. The content on which the social action is being 
    taken (i.e. a specific article or video).
@param string action Required. The social action taken (e.g. Like, Share, +1, etc.).
@param table additionalParams Optional. Extra parameters you want to include. 
--]] 
M.social = function(socialNetwork, target, action, additionalParams)
    
    local params = {
        t = "social", -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t
        sn = socialNetwork, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#sn
        st = target, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#st
        sa = action, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#sa
    }
    
    send(mergeTables(params, additionalParams))
    
end


--[[
Exception tracking
https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#exception
@param string description   Optional. 
@param bool fatal           Optional. Fatal exception or not
@param string description   Optional. 
@param table additionalParams Optional. Extra parameters you want to include. 
--]]
M.error = function(description, fatal, additionalParams)
    
    if fatal == true then
        fatal = 1
    elseif fatal ~= 1 then
        fatal = 0
    end
    
    local params = {
        t = "exception", -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t 
        exd = description, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#exd
        exf = fatal, -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#exf
    }
    
    send(mergeTables(params, additionalParams))

end


--[[
Screen tracking. Do not use if using automatic scene tracking.
-- https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#screenView
@param string sceneName Required. 
@param table additionalParams Optional. Extra parameters you want to include. 
--]]
M.enterScene = function(sceneName, additionalParams)
    
    _currentScene = sceneName
    
    local params = {
        t = "screenview", -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#t 
        -- cd = _currentScene -- Not required, scene name is appended in send function to all events if available
    }

    send(mergeTables(params, additionalParams))
    
end



-- Send 1 pending offline payload. This function is also called every time a payload 
-- is sent successfully to check if there are any offline payloads waiting. Payloads
-- are sent one at a time after each successful send. Offline payloads get a "qt" 
-- parameter added to them: https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#qt
local sendOffline = function()
    
    -- Check if we have reached time outs on any _pending payloads and if so move to _offline
    for payloadID, payload in pairs(_pending) do
        if (system.getTimer() - payload.time) / 1000 > _timeOut then
            debug.p(payloadID, "Timed out, will be sent as offline payload")
            _offline[payloadID] = copyTable(_pending[payloadID])
            _pending[payloadID] = nil
        end
    end
    
    local sendNext = next(_offline)
    if not sendNext then return end -- No offline payloads to be delivered
    
    debug.p(sendNext, 'Found waiting offline event to be sent')
    local offlineEvent = _offline[sendNext]
    local eventTime = offlineEvent.time
    local params = offlineEvent.params
    params.qt = math.floor(system.getTimer() - eventTime) -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#qt
    send(params, sendNext)
    
end




-- Storyboard scene management
-- https://developers.google.com/analytics/devguides/collection/protocol/v1/devguide#screenView
------------------------------------------------------------------------------------
-- Override the storyboard.newScene and storyboard.showOverlay functions to 
-- enable screen tracking. 
-- Custom scene names:
-- If you wish to override the scene name, for examples if you use a single scene for
-- multiple different things can use params.analyticsName in gotoScene. Example: 
-- storyboard.gotoScene('popup', {params = {analyticsName = "Wrong password popup"}})
M.enableStoryBoardScenes = function()
    
    local storyboard = require("storyboard")
    local newSceneOriginal = storyboard.newScene
    local showOverlayOriginal = storyboard.showOverlay
    local hasOverlay = false
    local sceneNameUnderOverlay

    storyboard.newScene = function()

        local scene = newSceneOriginal()

        local function enterScene(event)

            local sceneName
            -- If analyticsName is specified in params
            if event and event.params and event.params.analyticsName then
                sceneName = event.params.analyticsName
            end

            local sceneName = sceneName or hasOverlay or storyboard.getCurrentSceneName()
            sceneName = string.sub(sceneName, (sceneName:match'^.*()%.' or 0) +1) -- If scene file is in a directory this will delete the directory from the scene name
            
            M.enterScene(sceneName)
            
        end

        local function overlayEnded()
            hasOverlay = false
            enterScene({params = {analyticsName = sceneNameUnderOverlay}}) -- When an overlay is ended it does not trigger enterScene again, so do that manually
        end

        scene:addEventListener("enterScene", enterScene)
        scene:addEventListener("overlayEnded", overlayEnded)

        return scene

    end

    storyboard.showOverlay = function(sceneName, options)
        -- Need to monitor showOverlay since getCurrentSceneName
        -- does not get overlay names but only the scene name underneith.
        -- Wanted to have overlayBegan listener instead of this but it 
        -- fires after enterScene listener making it impracticle.
        sceneNameUnderOverlay = _currentScene
        hasOverlay = sceneName
        showOverlayOriginal(sceneName, options)
    end

end








--
----
------ Private function
----                    
--


-- System event listeners to check for session starting and ending
-- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#session
local _sessionStartTime
local function sessionControlEvent(event)
    
    local eventType = event.type
    
    if  eventType == "applicationStart" or eventType == "applicationResume" then
        
        _sessionStartTime = system.getTimer()
        M.event("Sessions", "Session control", "start", os.date("%H"), mergeTables({sc = "start"}, _sessionParams)) -- Using value as current hour just to use it for something
        
    elseif eventType == "applicationSuspend" then
        
        if _sessionStartTime then
            -- Setting value as how long the session lasted in seconds, 
            -- presumbly more accurate than session times Google can provide?
            local sessionLength = math.floor((system.getTimer() - _sessionStartTime)/1000) -- In seconds
            local params = {sc = "end"}
            M.event("Sessions", "Session control", "end", sessionLength, params) 
        end
        
    elseif  eventType == "applicationExit" then
        -- Do not use. Sending HTTP request on EXIT crashes simulator on refresh and perhaps devices
    end
    
end

Runtime:addEventListener("system", sessionControlEvent);



-- Network listener for requests to Google
function networkListener(event)  
    
    local url, payloadID
    if event and event.url then 
        url = event.url
        payloadID = trimFromFront(url, "payloadID") -- Extract the payload ID from URL
    end
    
    if event.isError and payloadID then
        
        -- When sending fails we only try to resend it twice more because offline 
        -- payloads are only sent when we have just successfully sent something else. 
        -- If they are failing repeatedly something serious is going on and we don't 
        -- want to be stuck in a loop sending offline payloads again and again.

        debug.p(event, "ERROR: Payload delivery unsuccessful")

        local op = _offline[payloadID]
        if op and not op.retry then op.retry = 0 end

        if op and op.retry > 2 then
            debug.p(payloadID, "ERROR: Retried this payload to many times, discarding")
            _offline[payloadID] = nil
        elseif op then
            debug.p(payloadID, "ERROR: Offline payload failing again, will retry later")
            op.retry = op.retry + 1
        elseif _pending[payloadID] then
            debug.p(payloadID, "ERROR: Failed to send payload, moving to offline where it will be retried once a successful payload has been delivered")
            _offline[payloadID] = copyTable(_pending[payloadID])
            _pending[payloadID] = nil
        end
            
    else -- Success
    
        if payloadID then
            debug.p(payloadID, "Payload sent successfully")
            _pending[payloadID] = nil
            _offline[payloadID] = nil 
            sendOffline() -- A successful payload was delivered so check if any offline payloads are pending
        end
        
    end 
    
end 


--[[
Send payloads to to Google
@param table params A table of url parameters that will be added to the defult
                    parameters and then sent as a POST network.request to Google.
@param string payloadID Optional payloadID for offline events that already have IDs.
--]]
function send(params, payloadID)
    
    if M.disabled or not _defaultParams then
        debug.p("Not initialized or disabled. Not sending to Google")
        return
    end
    
    local payloadID = payloadID or getPayloadID() -- Unique ID for each payload
    
    if _isApple and not _userAgent then
        debug.p(payloadID, "Not sending data because user agent is still missing. Will retry when user agent is available")
        _offline[payloadID] = {time = system.getTimer(), params = params} -- Add offline payload
        return
    elseif _isApple and _userAgent then
        params.ua = _userAgent -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#ua
    end
    
    if _currentScene and not params.cd then
        -- If scene tracking is used this will be added to every event
        params.cd = _currentScene -- https://developers.google.com/analytics/devguides/collection/protocol/v1/parameters#cd
    end
    
    local eventParams = _defaultParams .. paramsToString(params) -- Combine parameters with the default parameters
    
    local headers = {}
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    
    if not _offline[payloadID] then
        -- First timers are added to the pending table and then removed on 
        -- success sending or moved to _offline on fail.
        _pending[payloadID] = {time = system.getTimer(), params = params} 
    end
    
    local requestParams = {
        headers = headers,
        body = eventParams
    }

    local url = _url .. "#payloadID" .. payloadID -- Append the payloadID to the URL so we can track when its returned in the network listener
    network.request(url, "POST", networkListener, requestParams )
    
    -- Showing GET URL in debug but using POST to send to Google (both will work)
    -- https://developers.google.com/analytics/devguides/collection/protocol/v1/reference
    debug.p(params, "Sending payload: " .. payloadID .. ": " .. _url .. "?" .. eventParams)
    
end



-- See readme.txt about user agent work around for iOS devices.
function setUserAgentFromWebView()
    
    if not fileExists(_htmlFileLocation, system.ResourceDirectory) then
        assert(false, "Google Analytics: ERROR. Can't find local User Agent HTML file: " .. _htmlFileLocation);
        return false
    end
    
    local uaWebView = native.newWebView(0, -display.contentHeight, 5, 5 ) -- Position webview off screen
    
    local function uaListener(event)
        
        if event and event.url and not _userAgent then
            
            _userAgent = trimFromFront(event.url, "userAgent=")
            
            if _userAgent then
                debug.p(_userAgent, "User agent from web view")
                uaWebView:removeSelf()
                sendOffline() -- Send any pending events to Google that did not send because there was no user agent yet.
            end
            
        end
        
        if event.errorCode then
           print("Google Analytics ERROR. Failed to get user agent!") 
        end
        
    end
    
    uaWebView:request(_htmlFileLocation, system.ResourceDirectory)
    uaWebView:addEventListener("urlRequest", uaListener)
        
end




-- Contruct an URL compatable string from a table of parameters
-- @param table params The parameters to be used in {paramName = paramValue, etc} format.
local urlOperations = require("socket.url")
local urlEncode = urlOperations.escape
function paramsToString(params)
     
    local paramsString = ""
    for name, value in pairs(params) do
        if value then 
            value = urlEncode(tostring(value))
            if string.len(value) > 0 then -- No empty values are to be sent
                paramsString = paramsString .. name .. "=" .. value .. "&"
            end
        end
    end
    
    return paramsString
    
end

--[[
Trim a string from front from where it finds target string, including target.
@param string str String to be trimmed
@param string findStr From where to trim string from front, including findStr
@returns string or nil Returns trimmed string or nil if findStr is not found
Example: trimFromFront("abc123", "bc") -- Returns 123
--]]
function trimFromFront(str, findStr)
    if not string.find(str, findStr) then return nil end
    return string.sub(str, (str:match('^.*()'..findStr) or 0) + string.len(findStr))
end

-- Create a copy of the first level of a table
function copyTable(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

-- Provides a unique ID for each payload
local getPayloadID_id = 0
function getPayloadID()
    getPayloadID_id = getPayloadID_id + 1
    return "pid" .. getPayloadID_id 
end

-- Merge 2 tables
function mergeTables(t1, t2)
    if type(t1) ~= "table" then t1 = {} end
    if type(t2) ~= "table" then t2 = {} end
    for k,v in pairs(t2) do t1[k] = v end
    return t1
end


function fileExists(myFile, directoryName)
    
    local directoryName = directoryName or system.DocumentsDirectory

    local filePath = system.pathForFile(myFile, directoryName)
    local results = false
    if filePath == nil then
        return false
    else
        local file = io.open(filePath, "r")
        if file then
                io.close(file)
            results = true
        end
        return results
    end
    
end

-- Pretty printer
debug.pr = function(t, name, indent)
  local tableList = {}
  local function table_r (t, name, indent, full)
    local id = not full and name
        or type(name)~="number" and tostring(name) or '['..name..']'
    local tag = indent .. id .. ' = '
    local out = {}      -- result
    if type(t) == "table" then
      if tableList[t] ~= nil then table.insert(out, tag .. '{} -- ' .. tableList[t] .. ' (self reference)')
      else
        tableList[t]= full and (full .. '.' .. id) or id
        if next(t) then -- Table not empty
          table.insert(out, tag .. '{')
          for key,value in pairs(t) do 
            table.insert(out,table_r(value,key,indent .. '|  ',tableList[t]))
          end 
          table.insert(out,indent .. '},')
        else table.insert(out,tag .. '{}') end
      end
    else 
      local val = type(t)~="number" and type(t)~="boolean" and '"'..tostring(t)..'"' or tostring(t)
      table.insert(out, tag .. val .. ',')
    end
    return table.concat(out, '\n')
  end
  return table_r(t,name or 'Value',indent or '')
end

debug.p = function(t, name)
    if debug.enabled then
        print('GA DEBUG: [' .. type(t) .. '] ' .. debug.pr(t,name))
    end
end




return M