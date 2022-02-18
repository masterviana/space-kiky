local log = {}

function log.error(message) 
	print('LOG:ERROR |', message, '|')
end

function log.debug(message) 
	print('LOG:debug |', message, '|')
end

function log.info(message) 
	print('LOG:info |', message,'|')
end

return log;