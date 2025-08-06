-- Food Fighter - Particle Effects System
-- Place this in ReplicatedStorage/Modules/FoodParticles

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Particle Configuration
local PARTICLE_CONFIG = {
	-- Food throwing trails
	ThrowTrail = {
		Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
		Transparency = NumberSequence.new(0, 1),
		Size = NumberSequence.new(0.5, 0),
		Lifetime = NumberRange.new(0.5, 1),
		Rate = 50,
		Speed = NumberRange.new(2, 5),
		SpreadAngle = Vector2.new(15, 15)
	},
	
	-- Hit explosions
	HitExplosion = {
		Color = ColorSequence.new(Color3.fromRGB(255, 100, 100)),
		Transparency = NumberSequence.new(0, 1),
		Size = NumberSequence.new(2, 0),
		Lifetime = NumberRange.new(0.5, 1.5),
		Rate = 100,
		Speed = NumberRange.new(10, 20),
		SpreadAngle = Vector2.new(360, 360)
	},
	
	-- Food-specific particles
	Fries = {
		Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)),
		Transparency = NumberSequence.new(0, 1),
		Size = NumberSequence.new(0.3, 0),
		Lifetime = NumberRange.new(0.3, 0.8),
		Rate = 30,
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(20, 20)
	},
	Donut = {
		Color = ColorSequence.new(Color3.fromRGB(210, 180, 140)),
		Transparency = NumberSequence.new(0, 1),
		Size = NumberSequence.new(0.4, 0),
		Lifetime = NumberRange.new(0.4, 1),
		Rate = 25,
		Speed = NumberRange.new(2, 6),
		SpreadAngle = Vector2.new(25, 25)
	},
	Hotdog = {
		Color = ColorSequence.new(Color3.fromRGB(160, 82, 45)),
		Transparency = NumberSequence.new(0, 1),
		Size = NumberSequence.new(0.3, 0),
		Lifetime = NumberRange.new(0.3, 0.7),
		Rate = 35,
		Speed = NumberRange.new(4, 9),
		SpreadAngle = Vector2.new(15, 15)
	},
	["Juice Box"] = {
		Color = ColorSequence.new(Color3.fromRGB(255, 165, 0)),
		Transparency = NumberSequence.new(0, 1),
		Size = NumberSequence.new(0.5, 0),
		Lifetime = NumberRange.new(0.5, 1.2),
		Rate = 20,
		Speed = NumberRange.new(1, 4),
		SpreadAngle = Vector2.new(30, 30)
	},
	["Pizza Slice"] = {
		Color = ColorSequence.new(Color3.fromRGB(255, 99, 71)),
		Transparency = NumberSequence.new(0, 1),
		Size = NumberSequence.new(0.4, 0),
		Lifetime = NumberRange.new(0.4, 0.9),
		Rate = 30,
		Speed = NumberRange.new(3, 7),
		SpreadAngle = Vector2.new(18, 18)
	},
	["Chicken Leg"] = {
		Color = ColorSequence.new(Color3.fromRGB(139, 69, 19)),
		Transparency = NumberSequence.new(0, 1),
		Size = NumberSequence.new(0.3, 0),
		Lifetime = NumberRange.new(0.3, 0.8),
		Rate = 40,
		Speed = NumberRange.new(5, 10),
		SpreadAngle = Vector2.new(12, 12)
	}
}

-- Create particle emitter
local function createParticleEmitter(parent, config)
	if not parent or not config then return nil end
	
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = config.Color
	emitter.Transparency = config.Transparency
	emitter.Size = config.Size
	emitter.Lifetime = config.Lifetime
	emitter.Rate = config.Rate
	emitter.Speed = config.Speed
	emitter.SpreadAngle = config.SpreadAngle
	emitter.Parent = parent
	
	return emitter
end

-- Create throwing trail effect
local function createThrowTrail(food)
	if not food then return end
	
	local config = PARTICLE_CONFIG.ThrowTrail
	local emitter = createParticleEmitter(food, config)
	
	if emitter then
		-- Stop emitting after 3 seconds
		spawn(function()
			wait(3)
			if emitter and emitter.Parent then
				emitter.Enabled = false
			end
		end)
		
		-- Clean up emitter when food is destroyed
		food.AncestryChanged:Connect(function()
			if emitter and emitter.Parent then
				emitter:Destroy()
			end
		end)
	end
end

-- Create hit explosion effect
local function createHitExplosion(position)
	if not position then return end
	
	-- Create temporary part to hold particles
	local explosionPart = Instance.new("Part")
	explosionPart.Size = Vector3.new(1, 1, 1)
	explosionPart.Position = position
	explosionPart.Anchored = true
	explosionPart.CanCollide = false
	explosionPart.Transparency = 1
	explosionPart.Parent = workspace
	
	local config = PARTICLE_CONFIG.HitExplosion
	local emitter = createParticleEmitter(explosionPart, config)
	
	if emitter then
		-- Stop emitting after 0.5 seconds
		spawn(function()
			wait(0.5)
			if emitter and emitter.Parent then
				emitter.Enabled = false
			end
		end)
		
		-- Clean up after 2 seconds
		Debris:AddItem(explosionPart, 2)
	end
end

-- Create food-specific impact effect
local function createFoodImpact(foodType, position)
	if not position then return end
	
	local config = PARTICLE_CONFIG[foodType]
	if not config then
		config = PARTICLE_CONFIG.Fries -- Default to fries
	end
	
	-- Create temporary part to hold particles
	local impactPart = Instance.new("Part")
	impactPart.Size = Vector3.new(1, 1, 1)
	impactPart.Position = position
	impactPart.Anchored = true
	impactPart.CanCollide = false
	impactPart.Transparency = 1
	impactPart.Parent = workspace
	
	local emitter = createParticleEmitter(impactPart, config)
	
	if emitter then
		-- Stop emitting after 0.3 seconds
		spawn(function()
			wait(0.3)
			if emitter and emitter.Parent then
				emitter.Enabled = false
			end
		end)
		
		-- Clean up after 1.5 seconds
		Debris:AddItem(impactPart, 1.5)
	end
end

-- Create score popup effect
local function createScorePopup(position, score, color)
	if not position then return end
	
	-- Create score text
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 100, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)
	billboardGui.Adornee = Instance.new("Part")
	billboardGui.Adornee.Size = Vector3.new(1, 1, 1)
	billboardGui.Adornee.Position = position
	billboardGui.Adornee.Anchored = true
	billboardGui.Adornee.CanCollide = false
	billboardGui.Adornee.Transparency = 1
	billboardGui.Adornee.Parent = workspace
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "+" .. tostring(score)
	textLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboardGui
	
	-- Animate the popup
	local tween = TweenService:Create(textLabel, TweenInfo.new(1), {
		Position = UDim2.new(0, 0, -1, 0),
		TextTransparency = 1
	})
	tween:Play()
	
	-- Clean up
	Debris:AddItem(billboardGui, 1)
end

-- Create combo effect
local function createComboEffect(position, comboCount)
	if not position then return end
	
	-- Create combo text
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 150, 0, 60)
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)
	billboardGui.Adornee = Instance.new("Part")
	billboardGui.Adornee.Size = Vector3.new(1, 1, 1)
	billboardGui.Adornee.Position = position
	billboardGui.Adornee.Anchored = true
	billboardGui.Adornee.CanCollide = false
	billboardGui.Adornee.Transparency = 1
	billboardGui.Adornee.Parent = workspace
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "COMBO x" .. tostring(comboCount)
	textLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = billboardGui
	
	-- Animate the combo
	local tween = TweenService:Create(textLabel, TweenInfo.new(1.5), {
		Position = UDim2.new(0, 0, -1.5, 0),
		TextTransparency = 1,
		Size = UDim2.new(1.5, 0, 1.5, 0)
	})
	tween:Play()
	
	-- Clean up
	Debris:AddItem(billboardGui, 1.5)
end

-- Create special effect for specific food types
local function createSpecialEffect(foodType, position)
	if not position then return end
	
	if foodType == "Juice Box" then
		-- Create splash effect
		local splashPart = Instance.new("Part")
		splashPart.Size = Vector3.new(1, 1, 1)
		splashPart.Position = position
		splashPart.Anchored = true
		splashPart.CanCollide = false
		splashPart.Transparency = 1
		splashPart.Parent = workspace
		
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 165, 0))
		emitter.Transparency = NumberSequence.new(0, 1)
		emitter.Size = NumberSequence.new(0.5, 0)
		emitter.Lifetime = NumberRange.new(0.5, 1)
		emitter.Rate = 40
		emitter.Speed = NumberRange.new(3, 8)
		emitter.SpreadAngle = Vector2.new(45, 45)
		emitter.Parent = splashPart
		
		-- Stop after 0.5 seconds
		spawn(function()
			wait(0.5)
			if emitter and emitter.Parent then
				emitter.Enabled = false
			end
		end)
		
		Debris:AddItem(splashPart, 1.5)
		
	elseif foodType == "Pizza Slice" then
		-- Create cheese stretch effect
		local stretchPart = Instance.new("Part")
		stretchPart.Size = Vector3.new(1, 1, 1)
		stretchPart.Position = position
		stretchPart.Anchored = true
		stretchPart.CanCollide = false
		stretchPart.Transparency = 1
		stretchPart.Parent = workspace
		
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
		emitter.Transparency = NumberSequence.new(0, 1)
		emitter.Size = NumberSequence.new(0.3, 0)
		emitter.Lifetime = NumberRange.new(0.8, 1.5)
		emitter.Rate = 25
		emitter.Speed = NumberRange.new(1, 3)
		emitter.SpreadAngle = Vector2.new(20, 20)
		emitter.Parent = stretchPart
		
		-- Stop after 0.8 seconds
		spawn(function()
			wait(0.8)
			if emitter and emitter.Parent then
				emitter.Enabled = false
			end
		end)
		
		Debris:AddItem(stretchPart, 2)
	end
end

-- Module exports
local FoodParticles = {}

FoodParticles.PARTICLE_CONFIG = PARTICLE_CONFIG
FoodParticles.createParticleEmitter = createParticleEmitter
FoodParticles.createThrowTrail = createThrowTrail
FoodParticles.createHitExplosion = createHitExplosion
FoodParticles.createFoodImpact = createFoodImpact
FoodParticles.createScorePopup = createScorePopup
FoodParticles.createComboEffect = createComboEffect
FoodParticles.createSpecialEffect = createSpecialEffect

return FoodParticles 