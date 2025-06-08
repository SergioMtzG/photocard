local replicatedStorage = game:GetService("ReplicatedStorage")
local charactersFolder = replicatedStorage:WaitForChild("NPCModels")

-- Function to create a follower with a given name and side offset
local function createFollower(name, sideOffset, playerHRP)
	-- Loop through each group folder inside NPCModels to find the matching NPC model
	local clone
	for _, groupFolder in ipairs(charactersFolder:GetChildren()) do
		if groupFolder:IsA("Folder") and groupFolder:FindFirstChild(name) then
			clone = groupFolder[name]:Clone()
			break
		end
	end

	if not clone then
		warn("Follower model not found: " .. name)
		return nil
	end

	clone.Name = name
	clone.Parent = workspace
	local humanoid = clone:WaitForChild("Humanoid")
	local hrp = clone:WaitForChild("HumanoidRootPart")

	-- Teleport the follower to the correct position next to the player
	local sideOffsetVec = playerHRP.CFrame.RightVector * sideOffset
	local backOffsetVec = playerHRP.CFrame.LookVector * -2
	local targetPosition = playerHRP.Position + sideOffsetVec + backOffsetVec + Vector3.new(0, 3, 0)

	-- Place the HRP directly at the final position
	hrp.CFrame = CFrame.new(targetPosition, playerHRP.Position) 

	-- Set up Animator and Walk Animation
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local walkAnim = Instance.new("Animation")
	walkAnim.AnimationId = "rbxassetid://507777826" -- R15 walk
	local walkTrack = animator:LoadAnimation(walkAnim)

	return {
		model = clone,
		humanoid = humanoid,
		hrp = hrp,
		walkTrack = walkTrack,
		sideOffset = sideOffset,
		name = name
	}
end

-- Function to check if the follower is within a certain distance of the player and teleport if not
local function checkAndTeleportIfNotInVicinity(follower, playerHRP, maxDistance)
	while follower and follower.model and follower.model.Parent do
		task.wait(1) -- Check every second

		if not playerHRP or not playerHRP.Parent then return end

		local distance = (follower.hrp.Position - playerHRP.Position).Magnitude

		-- If the follower is not within the specified max distance, teleport it back to the player
		if distance > maxDistance then
			follower.hrp.CFrame = playerHRP.CFrame + (playerHRP.CFrame.RightVector * follower.sideOffset)
		end
	end
end

-- Function to detect if the NPC has fallen or is in an invalid state and teleport them back
local function detectAndTeleportIfFallen(follower, playerHRP)
	while follower and follower.model and follower.model.Parent do
		task.wait(1) -- Check every second

		if not playerHRP or not playerHRP.Parent then return end

		local humanoid = follower.humanoid
		local state = humanoid:GetState()

		-- Check if the humanoid is falling or seated (indicating that the NPC has fallen)
		if state == Enum.HumanoidStateType.Seated or state == Enum.HumanoidStateType.FallingDown then
			-- Teleport the NPC back to the player
			follower.hrp.CFrame = playerHRP.CFrame + (playerHRP.CFrame.RightVector * follower.sideOffset)
		end
	end
end

-- Function to remove a follower
local function removeFollower(follower)
	if follower and follower.model and follower.model.Parent then
		follower.model:Destroy()
		return true
	end
	return false
end

-- Set up remote events if they don't exist
if not replicatedStorage:FindFirstChild("EquipFollowerEvent") then
	local equipEvent = Instance.new("RemoteEvent")
	equipEvent.Name = "EquipFollowerEvent"
	equipEvent.Parent = replicatedStorage
end

if not replicatedStorage:FindFirstChild("RemoveFollowerEvent") then
	local removeEvent = Instance.new("RemoteEvent")
	removeEvent.Name = "RemoveFollowerEvent"
	removeEvent.Parent = replicatedStorage
end

-- Create a cache to store follower instances
local followerCache = {}

-- Function to handle follower movement
function startFollowerMovement(follower, playerHRP)
	task.wait(0.5)
	
	while follower and follower.model and follower.model.Parent do
		if not playerHRP or not playerHRP.Parent then return end

		local offset = (playerHRP.CFrame.RightVector * follower.sideOffset) - (playerHRP.CFrame.LookVector * 2)
		local targetPosition = playerHRP.Position + offset
		local distance = (follower.hrp.Position - targetPosition).Magnitude

		-- Move follower to target position smoothly
		if distance > 1 then
			follower.humanoid:MoveTo(targetPosition)
			if not follower.walkTrack.IsPlaying then
				follower.walkTrack:Play()
			end
		else
			follower.humanoid:MoveTo(follower.hrp.Position)
			follower.walkTrack:Stop()
		end

		task.wait(0.01)
	end
end

-- Listen for the Equip and Remove events
replicatedStorage.EquipFollowerEvent.OnServerEvent:Connect(function(player, followerName)
	local playerHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not playerHRP then return end

	-- Get player's unique ID for caching
	local playerID = player.UserId

	-- Initialize cache for this player if needed
	if not followerCache[playerID] then
		followerCache[playerID] = {
			leftFollower = nil,
			rightFollower = nil
		}
	end

	local playerCache = followerCache[playerID]

	-- First, check if this NPC is already equipped in either position
	local isAlreadyEquipped = false
	if playerCache.leftFollower and playerCache.leftFollower.name == followerName then
		print("Character " .. followerName .. " is already equipped on the left.")
		isAlreadyEquipped = true
	end

	if playerCache.rightFollower and playerCache.rightFollower.name == followerName then
		print("Character " .. followerName .. " is already equipped on the right.")
		isAlreadyEquipped = true
	end

	if isAlreadyEquipped then
		return -- Character is already equipped, do nothing
	end

	-- Determine which position to use (right first, then left if right is occupied)
	local position
	if not playerCache.rightFollower then
		position = "right" -- Right position is free, use it
	elseif not playerCache.leftFollower then
		position = "left" -- Right is occupied but left is free
	else
		print("Both follower positions are already occupied.")
		return -- Both positions are occupied, do nothing
	end

	-- Equip to the determined position
	if position == "left" then
		-- Create the left follower
		local follower = createFollower(followerName, -3, playerHRP)  -- Left follower has a sideOffset of -3

		-- Store follower data in the cache
		playerCache.leftFollower = follower

		-- Store follower name as an attribute for persistence
		player:SetAttribute("LeftFollowerName", followerName)

		-- Start monitoring
		coroutine.wrap(function() checkAndTeleportIfNotInVicinity(follower, playerHRP, 15) end)()
		coroutine.wrap(function() detectAndTeleportIfFallen(follower, playerHRP) end)()
		coroutine.wrap(function() startFollowerMovement(follower, playerHRP) end)()

	elseif position == "right" then
		-- Create the right follower
		local follower = createFollower(followerName, 3, playerHRP)  -- Right follower has a sideOffset of 3

		-- Store follower data in the cache
		playerCache.rightFollower = follower

		-- Store follower name as an attribute for persistence
		player:SetAttribute("RightFollowerName", followerName)

		-- Start monitoring
		coroutine.wrap(function() checkAndTeleportIfNotInVicinity(follower, playerHRP, 15) end)()
		coroutine.wrap(function() detectAndTeleportIfFallen(follower, playerHRP) end)()
		coroutine.wrap(function() startFollowerMovement(follower, playerHRP) end)()
	end
end)

replicatedStorage.RemoveFollowerEvent.OnServerEvent:Connect(function(player, followerName)
	local playerID = player.UserId

	-- Check if player has cache
	if not followerCache[playerID] then return end

	local playerCache = followerCache[playerID]
	local leftRemoved = false
	local rightRemoved = false

	-- Remove the specific follower by name
	if playerCache.leftFollower and playerCache.leftFollower.name == followerName then
		if removeFollower(playerCache.leftFollower) then
			playerCache.leftFollower = nil
			player:SetAttribute("LeftFollowerName", nil)
			leftRemoved = true
			print("Removed " .. followerName .. " from left position")
		end
	end

	if playerCache.rightFollower and playerCache.rightFollower.name == followerName then
		if removeFollower(playerCache.rightFollower) then
			playerCache.rightFollower = nil
			player:SetAttribute("RightFollowerName", nil)
			rightRemoved = true
			print("Removed " .. followerName .. " from right position")
		end
	end

	if not leftRemoved and not rightRemoved then
		print("Could not find " .. followerName .. " to remove")
	end
end)


game.Players.PlayerAdded:Connect(function(player)
	-- Initialize player in cache
	followerCache[player.UserId] = {
		leftFollower = nil,
		rightFollower = nil
	}

	-- Function to clean up followers when player dies
	local function cleanupFollowers()
		local playerID = player.UserId

		if followerCache[playerID] then
			-- Remove left follower if exists
			if followerCache[playerID].leftFollower then
				removeFollower(followerCache[playerID].leftFollower)
				followerCache[playerID].leftFollower = nil
			end

			-- Remove right follower if exists
			if followerCache[playerID].rightFollower then
				removeFollower(followerCache[playerID].rightFollower)
				followerCache[playerID].rightFollower = nil
			end
		end
	end

	-- Handle character dying
	local function characterDied(character)
		print("Player died, cleaning up followers")
		cleanupFollowers()

		-- Reset follower attributes if you want to completely reset followers
		-- Comment these out if you want followers to persist after death
		player:SetAttribute("LeftFollowerName", nil)
		player:SetAttribute("RightFollowerName", nil)
	end

	player.CharacterAdded:Connect(function(character)
		local playerHRP = character:WaitForChild("HumanoidRootPart")

		-- Set up death detection
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			characterDied(character)
		end)

		-- Check if the player has equipped followers based on attributes
		local leftFollowerName = player:GetAttribute("LeftFollowerName")
		local rightFollowerName = player:GetAttribute("RightFollowerName")

		-- Recreate followers if needed
		if leftFollowerName then
			local leftFollower = createFollower(leftFollowerName, -3, playerHRP)
			followerCache[player.UserId].leftFollower = leftFollower

			-- Start monitoring
			coroutine.wrap(function() checkAndTeleportIfNotInVicinity(leftFollower, playerHRP, 15) end)()
			coroutine.wrap(function() detectAndTeleportIfFallen(leftFollower, playerHRP) end)()
			coroutine.wrap(function() startFollowerMovement(leftFollower, playerHRP) end)()
		end

		if rightFollowerName then
			local rightFollower = createFollower(rightFollowerName, 3, playerHRP)
			followerCache[player.UserId].rightFollower = rightFollower

			-- Start monitoring
			coroutine.wrap(function() checkAndTeleportIfNotInVicinity(rightFollower, playerHRP, 15) end)()
			coroutine.wrap(function() detectAndTeleportIfFallen(rightFollower, playerHRP) end)()
			coroutine.wrap(function() startFollowerMovement(rightFollower, playerHRP) end)()
		end
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	local playerID = player.UserId

	-- Clean up followers when player leaves
	if followerCache[playerID] then
		if followerCache[playerID].leftFollower then
			removeFollower(followerCache[playerID].leftFollower)
		end

		if followerCache[playerID].rightFollower then
			removeFollower(followerCache[playerID].rightFollower)
		end

		-- Remove player from cache
		followerCache[playerID] = nil
	end
end)
