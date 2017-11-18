local TG = {}
local json = require("JSON")
local internet = require("internet")
local serial = require("serialization")
local fs = require("filesystem")
function TG.sendRequest(token,method,POST)
	local data = ""
	for chunk in internet.request("https://api.telegram.org/bot" .. token .. "/" .. method,POST) do
		data = data .. chunk
	end
	return json.decode(data)
end

function TG.sendMessage(token,chat_id,text)
	while true do
		local success, reason = pcall(TG.sendRequest,token,"sendMessage",{chat_id = chat_id, text = text})
		if success then return reason end
	end
end

function TG.getUpdates(token)
	while true do
		local success, reason = pcall(TG.sendRequest,token,"getUpdates",{offset = TG.lastUpdate})
		if success then
			for i = 1, #reason.result do
				TG.lastUpdate = reason.result[i].update_id + 1
			end
			return reason 
		end
	end
end

function TG.receiveMessages(token)
	local updates = TG.getUpdates(token,{offset = TG.lastUpdate})
	local messages = {}
	for i = 1, #updates.result do
		local update = updates.result[i]
		if update and update.message then
			local message = {update = update, text = update.message.text, chat_id = update.message.chat.id}
			table.insert(messages,message)
		end
	end
	return messages
end


return TG
