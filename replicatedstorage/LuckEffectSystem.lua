local module = {}
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local luckEffectActive = false
local luckTimeRemaining = 0
local luckEffectFrame = nil
local luckTimeLabel = nil

-- References to the existing GUI elements
local function getLuckGuiElements()
	-- Wait for the LuckGui to be available in PlayerGui (copied from StarterGui)
	local luckGui = playerGui:WaitForChild("LuckGui", 10)
	if not luckGui then
		warn("LuckGui not found in PlayerGui within 10 seconds")
		return nil, nil
	end

	-- Get the Frame and TextLabel from the existing GUI
	local frame = luckGui:FindFirstChild("Frame")
	if not frame then
		warn("Frame not found in LuckGui")
		return nil, nil
	end

	local textLabel = frame:FindFirstChild("TextLabel")
	if not textLabel then
		warn("TextLabel not found in Frame")
		return nil, nil
	end

	return frame, textLabel
end

-- Create Events
local LuckEffectRemotes = ReplicatedStorage:FindFirstChild("LuckEffectRemotes") or Instance.new("Folder")
LuckEffectRemotes.Name = "LuckEffectRemotes"
LuckEffectRemotes.Parent = ReplicatedStorage

local ActivateLuckEffectEvent = LuckEffectRemotes:FindFirstChild("ActivateLuckEffect") or Instance.new("RemoteEvent")
ActivateLuckEffectEvent.Name = "ActivateLuckEffect"
ActivateLuckEffectEvent.Parent = LuckEffectRemotes

-- Function to format time (converts seconds to MM:SS)
local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%01d:%02d", minutes, secs)
end

-- Function to activate the luck effect
function module.activateLuckEffect(duration)
	duration = 90 -- Default 2 minutes (120 seconds)

	-- Get references to the GUI elements if we don't have them yet
	if not luckEffectFrame or not luckTimeLabel then
		luckEffectFrame, luckTimeLabel = getLuckGuiElements()
		if not luckEffectFrame or not luckTimeLabel then
			warn("Failed to get LuckGui elements")
			return false, 0
		end
	end

	-- If already active, just add to the time
	if luckEffectActive then
		luckTimeRemaining = luckTimeRemaining + duration
	else
		luckEffectActive = true
		luckTimeRemaining = duration
		luckEffectFrame.Visible = true

		-- Start the timer update
		local connection
		connection = RunService.Heartbeat:Connect(function(deltaTime)
			if luckTimeRemaining > 0 then
				luckTimeRemaining = luckTimeRemaining - deltaTime
				luckTimeLabel.Text = "Luck: " .. formatTime(math.ceil(luckTimeRemaining))
			else
				-- Effect ended
				luckEffectActive = false
				luckEffectFrame.Visible = false
				connection:Disconnect()
			end
		end)
	end

	-- Return the current status for other systems to check
	return luckEffectActive, luckTimeRemaining
end

-- Function to check if luck effect is active
function module.isLuckEffectActive()
	return luckEffectActive
end

-- Function to get current luck time remaining
function module.getLuckTimeRemaining()
	return luckTimeRemaining
end

-- Handle RemoteEvent from server
ActivateLuckEffectEvent.OnClientEvent:Connect(function(duration)
	module.activateLuckEffect(duration)
end)

return module
