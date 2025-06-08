# 🎮 [Photocard RNG]

## Watch the Demo:

[![Watch the demo](https://img.youtube.com/vi/lUSLr8VZizY/maxresdefault.jpg)](https://www.youtube.com/watch?v=lUSLr8VZizY)



## 📘 Overview
**Photocard RNG** is a free gacha RPG collection game where players roll to collect, equip, and interact with characters inspired by 50 K-pop idols accross 6 different K-pop groups.  

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

## 🌟 Inspirations
### Game Design:
- Inspired by games like *Genshin Impact*, *All Star Tower Defense*, and *Obby but Better*
- Gacha system inspired by mobile games and random loot mechanics

### Character & Map Design:
- Character models influenced by [real groups/characters like LE SSERAFIM, TWICE]
- Map themes based on [e.g., music stages, concert sets, cityscapes]

---

## 🧪 GUI System & Code
### Interface Layout:
- Inventory GUI, Info panel, Roll UI
- ViewportFrames used to show 3D character previews
- Custom color schemes based on rarity

### Key GUI Scripts:
```lua
-- Show character model in ViewportFrame
function showModelInViewport(viewport, characterModel)
    local clone = characterModel:Clone()
    clone.Parent = viewport
    -- camera setup code here
end
