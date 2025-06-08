local SharedGameState = {}
-- Create a table to store state
SharedGameState.State = {
	IsRolling = false,
	IsInventoryOpen = false,
	IsStorageOpen = false
}
-- Create a BindableEvent to notify when state changes
SharedGameState.StateChanged = Instance.new("BindableEvent")

-- Function to update rolling state
function SharedGameState:SetRollingState(isRolling)
	self.State.IsRolling = isRolling
	self.StateChanged:Fire("IsRolling", isRolling)
end

-- Function to update inventory open state
function SharedGameState:SetInventoryOpen(isOpen)
	self.State.IsInventoryOpen = isOpen
	self.StateChanged:Fire("IsInventoryOpen", isOpen)
end

function SharedGameState:SetStorageOpen(isOpen)
	self.State.IsStorageOpen = isOpen
	self.StateChanged:Fire("IsStorageOpen", isOpen)
end

-- Function to check rolling state
function SharedGameState:IsRolling()
	return self.State.IsRolling
end

-- Function to check inventory open state
function SharedGameState:IsInventoryOpen()
	return self.State.IsInventoryOpen
end

-- Function to check if rolling is allowed
function SharedGameState:CanRoll()
	return not self.State.IsInventoryOpen and not self.State.IsRolling and not self.State.IsStorageOpen
end

function SharedGameState:IsStorageOpen()
	return self.State.IsStorageOpen
end

return SharedGameState
