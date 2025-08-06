-- Food Fighter - Sound Effects System
-- Place this in ReplicatedStorage/Modules/FoodSounds

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- Sound Configuration
local SOUND_CONFIG = {
	-- Throwing sounds
	Throw = {
		SoundId = "rbxasset://sounds/impact_explosion_02.mp3",
		Volume = 0.6,
		PlaybackSpeed = 1.0
	},
	
	-- Hit sounds
	Hit = {
		SoundId = "rbxasset://sounds/impact_explosion_03.mp3",
		Volume = 0.7,
		PlaybackSpeed = 1.2
	},
	
	-- Food-specific sounds
	Fries = {
		SoundId = "rbxasset://sounds/impact_water.mp3",
		Volume = 0.5,
		PlaybackSpeed = 1.1
	},
	Donut = {
		SoundId = "rbxasset://sounds/impact_metal.mp3",
		Volume = 0.6,
		PlaybackSpeed = 0.9
	},
	Hotdog = {
		SoundId = "rbxasset://sounds/impact_wood.mp3",
		Volume = 0.5,
		PlaybackSpeed = 1.0
	},
	["Juice Box"] = {
		SoundId = "rbxasset://sounds/impact_water.mp3",
		Volume = 0.7,
		PlaybackSpeed = 1.3
	},
	["Pizza Slice"] = {
		SoundId = "rbxasset://sounds/impact_metal.mp3",
		Volume = 0.6,
		PlaybackSpeed = 0.8
	},
	["Chicken Leg"] = {
		SoundId = "rbxasset://sounds/impact_wood.mp3",
		Volume = 0.5,
		PlaybackSpeed = 1.1
	},
	
	-- UI sounds
	ButtonClick = {
		SoundId = "rbxasset://sounds/button-09.mp3",
		Volume = 0.4,
		PlaybackSpeed = 1.0
	},
	FoodSwitch = {
		SoundId = "rbxasset://sounds/electronicpingshort.mp3",
		Volume = 0.3,
		PlaybackSpeed = 1.2
	},
	
	-- Ambient sounds
	GameStart = {
		SoundId = "rbxasset://sounds/electronicpingshort.mp3",
		Volume = 0.6,
		PlaybackSpeed = 1.0
	},
	GameEnd = {
		SoundId = "rbxasset://sounds/electronicpingshort.mp3",
		Volume = 0.6,
		PlaybackSpeed = 0.8
	}
}

-- Create and play sound at position
local function playSoundAtPosition(soundType, position, config)
	if not position then return end
	
	-- Get sound configuration
	local soundConfig = config or SOUND_CONFIG[soundType]
	if not soundConfig then
		print("No sound config found for: " .. tostring(soundType))
		return
	end
	
	-- Create sound object
	local sound = Instance.new("Sound")
	sound.SoundId = soundConfig.SoundId
	sound.Volume = soundConfig.Volume
	sound.PlaybackSpeed = soundConfig.PlaybackSpeed
	sound.Parent = workspace
	
	-- Position the sound
	local soundPart = Instance.new("Part")
	soundPart.Size = Vector3.new(1, 1, 1)
	soundPart.Position = position
	soundPart.Anchored = true
	soundPart.CanCollide = false
	soundPart.Transparency = 1
	soundPart.Parent = workspace
	
	sound.Parent = soundPart
	
	-- Play the sound
	sound:Play()
	
	-- Clean up after sound finishes
	sound.Ended:Connect(function()
		soundPart:Destroy()
	end)
	
	-- Fallback cleanup
	Debris:AddItem(soundPart, 5)
end

-- Play sound for specific player
local function playSoundForPlayer(soundType, player, config)
	if not player then return end
	
	local soundConfig = config or SOUND_CONFIG[soundType]
	if not soundConfig then return end
	
	-- Create sound in player's character
	local character = player.Character
	if not character then return end
	
	local sound = Instance.new("Sound")
	sound.SoundId = soundConfig.SoundId
	sound.Volume = soundConfig.Volume
	sound.PlaybackSpeed = soundConfig.PlaybackSpeed
	sound.Parent = character
	
	sound:Play()
	
	-- Clean up
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
	
	Debris:AddItem(sound, 5)
end

-- Play sound for all players
local function playSoundForAll(soundType, config)
	local soundConfig = config or SOUND_CONFIG[soundType]
	if not soundConfig then return end
	
	for _, player in pairs(Players:GetPlayers()) do
		playSoundForPlayer(soundType, player, soundConfig)
	end
end

-- Food-specific sound functions
local function playThrowingSound(foodType, position)
	local soundType = foodType or "Throw"
	playSoundAtPosition(soundType, position)
end

local function playHitSound(foodType, position)
	local soundType = foodType or "Hit"
	playSoundAtPosition(soundType, position)
end

local function playBounceSound(foodType, position)
	local soundType = foodType or "Hit"
	playSoundAtPosition(soundType, position)
end

local function playSwitchingSound(player)
	playSoundForPlayer("FoodSwitch", player)
end

local function playUISound(soundType, player)
	playSoundForPlayer(soundType, player)
end

-- Module exports
local FoodSounds = {}

FoodSounds.SOUND_CONFIG = SOUND_CONFIG
FoodSounds.playSoundAtPosition = playSoundAtPosition
FoodSounds.playSoundForPlayer = playSoundForPlayer
FoodSounds.playSoundForAll = playSoundForAll
FoodSounds.playThrowingSound = playThrowingSound
FoodSounds.playHitSound = playHitSound
FoodSounds.playBounceSound = playBounceSound
FoodSounds.playSwitchingSound = playSwitchingSound
FoodSounds.playUISound = playUISound

return FoodSounds 