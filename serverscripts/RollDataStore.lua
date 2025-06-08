local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local characterStore = DataStoreService:GetDataStore("CharacterInventory")
local rollEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RollCharacter")
local getInventoryFunction = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GetInventory")

-- Rolls and updates inventory
local function addToInventory(player, characterName)
	local userId = tostring(player.UserId)
	local success, data = pcall(function()
		return characterStore:GetAsync(userId)
	end)

	if not success then
		warn("Failed to get inventory for", player.Name)
		data = {}
	end

	data = data or {}
	data[characterName] = (data[characterName] or 0) + 1

	local saveSuccess, err = pcall(function()
		characterStore:SetAsync(userId, data)
	end)

	if not saveSuccess then
		warn("Failed to save inventory for", player.Name, err)
	end
end

-- Handle roll requests
rollEvent.OnServerEvent:Connect(function(player, characterName)
	addToInventory(player, characterName)
end)

-- Handle inventory fetch
getInventoryFunction.OnServerInvoke = function(player)
	local userId = tostring(player.UserId)
	local success, data = pcall(function()
		return characterStore:GetAsync(userId)
	end)
	if success then
		return data or {}
	else
		warn("Inventory fetch failed:", data)
		return {}
	end
end
