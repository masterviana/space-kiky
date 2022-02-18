local json = require "json"

local levelsLoader = {}
levelsLoader.levels = {}
levelsLoader.max = 5
levelsLoader.isLoaded = false


function levelsLoader.getCache(number)
      local  levelData = levelsLoader.levels[number]
      
      if levelData == nil then     
        levelsLoader.levels[number] = levelData
      else
        print('hit on cache')
     end
     
      return levelData  
end

 function levelsLoader.loadTable(filename)
    local path = system.pathForFile( filename, system.ResourceDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        --print("trying to read ", filename)
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        myTable = json.decode(contents);
        io.close( file )
        --print("Loaded file")
        return myTable
    end
    print(filename, "file not found")
    return nil
end

 function levelsLoader.getLevel(number)
        if tonumber(number) > 5 then
          number = 1
        end
        local str = string.format("levels/level%d.json", number);
        level = levelsLoader.loadTable(str);

        print('data level is ', level.data)
        
        if level == nill then
            print('error loading level')
        else
            return level
        end
 end

  function levelsLoader.save( filename, dataTable )
    --encode table into json string
    local jsonString = json.encode( dataTable )
    -- create a file path for corona i/o
    local path = system.pathForFile( filename, system.ResourceDirectory )
    -- io.open opens a file at path. Creates one if doesn't exist
    local file = io.open( path, "w" )
    if file then
        --write json string into file
       file:write( jsonString )
       -- close the file after using it
       io.close( file )
    end
    return true;
end




return levelsLoader
