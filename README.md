# 🎮 [Photocard RNG]

## Click below to watch the demo:

[![Watch the demo](https://img.youtube.com/vi/lUSLr8VZizY/maxresdefault.jpg)](https://www.youtube.com/watch?v=lUSLr8VZizY)



## 📘 Overview
**Photocard RNG** is a free gacha RPG collection game where players roll to collect, equip, and interact with characters inspired by 50 K-pop idols across 6 different K-pop groups. The game is designed for seamless play on **desktops, phones, and tablets**, ensuring a consistent experience across all devices.

This game blends stylish UI, custom 3D models, and smart Lua scripting to deliver an immersive Roblox experience. All core systems — including the roll UI, roll animations, inventory, data storage, and character equipping — are fully scripted in Lua. Characters and environments are designed directly in Roblox Studio for seamless integration.

---

## 🕹️ Gameplay Summary
- 🎲 Roll for characters with rarity-based odds
- 🎒 View and manage your personal character inventory
- 🧍 Equip up to two characters to follow you around the map
- 🗺️ Explore a themed world tied to your character's origin
- ⚡️ Discover K-pop-themed lightsticks hidden across the map
- 🍀 Store and use lightsticks to boost your luck during rolls

---

## 🧪 Roll GUI & System 
![image](https://github.com/user-attachments/assets/07c4ae0c-cfb4-4cc3-8ad9-6791c23c4381)
### Overview:
- Roll, auto roll, fast roll interfaces
- ViewportFrames used to show 3D character previews
- Probability weights and luck effects

### Animation Script:
```lua
-- Animate roll
local function rollAnimation(groupName, finalNPC, rarity, isLuckBoost, spinFast)
    -- Make sure the same model doesn't show up twice in a row
    local previousModel = nil
    local num = 20

    -- This allows for fast spins
	if spinFast then
		num = 8
	end

    -- Each spin slows slightly to simulate momentum
	for i = 1, num do
		local randomModel
		repeat
			randomModel = getWeightedRandomNPCName(groupName, isLuckBoost) -- if luck boost it has better odds
		until randomModel ~= previousModel

		previousModel = randomModel
		local randomRarity = NPC_Rarities_ByGroup[groupName][randomModel].rarity

        -- Script that shows a model in a specific camera angle on the viewport object (on the screen)
		showModelInViewport(randomModel, randomRarity, groupName)
		spinAudio:Play()
		wait(0.04 + (i * 0.01))
	end 
end
```

<a href="https://imgflip.com/gif/9wnrjz">
  <img src="https://i.imgflip.com/9wnrjz.gif" width="500" alt="Equip System Preview"/>
</a>


This function is the heart of the game’s rolling system — it controls the animation, pacing, and visual randomness that make the gacha experience feel dynamic and rewarding.

It utilizes the Roblox Viewport, a local screen object, to display character models that are stored in ServerStorage. These models are paired with rarity-specific colors, sound effects, and timed animations to give each roll its unique feel.

Additional logic includes:
- A **spinFast** variable, triggered by the fast-roll button, which reduces the spin to 8 models for a quicker animation.
- An **isLuckBoost** variable, activated either every 10th roll or via a luck boost item, which alters the underlying probabilities to favor rarer characters.

🌀 Two-Stage Rolling Design:
Before spinning for an individual character, the system first spins through K-pop groups to land on one. Once selected, only members from that group are included in the character spin. This adds an extra layer of anticipation and gives each roll a more personalized, group-themed experience.

### Luck System Scripts:
```lua
local NPC_Rarities_ByGroup = {
	FEARLINGS = {
                -- Mythics 
		["Candy Wonnie"] = {weight = 5, rarity = "Mythic"},
		["Dress Sakkee"] = {weight = 5, rarity = "Mythic"},
		["Laker Jen"] = {weight = 5, rarity = "Mythic"},

		-- Legendaries (1% total = 100)
		-- characters here  

		-- Epics (7.5% total = 750)
		-- characters here  

		-- Rares
		-- characters here  

                -- Commons (50% total = 5000)
		["Wonnie"] = {weight = 1000, rarity = "Common"},
		["Jen"] = {weight = 1000, rarity = "Common"},
		["Zuaa"] = {weight = 1000, rarity = "Common"},
		["Sakkee"] = {weight = 1000, rarity = "Common"},
		["Munche"] = {weight = 1000, rarity = "Common"},
	},
        OTHER_GROUPS = {

        }
```

<p align="center">
  <img src="https://github.com/user-attachments/assets/3d85f473-5ee1-4a5f-9ab5-bc9b2d7fa157" height="300"/>
  <img src="https://github.com/user-attachments/assets/398c50e6-b65a-40b9-ab39-dd563d7a85de" height="300"/>
  <img src="https://github.com/user-attachments/assets/0de38e21-f30b-46f8-b624-529aec57e885" height="300"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/6927ae6e-3793-4072-ba05-da14666c002d" height="300"/>
  <img src="https://github.com/user-attachments/assets/c2b767d6-7b1a-428b-9d84-0773e606f737" height="300"/>
</p>

I designed the game with five rarity groups to balance excitement, collectibility, and player retention:

- The most decorated and iconic members or outfits are assigned to the highest rarities (e.g., Mythic, Legendary). These characters are rarer but more visually striking, with special effects—like Candy Wonnie’s unique candy aura—and enhanced name tags in-game.

- The rarity tiers are weighted carefully to make rare characters feel special and valuable but still attainable enough to keep K-pop fans engaged and motivated to keep rolling.

- Common characters make up the majority of pulls to keep the collection accessible, while epic and rare tiers serve as exciting middle ground.

- This tiered system reflects the popularity and iconic status of members and their costumes, encouraging players who are fans of those groups to stay longer and enjoy hunting for their favorites.

```lua
-- Global variables:
local luckEffect = false

local function shouldApplyLuckBonus()
	if LuckEffectSystem.isLuckEffectActive() then
		luckEffect = true
	end
end


local function getWeightedRandomNPCName(groupName, isLuckBoost)
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
```
Additionally, when choosing a random character for a roll, the system checks whether the roll qualifies as “lucky.” This can happen in two ways:

- Guaranteed Luck Roll: Every 10th roll is automatically lucky, rewarding consistent play.

- Temporary Luck Boost: Picking up and activating a K-pop lightstick grants a 90-second window where luck is boosted.

If the roll is lucky, the game increases the chances of pulling rarer characters by dynamically adjusting probability weights during the selection process. This system creates rewarding peaks in gameplay while incentivizing both long-term play and map exploration.

---
## 💼 Inventory System 

<img src="https://github.com/user-attachments/assets/473f79bb-edfa-4fa5-8457-eb35a96e3efc" width="700"/>

### Overview:
- Inventory GUI creation
- DataStores to save player informatipn
- Shared game state

### Inventory UI:

<p align="center">
  <img src="https://github.com/user-attachments/assets/3cef85c7-443b-46ad-b481-d25fa78149f4" height="375"/>
  <img src="https://github.com/user-attachments/assets/c969dcef-05bf-482b-a678-479291e97d98" height="375"/>
</p>






## 🌟 Inspirations
### Game Design:
- Inspired by games like *Genshin Impact*, *All Star Tower Defense*, and *Obby but Better*
- Gacha system inspired by mobile games and random loot mechanics

### Character & Map Design:
- Character models influenced by [real groups/characters like LE SSERAFIM, TWICE]
- Map themes based on [e.g., music stages, concert sets, cityscapes]
