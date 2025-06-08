-- This is a moudle script
local module = {}

local DataStoreService = game:GetService("DataStoreService")
local lightstickStore = DataStoreService:GetDataStore("LightstickStore")

local Template = {
	["NJZStick"] = 0,
	["SKZStick"] = 0
}

-- Deep copy helper
local function deepCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepCopy(orig_key)] = deepCopy(orig_value)
		end
		setmetatable(copy, deepCopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

-- In-memory player data
local playerLightstickData = {}

-- Load data when player joins
game.Players.PlayerAdded:Connect(function(player)
	local userId = player.UserId
	local key = tostring(userId)

	local success, data = pcall(function()
		return lightstickStore:GetAsync(key)
	end)

	if success then
		if not data then
			data = deepCopy(Template)
			local saveSuccess, err = pcall(function()
				lightstickStore:SetAsync(key, data)
			end)
			if not saveSuccess then
				warn("Failed to initialize data for", player.Name, ":", err)
			end
		end
	else
		warn("Failed to load data for", player.Name, ":", data)
		data = deepCopy(Template) -- use default if load fails
	end

	playerLightstickData[userId] = data

	print(player.Name .. "'s Lightstick Inventory:")
	for stickName, count in pairs(data) do
		print("  " .. stickName .. ": " .. tostring(count))
	end
end)

-- Save data when player leaves
game.Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	local key = tostring(userId)
	local data = playerLightstickData[userId]

	if data then
		local success, err = pcall(function()
			lightstickStore:UpdateAsync(key, function(oldData)
				return data
			end)
		end)

		if not success then
			warn("Failed to save data for", player.Name, ":", err)
		end

		playerLightstickData[userId] = nil
	end
end)

-- Save data on server shutdown
game:BindToClose(function()
	for userId, data in pairs(playerLightstickData) do
		local key = tostring(userId)
		pcall(function()
			lightstickStore:UpdateAsync(key, function()
				return data
			end)
		end)
	end
end)

-- Add +1 to a stick
function AddStick(player, stickName)
	local data = playerLightstickData[player.UserId]
	if data and data[stickName] ~= nil then
		data[stickName] = data[stickName] + 1
	end
end

-- Subtract -1 from a stick
function SubtractStick(player, stickName)
	local data = playerLightstickData[player.UserId]
	if data and data[stickName] ~= nil and data[stickName] > 0 then
		data[stickName] = data[stickName] - 1
		return true
	else
		return false
	end
end

-- Get current inventory
function GetInventory(player)
	local data = playerLightstickData[player.UserId]
	if data then
		return data
	else
		return deepCopy(Template)
	end
end

-- Add this at the end:
module.AddStick = AddStick
module.SubtractStick = SubtractStick
module.GetInventory = GetInventory

return module
