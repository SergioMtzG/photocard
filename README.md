# 🎮 [Photocard RNG]

[![Watch the demo](https://img.youtube.com/vi/lUSLr8VZizY/maxresdefault.jpg)](https://www.youtube.com/watch?v=lUSLr8VZizY)


![Banner or Game Logo](./assets/banner.png)

## 📘 Overview
**[Game Title]** is a [genre, e.g., "gacha RPG adventure"] where players collect, equip, and interact with characters inspired by [K-pop groups / fantasy / etc.].  
It blends stylish UI, custom models, and smart scripting to create an immersive Roblox experience.

---

## 🕹️ Gameplay Summary
- 🎲 Roll for characters with rarity-based odds
- 🎒 View and manage your personal character inventory
- 🧍 Equip one character to follow you around the map
- 🗺️ Explore a themed world tied to your character's origin

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
