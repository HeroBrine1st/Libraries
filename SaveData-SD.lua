local SD = {}
local fs = require("filesystem")
local serial = require("serialization")

function SD.saveData(name,data)
	checkArg(2,data,"table")
	checkArg(1,name,"string")
	data = serial.serialize(data)
	local path = fs.concat("/database/",name)
	fs.makeDirectory("/database/")
	local handle, reason = io.open(path,"w")
	if not handle then return nil, reason end
	handle:write(data)
	handle:close()
	return true
end

function SD.readData(name)
	checkArg(1,name,"string")
	local path = fs.concat("/database/",name)
	local handle, reason = io.open(path,"r")
	if not handle then return nil, reason end
	local buffer = ""
	repeat
		local data,reason = handle:read()
		if data then buffer = buffer .. data end
		if not data and reason then handle:close() return nil, reason end
	until not data
	handle:close()
	return serial.unserialize(buffer)
end

return SD
