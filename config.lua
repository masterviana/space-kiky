application =
{
	content =
	{
		width = 0,
        height = 0,
		scale = "letterBox",
		fps = 60
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
		},
		--]]
	},
	android =
    {
        versionCode = "11",
        usesPermissions =
        {
            "android.permission.INTERNET",
            "android.permission.WRITE_EXTERNAL_STORAGE",
            "android.permission.ACCESS_FINE_LOCATION",
            "android.permission.ACCESS_COARSE_LOCATION",
        },
        googlePlayGamesAppId = "1011083537495",
    },
		plugins =
    {
        ["CoronaProvider.gameNetwork.google"] =
        {
            publisherId = "com.coronalabs",
            supportedPlatforms = { android=true },
        },
    },



	--[[
	-- Push notifications
	notification =
	{
		iphone =
		{
			types =
			{
				"badge", "sound", "alert", "newsstand"
			}
		}
	},
	--]]
}
