local ServerStorage = game:GetService("ServerStorage")
local spawner = script.Parent
local lightstick = ServerStorage:FindFirstChild("NJZStick")
local WAIT_TIME = 200

function spawnLightstick()
	local newStick = lightstick:Clone()

	-- Position the model using SetPrimaryPartCFrame if it has a primary part
	if newStick.PrimaryPart then
		-- Create a CFrame that preserves the original orientation (35, -90, 180)
		local originalOrientation = CFrame.fromEulerAnglesXYZ(math.rad(35), 0, 0)
		local newPosition = spawner.Position + Vector3.new(0, 2.5, 0)
		newStick:SetPrimaryPartCFrame(CFrame.new(newPosition) * originalOrientation)
	else
		-- If no primary part is set, try to find one to set
		local potentialPrimaryPart = newStick:FindFirstChildWhichIsA("BasePart")
		if potentialPrimaryPart then
			newStick.PrimaryPart = potentialPrimaryPart
			local originalOrientation = CFrame.fromEulerAnglesXYZ(math.rad(35), 0, 0)
			local newPosition = spawner.Position + Vector3.new(0, 2.5, 0)
			newStick:SetPrimaryPartCFrame(CFrame.new(newPosition) * originalOrientation)
		else
			warn("Model has no parts that can be used as PrimaryPart")
		end
	end

	newStick.Parent = spawner
end

function Init()
	spawnLightstick()
end

Init()

-- Fixed event connection syntax
spawner.ChildRemoved:Connect(function(child)
	if child.Name == lightstick.Name then
		task.wait(WAIT_TIME)
		spawnLightstick()
	end
end)
