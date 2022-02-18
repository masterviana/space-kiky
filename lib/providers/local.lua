local json = require "json"
local user = require "lib.models.user"
local log  = require "lib.bussiness.log"

local localStore = {}


 function localStore.save( filename, dataTable )
    --encode table into json string
    local jsonString = json.encode( dataTable )
    -- create a file path for corona i/o
    local path = system.pathForFile( filename, system.ResourceDirectory)

    log.error('path file is ' .. path);
    -- io.open opens a file at path. Creates one if doesn't exist
    local file = io.open( path, "w" )
    if file then
        --write json string into file
       file:write( jsonString )
       -- close the file after using it
       io.close( file )

        return true;
    else
        log.error("unable to save file " .. filename);
        return false
    end

   
end

 function localStore.load(filename)
    local path = system.pathForFile( filename, system.ResourceDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        --print("trying to read ", filename)
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        log.debug(contents);
        myTable = json.decode(contents);
        io.close( file )
        --print("Loaded file")
        return myTable
    end
        log.error("file not found " .. filename);
    return nil
end

function localStore.getUserDataFiles(user)
     -- log.debug("local data location is "..'_dataStore/' .. user.name .. "_" .. user.deviceId );
     local returned ="_dataStore/savedLevels.json"
    return  returned;
end


return localStore