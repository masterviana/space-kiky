--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2be74e2a16ccddc59d889e7f6a51657d:7f3465261554e6198b363a3bc58f55a6:50b00ff7affc1d4eaa6f5b2e63e9d719$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- eating1
            x=101,
            y=2,
            width=90,
            height=70,

            sourceX = 27,
            sourceY = 37,
            sourceWidth = 142,
            sourceHeight = 142
        },
        {
            -- eating2
            x=193,
            y=2,
            width=90,
            height=70,

            sourceX = 27,
            sourceY = 37,
            sourceWidth = 142,
            sourceHeight = 142
        },
        {
            -- eating3
            x=285,
            y=2,
            width=90,
            height=70,

            sourceX = 27,
            sourceY = 37,
            sourceWidth = 142,
            sourceHeight = 142
        },
        {
            -- eating4
            x=2,
            y=2,
            width=97,
            height=70,

            sourceX = 24,
            sourceY = 37,
            sourceWidth = 142,
            sourceHeight = 142
        },
    },
    
    sheetContentWidth = 377,
    sheetContentHeight = 74
}

SheetInfo.frameIndex =
{

    ["eating1"] = 1,
    ["eating2"] = 2,
    ["eating3"] = 3,
    ["eating4"] = 4,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
