local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LightstickManager = require(script.Parent:WaitForChild("LightstickDataStore"))

-- Event to subtract a stick
ReplicatedStorage.SubtractStickEvent.OnServerEvent:Connect(function(player, stickName)
	local success = LightstickManager.SubtractStick(player, stickName)
	if not success then
		warn(player.Name .. " tried to subtract a stick they don't have.")
	end
end)

-- Function to get inventory
ReplicatedStorage.GetStorageFunction.OnServerInvoke = function(player)
	return LightstickManager.GetInventory(player)
end
