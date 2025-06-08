local ServerStorage = game:GetService("ServerStorage")
local MusicFolder = ServerStorage:WaitForChild("MusicFolder")

-- Songs and how many times each should play
local playlist = {
	{ sound = MusicFolder:WaitForChild("Song1"), repeatCount = 2 },
	{ sound = MusicFolder:WaitForChild("Song2"), repeatCount = 2 },
	{ sound = MusicFolder:WaitForChild("Song3"), repeatCount = 1 }
}

-- Create the Sound instance in Workspace
local soundPlayer = Instance.new("Sound")
soundPlayer.Name = "MusicPlayer"
soundPlayer.Parent = workspace
soundPlayer.RollOffMode = Enum.RollOffMode.Linear
soundPlayer.EmitterSize = 0
soundPlayer.MaxDistance = 100000
soundPlayer.Volume = .2
soundPlayer.Looped = false

local currentIndex = 1
local currentRepeat = 1

local function playNextSong()
	local songData = playlist[currentIndex]
	local song = songData.sound

	-- Set up the sound
	soundPlayer.SoundId = song.SoundId
	soundPlayer.TimePosition = 0  -- Reset to beginning
	soundPlayer:Play()

	-- Wait for it to end
	soundPlayer.Ended:Wait()

	-- Check if we need to repeat the current song
	if currentRepeat < songData.repeatCount then
		currentRepeat += 1
		-- Stay on the same song, just increment repeat counter
	else
		-- Move to next song
		currentRepeat = 1
		currentIndex += 1
		if currentIndex > #playlist then
			currentIndex = 1  -- loop the playlist
		end
	end

	-- Recursively play the next song (or repeat current)
	playNextSong()
end

playNextSong()
