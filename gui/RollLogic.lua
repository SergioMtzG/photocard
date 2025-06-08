local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCModels = ReplicatedStorage:WaitForChild("NPCModels")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local rollButton = script.Parent:WaitForChild("RollButton")
local viewport = script.Parent:WaitForChild("NPCViewport")
viewport.Visible = false

local fastRollButton = script.Parent:WaitForChild("FastRollButton")
local isFastRoll = false

local autoRollButton = script.Parent:WaitForChild("AutoRollButton")
local shouldAutoRoll = false -- what the button sets
local isRollingLoopActive = false -- ensures one loop runs at a time


local Largeviewport = script.Parent:WaitForChild("LargerNPCViewport")
Largeviewport.Visible = false

local GroupViewport = script.Parent:WaitForChild("GroupViewport")
GroupViewport.Visible = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedGameState = require(ReplicatedStorage:WaitForChild("SharedGameState"))

-- Used to show what roll out of 10 we are
local rollNumLabel = script.Parent:WaitForChild("RollNumLabel")

local LuckEffectSystem = require(ReplicatedStorage:WaitForChild("LuckEffectSystem")) 

local SpinEvent = ReplicatedStorage:WaitForChild("SpinEvent")

local function shouldApplyLuckBonus()
	return LuckEffectSystem.isLuckEffectActive()
end

-- Track roll count for luck boost
local currentRollCount = 0

local luckEffect = false

-- New rarity setup
local NPC_Rarities_ByGroup = {
	FEARLINGS = {
		["Candy Wonnie"] = {weight = 5, rarity = "Mythic"},
		["Dress Sakkee"] = {weight = 5, rarity = "Mythic"},
		["Laker Jen"] = {weight = 5, rarity = "Mythic"},

		-- Legendaries (1% total = 100)
		["Cray Munche"] = {weight = 20, rarity = "Legendary"},
		["Glasses Jen"] = {weight = 20, rarity = "Legendary"},
		["Dance Wonnie"] = {weight = 20, rarity = "Legendary"},

		-- Epics (7.5% total = 750)
		["Dance Munche"] = {weight = 188, rarity = "Epic"},
		["Dance Zuaa"] = {weight = 188, rarity = "Epic"},
		["Dance Jen"] = {weight = 187, rarity = "Epic"},
		["Beanie Sakkee"] = {weight = 187, rarity = "Epic"},

		-- Commons (50% total = 5000)
		["Wonnie"] = {weight = 1000, rarity = "Common"},
		["Jen"] = {weight = 1000, rarity = "Common"},
		["Zuaa"] = {weight = 1000, rarity = "Common"},
		["Sakkee"] = {weight = 1000, rarity = "Common"},
		["Munche"] = {weight = 1000, rarity = "Common"},

		-- Rares (remaining weight = ~4120)
		["Dance Sakkee"] = {weight = 1045, rarity = "Rare"},
		["Smart Sakkee"] = {weight = 1045, rarity = "Rare"},
		["Smart Munche"] = {weight = 1045, rarity = "Rare"},
		["Smart Wonnie"] = {weight = 1040, rarity = "Rare"},
	},
	BUNNIEZ = {
		
		["Bob Pham"] = {weight = 5, rarity = "Mythic"},
		["Cat Kitrin"] = {weight = 5, rarity = "Mythic"},
		
		
		["Heart Pham"] = {weight = 20, rarity = "Legendary"},
		["Red Kitrin"] = {weight = 20, rarity = "Legendary"},
		
		["Icon Dany"] = {weight = 250, rarity = "Epic"},
		["Icon Mingee"] = {weight = 250, rarity = "Epic"},
		["Icon Hyehye"] = {weight = 250, rarity = "Epic"},
		
		
		["Jersey Dany"] = {weight = 1050, rarity = "Rare"},
		["Jersey Mingee"] = {weight = 1050, rarity = "Rare"},
		["Jersey Hyehye"] = {weight = 1063, rarity = "Rare"},
		
		
		["Kitrin"] = {weight = 1207, rarity = "Common"},
		["Pham"] = {weight = 1210, rarity = "Common"},
		["Dany"] = {weight = 1210, rarity = "Common"},
		["Mingee"] = {weight = 1210, rarity = "Common"},
		["Hyehye"] = {weight = 1200, rarity = "Common"},
	},
	TWOEYES = {
		["PJ Bunni"] = {weight = 5, rarity = "Mythic"},
		["Suit Jiha"] = {weight = 5, rarity = "Mythic"},
		
		["Science Dubu"] = {weight = 20, rarity = "Legendary"},
		["Pirate Swina"] = {weight = 20, rarity = "Legendary"},
		["Skirt Mimi"] = {weight = 20, rarity = "Legendary"},
		
		["Beret Yeoni"] = {weight = 188, rarity = "Epic"},
		["Pink Chaeng"] = {weight = 188, rarity = "Epic"},
		["Suit Shyshy"] = {weight = 187, rarity = "Epic"},
		["Violet Chewee"] = {weight = 187, rarity = "Epic"},
		
		
		["Jiha"] = {weight = 795, rarity = "Rare"},   -- Jihyo
		["Bunni"] = {weight = 795, rarity = "Rare"}, -- Nayeon
		["Chaeng"] = {weight = 795, rarity = "Rare"},   -- Chaeyoung
		["Mimi"] = {weight = 795, rarity = "Rare"},    -- Momo
		
		
		["Shyshy"] = {weight = 1200, rarity = "Common"},   -- Sana
		["Chewee"] = {weight = 1200, rarity = "Common"},  -- Tzuyu
		["Yeoni"] = {weight = 1200, rarity = "Common"},   -- Jeongyeon
		["Dubu"] = {weight = 1200, rarity = "Common"},  -- Dahyun
		["Swina"] = {weight = 1200, rarity = "Common"}  -- Mina
		
	},
	
	DYNAMITE = {
	
		["Mint Yoons"] = {weight = 5, rarity = "Mythic"}, 
		["Orange JM"] = {weight = 5, rarity = "Mythic"}, 
		
		["Swan JM"] = {weight = 20, rarity = "Legendary"}, 
		["Swan Yoons"] = {weight = 20, rarity = "Legendary"},
		["Swan JK"] = {weight = 20, rarity = "Legendary"},
		
		["Swan NMJ"] = {weight = 188, rarity = "Epic"},
		["Swan Vae"] = {weight = 188, rarity = "Epic"},
		["Swan Hobbi"] = {weight = 187, rarity = "Epic"},
		["Swan WWH"] = {weight = 187, rarity = "Epic"},
		
		["JK"] = {weight = 1060, rarity = "Rare"},
		["NMJ"] = {weight = 1060, rarity = "Rare"},
		["Hobbi"] = {weight = 1060, rarity = "Rare"},
		
		["JM"] = {weight = 1500, rarity = "Common"},
		["Vae"] = {weight = 1500, rarity = "Common"},
		["Yoons"] = {weight = 1500, rarity = "Common"},
		["WWH"] = {weight = 1500, rarity = "Common"},

	},
	
	LOSTBOYS = {
		["Glasses Jiniret"] = {weight = 5, rarity = "Mythic"}, 
		["Ginger Ayen"] = {weight = 5, rarity = "Mythic"}, 
		
		["Boom Ayen"] = {weight = 20, rarity = "Legendary"}, 
		["Boom Lixx"] = {weight = 20, rarity = "Legendary"}, 
		["Boom Channie"] = {weight = 20, rarity = "Legendary"}, 
		
		["Boom Lino"] = {weight = 188, rarity = "Epic"}, 
		["Boom Hannie"] = {weight = 187, rarity = "Epic"}, 
		["Boom Dwaekki"] = {weight = 188, rarity = "Epic"}, 
		["Boom Minmin"] = {weight = 187, rarity = "Epic"}, 
		
		["Jiniret"] = {weight = 795, rarity = "Rare"}, 
		["Lixx"] = {weight = 795, rarity = "Rare"}, 
		["Lino"] = {weight = 795, rarity = "Rare"}, 
		["Hannie"] = {weight = 795, rarity = "Rare"}, 
		
		["Channie"] = {weight = 1500, rarity = "Common"}, 
		["Ayen"] = {weight = 1500, rarity = "Common"}, 
		["Minmin"] = {weight = 1500, rarity = "Common"}, 
		["Dwaekki"] = {weight = 1500, rarity = "Common"}, 
		
	},
	
	TMRWLINGS = {
		["Pink Junie"] = {weight = 5, rarity = "Mythic"}, 
		["Beanie Hyunie"] = {weight = 5, rarity = "Mythic"}, 
		
		["Hour Tiger"] = {weight = 20, rarity = "Legendary"}, 
		["Hour Hyuka"] = {weight = 20, rarity = "Legendary"}, 
		["Hour Sloth"] = {weight = 20, rarity = "Legendary"}, 
		
		["Rules Tiger"] = {weight = 250, rarity = "Epic"}, 
		["Rules Sloth"] = {weight = 250, rarity = "Epic"}, 
		["Rules Hyuka"] = {weight = 250, rarity = "Epic"}, 
		
		["Rules Junies"] = {weight = 1060, rarity = "Rare"}, 
		["Rules Hyunie"] = {weight = 1060, rarity = "Rare"}, 
		["Hyunie"] = {weight = 1060, rarity = "Rare"}, 
		
		["Tiger"] = {weight = 1500, rarity = "Common"}, 
		["Sloth"] = {weight = 1500, rarity = "Common"}, 
		["Hyuka"] = {weight = 1500, rarity = "Common"}, 
		["Junie"] = {weight = 1500, rarity = "Common"}, 
		
	}
}


local RARITY_COLORS = {
	Mythic = Color3.fromRGB(255, 85, 255),     -- Purple-pink
	Legendary = Color3.fromRGB(255, 170, 0),   -- Orange
	Epic = Color3.fromRGB(128, 0, 255),        -- Violet
	Rare = Color3.fromRGB(0, 170, 255),        -- Blue
	Common = Color3.fromRGB(170, 170, 170)     -- Gray
}

local GROUP_COLORS = {
	FEARLINGS = Color3.fromRGB(30, 30, 30),        -- Dark matte gray
	BUNNIEZ = Color3.fromRGB(160, 210, 245),            -- Light blue
	TWOEYES = Color3.fromRGB(255, 182, 193),          -- Light pink
	DYNAMITE = Color3.fromRGB(193, 141, 255),
	LOSTBOYS = Color3.fromRGB(180, 71, 69),
	TMRWLINGS = Color3.fromRGB(106, 226, 200)
	
}

-- Map group names to folder names
local GROUP_FOLDERS = {
	FEARLINGS = "FEARLINGS",  -- Using proper folder name casing
	BUNNIEZ = "BUNNIEZ",
	TWOEYES = "TWOEYES",  -- Using proper folder name casing
	DYNAMITE = "DYNAMITE",
	LOSTBOYS = "LOSTBOYS",
	TMRWLINGS = "TMRWLINGS"
}

local groupNames = {"FEARLINGS", "BUNNIEZ", "TWOEYES", "LOSTBOYS", "DYNAMITE", "TMRWLINGS"}

local spinAudio = ReplicatedStorage:WaitForChild("Audios"):WaitForChild("Spin")
local flipAudio = ReplicatedStorage:WaitForChild("Audios"):WaitForChild("Flip")
local winAudio = ReplicatedStorage:WaitForChild("Audios"):WaitForChild("Win")
local legendWin = ReplicatedStorage:WaitForChild("Audios"):WaitForChild("LegendWin")

-- Function to update roll counter display
local function updateRollCounterDisplay()
	if currentRollCount % 10 == 0 and currentRollCount > 0 then
		-- It's a luck boost roll (10th, 20th, etc.)
		rollNumLabel.Text = "LUCK BOOST!"
		rollNumLabel.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color for emphasis
	else
		-- Regular roll, show current count out of 10
		local displayCount = currentRollCount 
		rollNumLabel.Text = displayCount .. "/10"
		rollNumLabel.TextColor3 = Color3.fromRGB(254, 190, 255) -- Default white color
	end
end

-- Update the weighting system to account for luck boost
local function getWeightedRandomNPCName(groupName, isLuckBoost)
	local groupTable = NPC_Rarities_ByGroup[groupName]
	local totalWeight = 0

	-- Create a temporary table to hold boosted weights
	local tempWeights = {}
	for name, data in pairs(groupTable) do
		local effectiveWeight = data.weight

		-- If it's a luck boost roll, boost better rarities (reduce their effective weight)
		if isLuckBoost or luckEffect then
			print("LUCKYSPIN")
			if data.rarity == "Common" then
				effectiveWeight = data.weight * 0.4878
			elseif data.rarity == "Rare" then
				effectiveWeight = data.weight * 2.04
			elseif data.rarity == "Epic" then
				effectiveWeight = data.weight * 1.8
			elseif data.rarity == "Legendary" then
				effectiveWeight = data.weight * 2
			elseif data.rarity == "Mythic" then
				effectiveWeight = data.weight * 3
			end
		end


		tempWeights[name] = effectiveWeight
		totalWeight += effectiveWeight
	end

	local rand = math.random(1, totalWeight)
	local counter = 0
	for name, weight in pairs(tempWeights) do
		counter += weight
		if rand <= counter then
			return name
		end
	end
end

-- Get total weight and select one based on odds
local function getRandomNPC(groupName, isLuckBoost)
	local groupTable = NPC_Rarities_ByGroup[groupName]
	if not groupTable then warn("Invalid group:", groupName) return end

	local totalWeight = 0
	-- Create a temporary table to hold boosted weights
	local tempWeights = {}
	for name, data in pairs(groupTable) do
		local effectiveWeight = data.weight
		
		if isLuckBoost or luckEffect then
			print("LUCKYSPIN")
			if data.rarity == "Common" then
				effectiveWeight = data.weight * 0.4878
			elseif data.rarity == "Rare" then
				effectiveWeight = data.weight * 2.04
			elseif data.rarity == "Epic" then
				effectiveWeight = data.weight * 1.8
			elseif data.rarity == "Legendary" then
				effectiveWeight = data.weight * 2
			elseif data.rarity == "Mythic" then
				effectiveWeight = data.weight * 3
			end
		end


		tempWeights[name] = {weight = effectiveWeight, rarity = data.rarity}
		totalWeight += effectiveWeight
	end

	local rand = math.random(1, totalWeight)
	local counter = 0
	for name, data in pairs(tempWeights) do
		counter += data.weight
		if rand <= counter then
			return name, data.rarity
		end
	end
end

-- Set up camera
local function setupCamera()
	local camera = viewport:FindFirstChildOfClass("Camera")
	if camera then camera:Destroy() end

	camera = Instance.new("Camera")
	camera.Name = "ViewportCamera"
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	return camera
end

-- Show model in viewport
local function showModelInViewport(modelName, rarity, groupName)
	-- Remove all relevant elements from the viewport
	for _, child in ipairs(viewport:GetChildren()) do
		if child:IsA("Model") or child:IsA("TextLabel") or child:IsA("Camera") or 
			(child:IsA("Frame") and child.Name == "TextContainer") then
			child:Destroy()
		end
		-- This preserves the UICorner
	end

	local camera = setupCamera()

	if RARITY_COLORS[rarity] then
		viewport.BackgroundColor3 = RARITY_COLORS[rarity]
	else
		viewport.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- fallback
	end

	-- Get the correct folder name for this group
	local folderName = GROUP_FOLDERS[groupName]
	if not folderName then 
		warn("Group folder mapping not found for:", groupName)
		return
	end

	-- Look for the model in the appropriate group subfolder
	local groupFolder = NPCModels:FindFirstChild(folderName)
	if not groupFolder then
		warn("Group folder not found:", folderName)
		return
	end

	local npcTemplate = groupFolder:FindFirstChild(modelName)
	if not npcTemplate then 
		warn("Model not found:", modelName, "in folder", folderName)
		return
	end

	local clone = npcTemplate:Clone()
	clone.Parent = viewport

	if not clone.PrimaryPart then
		clone.PrimaryPart = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("Head")
	end
	if not clone.PrimaryPart then
		warn("No PrimaryPart found for model:", modelName)
		return
	end

	clone:SetPrimaryPartCFrame(CFrame.new(0, 0.5, 0) * CFrame.Angles(0, math.rad(180), 0))
	camera.CFrame = CFrame.new(clone.PrimaryPart.Position + Vector3.new(0, 1.5, 2.9), clone.PrimaryPart.Position + Vector3.new(0, 1.5, 0))

	-- Create a frame to contain our text labels
	local textContainer = Instance.new("Frame")
	textContainer.Name = "TextContainer"
	textContainer.Size = UDim2.fromScale(1, 0.25) -- Take 25% of the viewport's height
	textContainer.Position = UDim2.fromScale(0.5, 0.16) -- Position at the top portion
	textContainer.AnchorPoint = Vector2.new(0.5, 0.5) -- Center the container
	textContainer.BackgroundTransparency = 1
	textContainer.Parent = viewport

	-- Add UIListLayout to arrange the labels vertically
	local listLayout = Instance.new("UIListLayout")
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2) -- Small padding between labels
	listLayout.Parent = textContainer

	-- Text label for the model name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.LayoutOrder = 1
	nameLabel.Size = UDim2.fromScale(1, 0.5) -- 50% of container height
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = modelName
	nameLabel.TextScaled = true -- Enable text scaling
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.Parent = textContainer

	-- Add UITextSizeConstraint to limit minimum/maximum text size
	local nameTextConstraint = Instance.new("UITextSizeConstraint")
	nameTextConstraint.MinTextSize = 16
	nameTextConstraint.MaxTextSize = 40
	nameTextConstraint.Parent = nameLabel

	-- Text label for the rarity
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.LayoutOrder = 2
	rarityLabel.Size = UDim2.fromScale(1, 0.3) -- 30% of container height
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Text = rarity
	rarityLabel.TextScaled = true -- Enable text scaling
	rarityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	rarityLabel.Font = Enum.Font.FredokaOne
	rarityLabel.Parent = textContainer

	local rarityTextConstraint = Instance.new("UITextSizeConstraint")
	rarityTextConstraint.MinTextSize = 14
	rarityTextConstraint.MaxTextSize = 30
	rarityTextConstraint.Parent = rarityLabel
end

-- Animate roll
local function rollAnimation(groupName, finalNPC, rarity, isLuckBoost, spinFast)
	viewport.Visible = true

	local availableModels = {}
	for name, _ in pairs(NPC_Rarities_ByGroup[groupName]) do
		table.insert(availableModels, name)
	end

	local previousModel = nil
	
	local num = 20
	
	if spinFast then
		num = 8
	end
	
	for i = 1, num do
		local randomModel
		repeat
			randomModel = getWeightedRandomNPCName(groupName, isLuckBoost) 
		until randomModel ~= previousModel

		previousModel = randomModel
		local randomRarity = NPC_Rarities_ByGroup[groupName][randomModel].rarity

		-- Clear previous viewport content before showing new model
		-- This ensures the previous text labels and models don't persist
		for _, child in ipairs(viewport:GetChildren()) do
			if child:IsA("Model") or child:IsA("TextLabel") or child:IsA("Camera") or 
				(child:IsA("Frame") and child.Name == "TextContainer") then
				child:Destroy()
			end
		end

		showModelInViewport(randomModel, randomRarity, groupName)
		spinAudio:Play()
		wait(0.04 + (i * 0.01))
	end 

	spinAudio:Play()

	-- Clear viewport again before showing final model
	for _, child in ipairs(viewport:GetChildren()) do
		if child:IsA("Model") or child:IsA("TextLabel") or child:IsA("Camera") or 
			(child:IsA("Frame") and child.Name == "TextContainer") then
			child:Destroy()
		end
	end

	showModelInViewport(finalNPC, rarity, groupName)
	wait(.25)
	if rarity == "Common" or rarity == "Rare" then
		winAudio:Play()
	else 
		legendWin:Play()
	end
	if not spinFast then
		wait(1.75)
	else
		wait(0.75)
	end
	viewport.Visible = false
end

local function spinThroughGroupNames(spinFast)
	GroupViewport.Visible = true

	for _, child in pairs(GroupViewport:GetChildren()) do
		if child:IsA("TextLabel") or child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Create a container for the group name to allow for scaling
	local textContainer = Instance.new("Frame")
	textContainer.Size = UDim2.fromScale(0.8, 0.6) -- 80% width and 60% height of parent
	textContainer.Position = UDim2.fromScale(0.5, 0.5) -- Center of viewport
	textContainer.AnchorPoint = Vector2.new(0.5, 0.5) -- Center the container
	textContainer.BackgroundTransparency = 1
	textContainer.Parent = GroupViewport

	local groupNameLabel = Instance.new("TextLabel")
	groupNameLabel.Size = UDim2.fromScale(1, 1) -- Fill the container
	groupNameLabel.BackgroundTransparency = 1
	groupNameLabel.TextScaled = true -- Enable text scaling
	groupNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	groupNameLabel.Font = Enum.Font.FredokaOne
	groupNameLabel.Parent = textContainer

	local textConstraint = Instance.new("UITextSizeConstraint")
	textConstraint.MinTextSize = 18
	textConstraint.MaxTextSize = 40
	textConstraint.Parent = groupNameLabel

	local chosenGroup
	local previousGroup = nil
	
	local num = 12
	
	if spinFast then
		num = 5
	end
	
	for i = 1, num do
		local randomGroup
		repeat
			randomGroup = groupNames[math.random(1, #groupNames)]
		until randomGroup ~= previousGroup

		previousGroup = randomGroup
		chosenGroup = randomGroup
		groupNameLabel.Text = randomGroup
		GroupViewport.BackgroundColor3 = GROUP_COLORS[randomGroup] or Color3.fromRGB(0, 0, 0)
		spinAudio:Play()
		wait(0.05 + i * 0.01)
	end
	
	if not spinFast then
		wait(0.35)
	else
		wait(0.2)
	end
	flipAudio:Play()
	wait(0.15)
	GroupViewport.Visible = false
	return chosenGroup
end

-- Add rounded corners to viewports
local function addRoundedCorners(frame)
	local existingCorner = frame:FindFirstChildOfClass("UICorner")
	if existingCorner then
		existingCorner:Destroy()
	end

	local uicorner = Instance.new("UICorner")
	uicorner.Parent = frame
	uicorner.CornerRadius = UDim.new(0, 10)  -- Adjust this value for slightly rounded corners
end

-- Apply rounded corners to the viewports
addRoundedCorners(viewport)
addRoundedCorners(GroupViewport)
addRoundedCorners(Largeviewport)

-- Function to ensure all child elements are properly cleaned up when needed
local function cleanViewport(viewportFrame)
	for _, child in ipairs(viewportFrame:GetChildren()) do
		if child:IsA("Model") or child:IsA("TextLabel") or child:IsA("Camera") or 
			(child:IsA("Frame") and child.Name == "TextContainer") then
			child:Destroy()
		end
	end
end

-- Initialize the roll counter display
updateRollCounterDisplay()

-- Button logic
rollButton.MouseButton1Click:Connect(function()
	if SharedGameState:IsInventoryOpen() or SharedGameState:IsStorageOpen() then
		print("Cannot roll while menu is open!")
		return
	end

	if SharedGameState:IsRolling() then
		print("Already rolling!")
		return
	end
	

	-- Set rolling state to true
	SharedGameState:SetRollingState(true)

	-- Increment roll counter
	currentRollCount = currentRollCount + 1
	
	SpinEvent:FireServer()

	-- Determine if this is a luck boost roll (every 10th roll)
	local isLuckBoost = (currentRollCount % 10 == 0) and (currentRollCount ~= 0)

	-- Update the roll counter display
	updateRollCounterDisplay()
	
	luckEffect = shouldApplyLuckBonus()
	
	local spinFast = isFastRoll

	local selectedGroup = spinThroughGroupNames(spinFast)
	if selectedGroup then
		local npcName, rarity = getRandomNPC(selectedGroup, isLuckBoost) -- Pass luck boost status
		if npcName and rarity then
			local rollRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RollCharacter")

			-- Also inform the server if this was a luck boosted roll for server-side validation if needed
			rollRemote:FireServer(npcName, isLuckBoost)

			rollAnimation(selectedGroup, npcName, rarity, isLuckBoost, spinFast)
		end
	end

	-- Set rolling state back to false
	SharedGameState:SetRollingState(false)
	
	if isLuckBoost then
		currentRollCount = 0
		updateRollCounterDisplay()
	end
	
end)

local MarketPlaceService = game:GetService("MarketplaceService")
local gamepassId = 1235877749
local player = game.Players.LocalPlayer

local checkGamepassRemote = ReplicatedStorage:WaitForChild("CheckGamepass")


fastRollButton.MouseButton1Click:Connect(function()
	local hasGamepass = checkGamepassRemote:InvokeServer()-- immediate and reliable

	if hasGamepass then
		if isFastRoll == false then
			isFastRoll = true
			fastRollButton.BackgroundTransparency = 0.2
		else 
			isFastRoll = false
			fastRollButton.BackgroundTransparency = 0.6
		end
	else
		print("You need the Fast Roll gamepass to use this feature!")
		MarketPlaceService:PromptGamePassPurchase(player, gamepassId)
	end
end)



fastRollButton.MouseButton1Click:Connect(function() 
	
	if isFastRoll == false then
		isFastRoll = true
		fastRollButton.BackgroundTransparency = 0.2
	else 
		isFastRoll = false
		fastRollButton.BackgroundTransparency = 0.6
	end
	
end)



autoRollButton.MouseButton1Click:Connect(function()
	shouldAutoRoll = not shouldAutoRoll
	
	if SharedGameState:IsInventoryOpen() or SharedGameState:IsStorageOpen() then
		print("Cannot roll while menu is open!")
		return
	end


	if shouldAutoRoll then
		autoRollButton.BackgroundTransparency = 0.2

		-- Start auto-roll loop only if not already running
		if not isRollingLoopActive then
			startAutoRollLoop()
		end
	else
		autoRollButton.BackgroundTransparency = 0.6
	end
end)


function startAutoRollLoop()
	isRollingLoopActive = true

	while shouldAutoRoll do
		-- Only start if not already rolling or blocked
		if not SharedGameState:IsRolling() and not SharedGameState:IsInventoryOpen() and not SharedGameState:IsStorageOpen() then
			-- ---- Your full roll logic here ----
			SharedGameState:SetRollingState(true)
			currentRollCount = currentRollCount + 1
			SpinEvent:FireServer()


			local isLuckBoost = (currentRollCount % 10 == 0) and (currentRollCount ~= 0)
			updateRollCounterDisplay()
			
			luckEffect = shouldApplyLuckBonus()

			local spinFast = isFastRoll
			local selectedGroup = spinThroughGroupNames(spinFast)

			if selectedGroup then
				local npcName, rarity = getRandomNPC(selectedGroup, isLuckBoost)
				if npcName and rarity then
					local rollRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RollCharacter")
					rollRemote:FireServer(npcName, isLuckBoost)
					rollAnimation(selectedGroup, npcName, rarity, isLuckBoost, spinFast)
				end
			end

			SharedGameState:SetRollingState(false)

			if isLuckBoost then
				currentRollCount = 0
				updateRollCounterDisplay()
			end
			-- ---- End of roll logic ----

			wait(0.1) -- Short pause between rolls
		else
			-- Wait if blocked by inventory or roll in progress
			wait(0.1)
		end
	end

	isRollingLoopActive = false -- Reset loop flag when user turns it off
end
