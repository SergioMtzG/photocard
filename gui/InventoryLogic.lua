local selectedCharacter = nil
local replicatedStorage = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local Gui = script.Parent
local background = Gui.Background
local button = Gui.InventoryButton
local container = background.ContainerBackground.SecondContainerBackground.Container
local infoFrame = background.InfoFrame
local infoList = infoFrame.ListFrame
local choseViewport = infoFrame.NPCBackground.NPCViewport
local equipButton = infoList.EquipButton
local equipButtonLabel = equipButton:FindFirstChild("Label") -- Get the TextLabel inside the button
local removeButton = infoList.RemoveButton
local rarity = infoList.RarityLabel
local template = script.Template
local SharedGameState = require(replicatedStorage:WaitForChild("SharedGameState"))
local NPCModels = replicatedStorage:WaitForChild("NPCModels")
local isVisible = false
local NPCName = infoFrame.NPCBackground.Name
local rarityName = rarity.RarityLAbel
local modelName = infoFrame.NPCName.NameLAbel
local groupName = infoList.GroupLabel.Label
local totalEquipped = background.TotalEquippedLabel

local equippedText = template.Equipped

local equipFollowerEvent = replicatedStorage:WaitForChild("EquipFollowerEvent")
local removeFollowerEvent = replicatedStorage:WaitForChild("RemoveFollowerEvent")

local getInventoryFunction = replicatedStorage:WaitForChild("Remotes"):WaitForChild("GetInventory")
-- Use FindFirstChild instead of WaitForChild to avoid infinite yield
local getEquippedFunction = replicatedStorage:WaitForChild("Remotes"):FindFirstChild("GetEquipped")

-- Keep track of equipped characters locally
local equippedCharacters = {}

local characterOrder = {
	-- Mythics
	"Mint Yoons",
	"Orange JM",
	
	"Glasses Jiniret",
	"Ginger Ayen",
	
	"Pink Junie",
	"Beanie Hyunie",
	
	"Candy Wonnie",
	"Dress Sakkee",
	"Laker Jen",
	
	"Cat Kitrin",
	"Bob Pham",
	
	"PJ Bunni",
	"Suit Jiha",

	-- Legendaries
	"Swan JM",
	"Swan Yoons",
	"Swan JK",
	
	"Boom Ayen",
	"Boom Lixx",
	"Boom Channie",
	
	"Hour Tiger",
	"Hour Hyuka",
	"Hour Sloth",
	
	"Cray Munche",
	"Glasses Jen",
	"Dance Wonnie",
	
	"Heart Pham",
	"Red Kitrin",
	
	"Science Dubu",
	"Pirate Swina",
	"Skirt Mimi",
	

	-- Epics
	"Swan NMJ",
	"Swan Vae",
	"Swan Hobbi",
	"Swan WWH",
	
	"Boom Lino",
	"Boom Hannie",
	"Boom Dwaekki",
	"Boom Minmin",
	
	"Rules Tiger",
	"Rules Sloth",
	"Rules Hyuka",
	
	"Dance Munche",
	"Dance Zuaa",
	"Dance Jen",
	"Beanie Sakkee",
	
	"Icon Dany",
	"Icon Mingee",
	"Icon Hyehye",
	
	"Beret Yeoni",
	"Pink Chaeng",
	"Suit Shyshy",
	"Violet Chewee",

	-- Rare
	"JK",
	"NMJ",
	"Hobbi",
	
	"Jiniret",
	"Lixx",
	"Lino",
	"Hannie",
	
	"Rules Junies",
	"Rules Hyunie",
	"Hyunie",
	
	
	"Dance Sakkee",
	"Smart Sakkee",
	"Smart Munche",
	"Smart Wonnie",
	
	"Jersey Dany",
	"Jersey Mingee",
	"Jersey Hyehye",
	
	"Jiha",
	"Bunni",
	"Chaeng",
	"Mimi",

	-- Commons
	"JM",
	"Vae",
	"Yoons",
	"WWH",
	
	"Channie",
	"Ayen",
	"Minmin",
	"Dwaekki",
	
	"Tiger",
	"Sloth",
	"Hyuka",
	"Junie",
	
	"Wonnie",
	"Jen",
	"Zuaa",
	"Sakkee",
	"Munche",
	
	"Hyehye",
	"Pham",
	"Mingee",
	"Kitrin",
	"Dany",
	
	"Shyshy",
	"Chewee",
	"Yeoni",
	"Swina",
	"Dubu"
}

local characterInfo = {
	["Mint Yoons"] = {group = "DYNAMITE", rarity = "Mythic"}, 
	["Orange JM"] = {group = "DYNAMITE", rarity = "Mythic"}, 

	["Swan JM"] = {group = "DYNAMITE", rarity = "Legendary"}, 
	["Swan Yoons"] = {group = "DYNAMITE", rarity = "Legendary"},
	["Swan JK"] = {group = "DYNAMITE", rarity = "Legendary"},

	["Swan NMJ"] = {group = "DYNAMITE", rarity = "Epic"},
	["Swan Vae"] = {group = "DYNAMITE", rarity = "Epic"},
	["Swan Hobbi"] = {group = "DYNAMITE", rarity = "Epic"},
	["Swan WWH"] = {group = "DYNAMITE", rarity = "Epic"},

	["JK"] = {group = "DYNAMITE", rarity = "Rare"},
	["NMJ"] = {group = "DYNAMITE", rarity = "Rare"},
	["Hobbi"] = {group = "DYNAMITE", rarity = "Rare"},

	["JM"] = {group = "DYNAMITE", rarity = "Common"},
	["Vae"] = {group = "DYNAMITE", rarity = "Common"},
	["Yoons"] = {group = "DYNAMITE", rarity = "Common"},
	["WWH"] = {group = "DYNAMITE", rarity = "Common"},
	
	["Glasses Jiniret"] = {group = "LOSTBOYS", rarity = "Mythic"}, 
	["Ginger Ayen"] = {group = "LOSTBOYS", rarity = "Mythic"}, 

	["Boom Ayen"] = {group = "LOSTBOYS", rarity = "Legendary"}, 
	["Boom Lixx"] = {group = "LOSTBOYS", rarity = "Legendary"}, 
	["Boom Channie"] = {group = "LOSTBOYS", rarity = "Legendary"}, 

	["Boom Lino"] = {group = "LOSTBOYS", rarity = "Epic"}, 
	["Boom Hannie"] = {group = "LOSTBOYS", rarity = "Epic"}, 
	["Boom Dwaekki"] = {group = "LOSTBOYS", rarity = "Epic"}, 
	["Boom Minmin"] = {group = "LOSTBOYS", rarity = "Epic"}, 

	["Jiniret"] = {group = "LOSTBOYS", rarity = "Rare"}, 
	["Lixx"] = {group = "LOSTBOYS", rarity = "Rare"}, 
	["Lino"] = {group = "LOSTBOYS", rarity = "Rare"}, 
	["Hannie"] = {group = "LOSTBOYS", rarity = "Rare"}, 

	["Channie"] = {group = "LOSTBOYS", rarity = "Common"}, 
	["Ayen"] = {group = "LOSTBOYS", rarity = "Common"}, 
	["Minmin"] = {group = "LOSTBOYS", rarity = "Common"}, 
	["Dwaekki"] = {group = "LOSTBOYS", rarity = "Common"}, 
	
	
	["Pink Junie"] = {group = "TMRWLINGS", rarity = "Mythic"}, 
	["Beanie Hyunie"] = {group = "TMRWLINGS", rarity = "Mythic"}, 

	["Hour Tiger"] = {group = "TMRWLINGS", rarity = "Legendary"}, 
	["Hour Hyuka"] = {group = "TMRWLINGS", rarity = "Legendary"}, 
	["Hour Sloth"] = {group = "TMRWLINGS", rarity = "Legendary"}, 

	["Rules Tiger"] = {group = "TMRWLINGS", rarity = "Epic"}, 
	["Rules Sloth"] = {group = "TMRWLINGS", rarity = "Epic"}, 
	["Rules Hyuka"] = {group = "TMRWLINGS", rarity = "Epic"}, 

	["Rules Junies"] = {group = "TMRWLINGS", rarity = "Rare"}, 
	["Rules Hyunie"] = {group = "TMRWLINGS", rarity = "Rare"}, 
	["Hyunie"] = {group = "TMRWLINGS", rarity = "Rare"}, 

	["Tiger"] = {group = "TMRWLINGS", rarity = "Common"}, 
	["Sloth"] = {group = "TMRWLINGS", rarity = "Common"}, 
	["Hyuka"] = {group = "TMRWLINGS", rarity = "Common"}, 
	["Junie"] = {group = "TMRWLINGS", rarity = "Common"}, 
	
	
	-- FEARLINGS Mythics
	["Candy Wonnie"] = {group = "FEARLINGS", rarity = "Mythic"},
	["Dress Sakkee"] = {group = "FEARLINGS", rarity = "Mythic"},
	["Laker Jen"] = {group = "FEARLINGS", rarity = "Mythic"},

	-- FEARLINGS Legendaries
	["Cray Munche"] = {group = "FEARLINGS", rarity = "Legendary"},
	["Glasses Jen"] = {group = "FEARLINGS", rarity = "Legendary"},
	["Dance Wonnie"] = {group = "FEARLINGS", rarity = "Legendary"},

	-- FEARLINGS Epics
	["Dance Munche"] = {group = "FEARLINGS", rarity = "Epic"},
	["Dance Zuaa"] = {group = "FEARLINGS", rarity = "Epic"},
	["Dance Jen"] = {group = "FEARLINGS", rarity = "Epic"},
	["Beanie Sakkee"] = {group = "FEARLINGS", rarity = "Epic"},
	

	-- FEARLINGS Rares
	["Dance Sakkee"] = {group = "FEARLINGS", rarity = "Rare"},
	["Smart Sakkee"] = {group = "FEARLINGS", rarity = "Rare"},
	["Smart Munche"] = {group = "FEARLINGS", rarity = "Rare"},
	["Smart Wonnie"] = {group = "FEARLINGS", rarity = "Rare"},
	

	-- FEARLINGS Commons
	["Wonnie"] = {group = "FEARLINGS", rarity = "Common"},
	["Jen"] = {group = "FEARLINGS", rarity = "Common"},
	["Zuaa"] = {group = "FEARLINGS", rarity = "Common"},
	["Munche"] = {group = "FEARLINGS", rarity = "Common"},
	["Sakkee"] = {group = "FEARLINGS", rarity = "Common"},
	
	-- BUNNIEZ
	["Bob Pham"] = {group = "BUNNIEZ", rarity = "Mythic"},
	["Cat Kitrin"] = {group = "BUNNIEZ", rarity = "Mythic"},
	
	["Heart Pham"] = {group = "BUNNIEZ", rarity = "Legendary"},
	["Red Kitrin"] = {group = "BUNNIEZ", rarity = "Legendary"},
	
	["Icon Dany"] = {group = "BUNNIEZ", rarity = "Epic"},
	["Icon Mingee"] = {group = "BUNNIEZ", rarity = "Epic"},
	["Icon Hyehye"] = {group = "BUNNIEZ", rarity = "Epic"},
	
	["Jersey Dany"] = {group = "BUNNIEZ", rarity = "Rare"},
	["Jersey Mingee"] = {group = "BUNNIEZ", rarity = "Rare"},
	["Jersey Hyehye"] = {group = "BUNNIEZ", rarity = "Rare"},
	
	
	["Kitrin"] = {group = "BUNNIEZ", rarity = "Common"},
	["Pham"] = {group = "BUNNIEZ", rarity = "Common"},
	["Dany"] = {group = "BUNNIEZ", rarity = "Common"},
	["Mingee"] = {group = "BUNNIEZ", rarity = "Common"},
	["Hyehye"] = {group = "BUNNIEZ", rarity = "Common"},

	-- TWOEYES
	
	["PJ Bunni"] = {group = "TWOEYES", rarity = "Mythic"},
	["Suit Jiha"] = {group = "TWOEYES", rarity = "Mythic"},

	["Science Dubu"] = {group = "TWOEYES", rarity = "Legendary"},
	["Pirate Swina"] = {group = "TWOEYES", rarity = "Legendary"},
	["Skirt Mimi"] = {group = "TWOEYES", rarity = "Legendary"},

	["Beret Yeoni"] = {group = "TWOEYES", rarity = "Epic"},
	["Pink Chaeng"] = {group = "TWOEYES", rarity = "Epic"},
	["Suit Shyshy"] = {group = "TWOEYES", rarity = "Epic"},
	["Violet Chewee"] = {group = "TWOEYES", rarity = "Epic"},


	["Jiha"] = {group = "TWOEYES", rarity = "Rare"},   -- Jihyo
	["Bunni"] = {group = "TWOEYES", rarity = "Rare"}, -- Nayeon
	["Chaeng"] = {group = "TWOEYES", rarity = "Rare"},   -- Chaeyoung
	["Mimi"] = {group = "TWOEYES", rarity = "Rare"},    -- Momo


	["Shyshy"] = {group = "TWOEYES", rarity = "Common"},   -- Sana
	["Chewee"] = {group = "TWOEYES", rarity = "Common"},  -- Tzuyu
	["Yeoni"] = {group = "TWOEYES", rarity = "Common"},   -- Jeongyeon
	["Dubu"] = {group = "TWOEYES", rarity = "Common"},  -- Dahyun
	["Swina"] = {group = "TWOEYES", rarity = "Common"}  -- Mina
}

local RARITY_COLORS = {
	Common = Color3.fromRGB(163, 162, 165),
	Legendary = Color3.fromRGB(255, 170, 0), 
	Rare = Color3.fromRGB(0, 162, 255),
	Epic = Color3.fromRGB(170, 0, 255),
	Mythic = Color3.fromRGB(255, 85, 255),
}

-- Function to check if a character is equipped
local function isCharacterEquipped(charName)
	for _, equipped in pairs(equippedCharacters) do
		if equipped == charName then
			return true
		end
	end
	return false
end

-- Function to update the equip button text based on selection
local function updateEquipButtonText()
	if selectedCharacter and isCharacterEquipped(selectedCharacter.name) then
		equipButtonLabel.Text = "Equipped"
	else
		equipButtonLabel.Text = "Equip"
	end
end

-- Function to update equipped indicators for all character buttons
local function updateEquippedIndicators()
	for _, buttonObj in pairs(container:GetChildren()) do
		if buttonObj:IsA("TextButton") then
			local charName = buttonObj.Name
			local equippedObj = buttonObj:FindFirstChild("Equipped")

			if equippedObj then
				equippedObj.Visible = isCharacterEquipped(charName)
			end
		end
	end
	local equippedCount = #equippedCharacters
	totalEquipped.Text = "Equipped: " .. equippedCount .. "/2"
end

local function clearViewport(viewport)
	for _, child in ipairs(viewport:GetChildren()) do
		if child:IsA("Model") or child:IsA("Camera") then
			child:Destroy()
		end
	end
end

local function loadNPCInViewport(viewport, modelName, groupName, npcRarity)
	clearViewport(viewport)

	local camera = Instance.new("Camera")
	camera.Name = "ViewportCamera"
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	viewport.BackgroundColor3 = RARITY_COLORS[npcRarity] or Color3.fromRGB(0, 0, 0)

	local groupFolder = NPCModels:FindFirstChild(groupName)
	if not groupFolder then
		warn("Group folder not found:", groupName)
		return
	end

	local model = groupFolder:FindFirstChild(modelName)
	if not model then
		warn("Model not found for:", modelName)
		return
	end

	local clone = model:Clone()
	clone.Parent = viewport

	clone.PrimaryPart = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("Head")
	if not clone.PrimaryPart then
		warn("No PrimaryPart for model:", modelName)
		return
	end

	clone:SetPrimaryPartCFrame(CFrame.new(0, 0.5, 0) * CFrame.Angles(0, math.rad(180), 0))
	camera.CFrame = CFrame.new(clone.PrimaryPart.Position + Vector3.new(0, 1.5, 2.9), clone.PrimaryPart.Position + Vector3.new(0, 1.5, 0))
end

local function Initialize()
	button.Visible = true
	background.Visible = false
	infoFrame.Visible = false

	for _, v in pairs(container:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	-- Initialize equipped characters if the function exists
	if getEquippedFunction then
		equippedCharacters = getEquippedFunction:InvokeServer() or {}
	else
		-- Otherwise, just use an empty table
		equippedCharacters = {}
	end
end

Initialize()

button.MouseButton1Click:Connect(function()
	if SharedGameState:IsRolling() or SharedGameState:IsStorageOpen() then
		print("Cannot open inventory while rolling!")
		return
	end

	isVisible = not isVisible
	background.Visible = isVisible

	-- Update the shared game state to track inventory open status
	SharedGameState:SetInventoryOpen(isVisible)

	if isVisible then
		-- Clear previous buttons
		for _, v in pairs(container:GetChildren()) do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end

		local inventoryData = getInventoryFunction:InvokeServer()

		-- Refresh equipped characters data if the function exists
		if getEquippedFunction then
			equippedCharacters = getEquippedFunction:InvokeServer() or {}
		end

		-- Loop through the desired order
		for _, charName in ipairs(characterOrder) do
			if inventoryData[charName] then  -- Check if the player has this character
				local newButton = template:Clone()
				newButton.Name = charName
				newButton.Text = charName .. " x" .. inventoryData[charName]
				newButton.Parent = container
				newButton.Visible = true

				local countLabel = newButton:FindFirstChild("Count", true)  -- true = search descendants
				if countLabel and countLabel:FindFirstChild("CountLabel") then
					countLabel.CountLabel.Text = "x" .. inventoryData[charName]
				else
					warn("Missing Count/CountLabel in template for:", charName)
				end

				local viewport = newButton:FindFirstChild("ViewportFrame")
				if viewport then
					local info = characterInfo[charName]
					if info then
						loadNPCInViewport(viewport, charName, info.group, info.rarity)
					else
						warn("Missing character info for:", charName)
					end
				end

				-- Setup the equipped indicator
				local equippedIndicator = newButton:FindFirstChild("Equipped")
				if equippedIndicator then
					equippedIndicator.Visible = isCharacterEquipped(charName)
				end

				newButton.MouseButton1Click:Connect(function()
					local info = characterInfo[charName]
					if info then
						selectedCharacter = { name = charName, rarity = info.rarity, group = info.group }
						print("Selected character: " .. charName)
						rarity.Text = info.rarity
						rarityName.Text = info.rarity
						modelName.Text = charName
						groupName.Text = info.group
						infoFrame.Visible = true
						loadNPCInViewport(choseViewport, charName, info.group, info.rarity)

						-- Update equip button text based on equipped status
						updateEquipButtonText()
					else
						warn("Missing character info for:", charName)
					end
				end)
			end
		end
	else
		-- Clear and hide the background when closing
		for _, v in pairs(container:GetChildren()) do
			if v:IsA("TextButton") then
				v:Destroy()
			end
		end
		infoFrame.Visible = false
	end
end)

background.Visible = false
infoFrame.Visible = false

equipButton.MouseButton1Click:Connect(function()
	if selectedCharacter then
		local charName = selectedCharacter.name
		print("Equip clicked for: " .. charName)

		if isCharacterEquipped(charName) then
			print("Character is already equipped")
			return
		end

		-- Check if we can equip more characters (max 2)
		if #equippedCharacters >= 2 then
			print("Cannot equip more than 2 characters")
			return
		end

		-- Fire server event to equip character
		equipFollowerEvent:FireServer(charName)

		-- Update local tracking (temporary until next refresh)
		table.insert(equippedCharacters, charName)

		-- Update button text
		equipButtonLabel.Text = "Equipped"

		-- Update equipped indicators
		updateEquippedIndicators()
	else
		print("No character selected to equip.")
	end
end)

removeButton.MouseButton1Click:Connect(function()
	if selectedCharacter then
		local charName = selectedCharacter.name
		print("Remove clicked for: " .. charName)

		if not isCharacterEquipped(charName) then
			print("Character is not equipped")
			return
		end

		-- Fire server event to remove character
		removeFollowerEvent:FireServer(charName)

		-- Update local tracking (temporary until next refresh)
		for i, name in ipairs(equippedCharacters) do
			if name == charName then
				table.remove(equippedCharacters, i)
				break
			end
		end

		-- Update button text
		equipButtonLabel.Text = "Equip"

		-- Update equipped indicators
		updateEquippedIndicators()
	else
		print("No character selected to remove.")
	end
end)

-- Connect to events to update equipped status when other scripts change it
-- These events would need to be fired by the server when equipment status changes
local equipmentChangedEvent = replicatedStorage:FindFirstChild("EquipmentChangedEvent")
if equipmentChangedEvent then
	equipmentChangedEvent.OnClientEvent:Connect(function(newEquippedList)
		equippedCharacters = newEquippedList
		updateEquippedIndicators()

		-- Also update the equip button if a character is currently selected
		updateEquipButtonText()
	end)
end
