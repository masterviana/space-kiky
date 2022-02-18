local localProvider = require('lib.providers.local')
local user    = require('lib.models.user');
local config  = require('lib.config.config');
local log     = require('lib.bussiness.log');

local providers = {}
providers['local'] = localProvider
providers['google'] = nil

-- save the file from a config provider (local | google)
function providers.save(filename,dataTable)
	if providers[config.gameDataStoreProvider] == nil then
		log.info("this provider doesnt exist ",config.gameDataStoreProvider);
	else
		providers[config.gameDataStoreProvider].save(filename,dataTable);
	end
end

-- load the file from a config provider (local | google)
function providers.load(filename)
	if providers[config.gameDataStoreProvider] == nil then
		log.info("this provider doesnt exist ",config.gameDataStoreProvider);
		return nil;
	else
		return providers[config.gameDataStoreProvider].load(filename);
	end
end

function providers.getUserDataFiles(user)
	if providers[config.gameDataStoreProvider] == nil then
		log.info("this provider doesnt exist " .. config.gameDataStoreProvider);
		return nil
	else
		return providers[config.gameDataStoreProvider].getUserDataFiles(user);
	end
end

return providers