-- Food Fighter - Sound Manager (Step 3: Complete Audio System)
-- Place this in StarterPlayerScripts/SoundManager.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

print("🔊 Starting Step 3: Sound System")

-- Sound Configuration with Roblox built-in sounds
local SOUND_LIBRARY = {
	-- Food throwing sounds (using Roblox built-in audio)
	Throwing = {
		Fries = {id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.3, pitch = 1.2},
		Donut = {id = "rbxasset://sounds/button-09.mp3", volume = 0.4, pitch = 0.8},
		Hotdog = {id = "rbxasset://sounds/impact_explosion_03.mp3", volume = 0.3, pitch = 1.1},
		["Juice Box"] = {id = "rbxasset://sounds/impact_water.mp3", volume = 0.4, pitch = 1.0},
		["Pizza Slice"] = {id = "rbxasset://sounds/impact_metal.mp3", volume = 0.3, pitch = 0.9},
		["Chicken Leg"] = {id = "rbxasset://sounds/impact_wood.mp3", volume = 0.4, pitch = 1.0}
	},

	-- Impact sounds
	Impact = {
		PlayerHit = {id = "rbxasset://sounds/impact_explosion_02.mp3", volume = 0.6, pitch = 1.0},
		TableHit = {id = "rbxasset://sounds/impact_wood.mp3", volume = 0.4, pitch = 0.8},
		WallHit = {id = "rbxasset://sounds/impact_metal.mp3", volume = 0.3, pitch = 0.7},
		FloorHit = {id = "rbxasset://sounds/footsteps/concrete1.mp3", volume = 0.3, pitch = 0.6}
	},

	-- UI and game state sounds
	UI = {
		FoodSelect = {id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.2, pitch = 1.5},
		FoodSwitch = {id = "rbxasset://sounds/button-3.mp3", volume = 0.3, pitch = 1.2},
		MatchStart = {id = "rbxasset://sounds/victory.mp3", volume = 0.5, pitch = 1.0},
		MatchEnd = {id = "rbxasset://sounds/victory.mp3", volume = 0.4, pitch = 0.8},
		MoneyEarn = {id = "rbxasset://sounds/electronicpingshort.wav", volume = 0.3, pitch = 2.0}
	},

	-- Ambient sounds
	Ambient = {
		CafeteriaBackground = {id = "rbxasset://sounds/ambient/ambiencecafe.mp3", volume = 0.1, pitch = 1.0, looped = true},
		CombatTension = {id = "rbxasset://sounds/ambient/ambiencecafe.mp3", volume = 0.15, pitch = 1.3, looped = true}
	}
}

-- Sound Manager Class
local SoundManager = {
	sounds = {},
	ambientSounds = {},
	masterVolume = 0.7,
	soundEnabled = true
}

-- Create and configure a sound object
function SoundManager.createSound(soundData, parent)
	if not soundData or not parent then return nil end

	local sound = Instance.new("Sound")
	sound.SoundId = soundData.id
	sound.Volume = (soundData.volume or 0.5) * SoundManager.masterVolume
	sound.PlaybackSpeed = soundData.pitch or 1.0
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.MaxDistance = 100
	sound.Parent = parent

	if soundData.looped then
		sound.Looped = true
	end

	return sound
end

-- Play sound at a specific position in the world
function SoundManager.playSoundAtPosition(soundType, category, position)
	if not SoundManager.soundEnabled then return end
	if not position then return end

	local soundData = SOUND_LIBRARY[category] and SOUND_LIBRARY[category][soundType]
	if not soundData then 
		warn("Sound not found: " .. category .. "." .. soundType)
		return 
	end

	-- Create invisible part to hold the sound
	local soundPart = Instance.new("Part")
	soundPart.Name = "SoundHolder"
	soundPart.Size = Vector3.new(0.1, 0.1, 0.1)
	soundPart.Position = position
	soundPart.Anchored = true
	soundPart.CanCollide = false
	soundPart.Transparency = 1
	soundPart.Parent = workspace

	-- Create and play sound
	local sound = SoundManager.createSound(soundData, soundPart)
	if sound then
		sound:Play()

		-- Clean up after sound finishes
		sound.Ended:Connect(function()
			soundPart:Destroy()
		end)

		-- Failsafe cleanup
		Debris:AddItem(soundPart, 5)

		return sound
	end
end

-- Play sound for the local player only
function SoundManager.playLocalSound(soundType, category)
	if not SoundManager.soundEnabled then return end

	local soundData = SOUND_LIBRARY[category] and SOUND_LIBRARY[category][soundType]
	if not soundData then 
		warn("Sound not found: " .. category .. "." .. soundType)
		return 
	end

	-- Play through SoundService for local player
	local sound = SoundManager.createSound(soundData, SoundService)
	if sound then
		sound:Play()

		-- Clean up after playing
		sound.Ended:Connect(function()
			sound:Destroy()
		end)

		-- Store reference
		SoundManager.sounds[soundType] = sound
		return sound
	end
end

-- Start ambient background sound
function SoundManager.startAmbientSound(soundType)
	if not SoundManager.soundEnabled then return end

	local soundData = SOUND_LIBRARY.Ambient[soundType]
	if not soundData then return end

	-- Stop existing ambient sound
	SoundManager.stopAmbientSound(soundType)

	-- Create new ambient sound
	local sound = SoundManager.createSound(soundData, SoundService)
	if sound then
		sound:Play()
		SoundManager.ambientSounds[soundType] = sound
		print("🎵 Started ambient sound: " .. soundType)
		return sound
	end
end

-- Stop ambient sound
function SoundManager.stopAmbientSound(soundType)
	local sound = SoundManager.ambientSounds[soundType]
	if sound then
		sound:Stop()
		sound:Destroy()
		SoundManager.ambientSounds[soundType] = nil
		print("🔇 Stopped ambient sound: " .. soundType)
	end
end

-- Food throwing sound integration
function SoundManager.onFoodThrown(foodType, position)
	if foodType and position then
		SoundManager.playSoundAtPosition(foodType, "Throwing", position)
		print("🎵 Playing throw sound: " .. foodType)
	end
end

-- Food impact sound integration  
function SoundManager.onFoodImpact(impactType, position)
	if impactType and position then
		SoundManager.playSoundAtPosition(impactType, "Impact", position)
		print("🎵 Playing impact sound: " .. impactType)
	end
end

-- UI sound integration
function SoundManager.onUIEvent(eventType)
	if eventType then
		SoundManager.playLocalSound(eventType, "UI")
		print("🎵 Playing UI sound: " .. eventType)
	end
end

-- Volume control
function SoundManager.setMasterVolume(volume)
	SoundManager.masterVolume = math.clamp(volume, 0, 1)

	-- Update all existing sounds
	for _, sound in pairs(SoundManager.sounds) do
		if sound and sound.Parent then
			sound.Volume = sound.Volume * SoundManager.masterVolume
		end
	end

	for _, sound in pairs(SoundManager.ambientSounds) do
		if sound and sound.Parent then
			sound.Volume = sound.Volume * SoundManager.masterVolume
		end
	end

	print("🔊 Master volume set to: " .. (SoundManager.masterVolume * 100) .. "%")
end

-- Toggle all sounds on/off
function SoundManager.toggleSound()
	SoundManager.soundEnabled = not SoundManager.soundEnabled

	if SoundManager.soundEnabled then
		print("🔊 Sounds enabled")
		SoundManager.startAmbientSound("CafeteriaBackground")
	else
		print("🔇 Sounds disabled")
		-- Stop all ambient sounds
		for soundType, _ in pairs(SoundManager.ambientSounds) do
			SoundManager.stopAmbientSound(soundType)
		end
	end
end

-- Initialize sound system
function SoundManager.initialize()
	print("🔊 Initializing Sound Manager...")

	-- Start background ambient sound
	wait(2) -- Wait for game to load
	SoundManager.startAmbientSound("CafeteriaBackground")

	-- Set up volume controls (optional)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		-- M key to toggle sound
		if input.KeyCode == Enum.KeyCode.M then
			SoundManager.toggleSound()
		end

		-- Volume controls with + and - keys
		if input.KeyCode == Enum.KeyCode.Equals then -- + key
			local newVolume = math.min(SoundManager.masterVolume + 0.1, 1)
			SoundManager.setMasterVolume(newVolume)
		elseif input.KeyCode == Enum.KeyCode.Minus then -- - key
			local newVolume = math.max(SoundManager.masterVolume - 0.1, 0)
			SoundManager.setMasterVolume(newVolume)
		end
	end)

	print("✅ Sound Manager initialized!")
	print("🎮 Controls: M = Toggle Sound, +/- = Volume")
end

-- Hook into existing food throwing system
local function hookIntoFoodThrowing()
	-- Monitor for food projectiles being created
	workspace.ChildAdded:Connect(function(child)
		if child.Name:find("Projectile") then
			-- Food was thrown - play sound
			local foodType = child.Name:gsub("Projectile", "")
			local position = child.Position
			SoundManager.onFoodThrown(foodType, position)

			-- Monitor for impacts
			child.Touched:Connect(function(hit)
				if hit.Name == "TableSurface" or hit.Name == "MainCombatTable" then
					SoundManager.onFoodImpact("TableHit", child.Position)
				elseif hit.Parent:FindFirstChild("Humanoid") then
					SoundManager.onFoodImpact("PlayerHit", child.Position)
				elseif hit.Name == "CafeteriaFloor" then
					SoundManager.onFoodImpact("FloorHit", child.Position)
				else
					SoundManager.onFoodImpact("WallHit", child.Position)
				end
			end)
		end
	end)
end

-- Hook into UI events (if food selection system exists)
local function hookIntoUIEvents()
	-- Monitor PlayerGui for food selection sounds
	if player.PlayerGui then
		player.PlayerGui.ChildAdded:Connect(function(gui)
			if gui.Name == "FoodSelectionUI" then
				-- Hook into food selection buttons
				spawn(function()
					wait(1) -- Wait for UI to load
					local buttons = gui:GetDescendants()
					for _, obj in pairs(buttons) do
						if obj:IsA("TextButton") and obj.Name:find("Food_") then
							obj.MouseButton1Click:Connect(function()
								SoundManager.onUIEvent("FoodSelect")
							end)
						elseif obj:IsA("TextButton") and obj.Name == "ReadyButton" then
							obj.MouseButton1Click:Connect(function()
								SoundManager.onUIEvent("MatchStart")
							end)
						end
					end
				end)
			end
		end)
	end
end

-- Start the sound system
spawn(function()
	SoundManager.initialize()
	hookIntoFoodThrowing()
	hookIntoUIEvents()

	print("🎉 Sound System fully activated!")
	print("🎵 Cafeteria ambience playing")
	print("🎯 Food throwing/impact sounds ready")
	print("🎮 UI feedback sounds ready")
end)

-- Export for other scripts to use
_G.SoundManager = SoundManager

print("✅ Step 3 Complete: Sound System loaded!")