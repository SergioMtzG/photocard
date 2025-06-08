local replicatedStorage = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local Gui = script.Parent
local background = Gui.Background
local button = Gui.StorageButton
local container = background.ContainerBackground.SecondContainerBackground.Container
local infoFrame = background.InfoFrame
local infoList = infoFrame.ListFrame
local choseViewport = infoFrame.ModelBackground.ModelViewport
local useButton = infoList.UseButton
local duration = infoList.DurationLabel
local template = script.Template
local SharedGameState = require(replicatedStorage:WaitForChild("SharedGameState"))
local StickModels = replicatedStorage:WaitForChild("StickModels")
local StickName = infoFrame.ModelName
local durationText = duration.Label -- "SKZ Stick"
local modelText = StickName.NameLAbel -- "1:30 m"
local powerText = infoList.PowerLabel.Label -- "LUCK BOOST"

local LuckEffectSystem = require(replicatedStorage:WaitForChild("LuckEffectSystem"))


local selectedStick = nil

local isVisible = false

local inventory = {}
local GetStorageFunction = replicatedStorage:WaitForChild("GetStorageFunction")
local SubtractStickEvent = replicatedStorage:WaitForChild("SubtractStickEvent")

local characterInfo = {
	SKZStick = { power = "Luck Boost", duration = "1:30 m" },
	NJZStick = { power = "Luck Boost", duration = "1:30 m" },
}

local function clearViewport(viewport)
	for _, child in ipairs(viewport:GetChildren()) do
		if child:IsA("Model") or child:IsA("Camera") then
			child:Destroy()
		end
	end
end

local function loadStickInViewport(viewport, modelName, power, duration)
	clearViewport(viewport)

	local camera = Instance.new("Camera")
	camera.Name = "ViewportCamera"
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	viewport.BackgroundColor3 = Color3.fromRGB(150, 184, 217)

	local model = StickModels:FindFirstChild(modelName)

	if not model then
		warn("Model not found for:", modelName)
		return
	end

	local clone = model:Clone()
	clone.Parent = viewport

	if not clone.PrimaryPart then
		warn("No PrimaryPart for model:", modelName)
		return
	end

	-- Set consistent camera position relative to the model
	local cameraDistance = 3.25     -- How far in front of the model the camera sits
	local tiltOffsetY = -1       -- Tilt camera up/down (positive = up)
	local tiltOffsetX = 0        -- Tilt camera left/right (positive = right)

	-- Orient the model to face the camera
	if modelName == "SKZStick" then
		-- Adjust for SKZ stick to face forward
		clone:SetPrimaryPartCFrame(CFrame.new(clone.PrimaryPart.Position) * CFrame.Angles(math.rad(-90), math.rad(180), 0))
	elseif modelName == "NJZStick" then
		-- Adjust for NJZ stick to face forward
		clone:SetPrimaryPartCFrame(CFrame.new(clone.PrimaryPart.Position) * CFrame.Angles(0, math.rad(90), 0))
	else
		-- Default orientation for any other sticks
		clone:SetPrimaryPartCFrame(CFrame.new(clone.PrimaryPart.Position) * CFrame.Angles(0, math.rad(180), 0))
	end

	-- === Core Camera Setup ===
	local cameraPos = clone.PrimaryPart.Position + Vector3.new(0, 0, cameraDistance)
	local lookAt = clone.PrimaryPart.Position + Vector3.new(tiltOffsetX, tiltOffsetY, 0)

	camera.CFrame = CFrame.new(cameraPos, lookAt)
end

-- Function to update button count display
local function updateButtonCount(buttonInstance, count)
	local countLabel = buttonInstance:FindFirstChild("Count", true)
	if countLabel and countLabel:FindFirstChild("CountLabel") then
		countLabel.CountLabel.Text = "x" .. count
	end
end

-- Function to refresh the inventory container display
local function refreshInventoryDisplay()
	-- Fetch from server
	local success, result = pcall(function()
		return GetStorageFunction:InvokeServer()
	end)

	if not success then
		warn("Failed to get inventory from server:", result)
		return
	end

	inventory = result

	-- Clear previous buttons
	for _, v in pairs(container:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	-- Create buttons
	for modelName, count in pairs(inventory) do
		if count > 0 then
			local newButton = template:Clone()
			newButton.Name = modelName
			newButton.Text = modelName .. " x" .. count
			newButton.Parent = container
			newButton.Visible = true

			local countLabel = newButton:FindFirstChild("Count", true)
			if countLabel and countLabel:FindFirstChild("CountLabel") then
				countLabel.CountLabel.Text = "x" .. count
			else
				warn("Missing Count/CountLabel in template for:", modelName)
			end

			local viewport = newButton:FindFirstChild("ViewportFrame")
			if viewport then
				local info = characterInfo[modelName]
				if info then
					loadStickInViewport(viewport, modelName, info.power, info.duration)
				else
					warn("Missing character info for:", modelName)
				end
			end

			newButton.MouseButton1Click:Connect(function()
				local info = characterInfo[modelName]
				if info then
					selectedStick = { name = modelName, power = info.power, duration = info.duration }
					print("Selected stick: " .. modelName)
					durationText.Text = info.duration
					modelText.Text = modelName
					powerText.Text = info.power
					infoFrame.Visible = true
					loadStickInViewport(choseViewport, modelName, info.power, info.duration)
				else
					warn("Missing character info for:", modelName)
				end
			end)
		end
	end
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
end

Initialize()

button.MouseButton1Click:Connect(function()
	if SharedGameState:IsRolling() or SharedGameState:IsInventoryOpen() then
		print("Cannot open storage while rolling/!")
		return
	end

	isVisible = not isVisible
	background.Visible = isVisible
	
	SharedGameState:SetStorageOpen(isVisible)

	if isVisible then
		refreshInventoryDisplay()
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

useButton.MouseButton1Click:Connect(function()
	if selectedStick then
		local stickName = selectedStick.name
		print("Use clicked for: " .. stickName)

		-- Tell the server to subtract one
		SubtractStickEvent:FireServer(stickName)
		LuckEffectSystem.activateLuckEffect(120)

		-- Delay briefly then refresh UI to reflect updated inventory
		task.wait(0.1)
		refreshInventoryDisplay()

		-- Hide info if item is gone
		if not inventory[stickName] or inventory[stickName] <= 0 then
			infoFrame.Visible = false
			selectedStick = nil
		end
	else
		print("No stick selected to use.")
	end
end)
