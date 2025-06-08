local DataStoreService = game:GetService("DataStoreService")
local SaveDS = DataStoreService:GetDataStore("SaveMyData")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpinEvent = ReplicatedStorage:WaitForChild("SpinEvent")

game.Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local totalSpins = Instance.new("IntValue")
	totalSpins.Name = "Photocards"
	totalSpins.Value = 0
	totalSpins.Parent = leaderstats

	local plrKey = "id_" .. player.UserId
	local success, data = pcall(function()
		return SaveDS:GetAsync(plrKey)
	end)

	if success and data then
		totalSpins.Value = data
	end
end)

game.Players.PlayerRemoving:Connect(function(player)
	local plrKey = "id_" .. player.UserId
	local spins = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Photocards")
	if spins then
		pcall(function()
			SaveDS:SetAsync(plrKey, spins.Value)
		end)
	end
end)

SpinEvent.OnServerEvent:Connect(function(player)
	local spins = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Photocards")
	if spins then
		spins.Value += 1
	end
end)
