-- Food Fighter - Collision Detection System
-- Place this in ReplicatedStorage/Modules/FoodCollision

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

-- Configuration
local HIT_DAMAGE = 10
local KNOCKBACK_FORCE = 20
local HIT_COOLDOWN = 2 -- seconds between hits on same player

-- Track players who have been hit recently
local hitCooldowns = {}

-- Create hit detection for food projectiles
local function setupFoodCollision(food)
	if not food then return end
	
	-- Wait for the food to be created
	wait(0.1)
	
	-- Connect collision detection
	local connection
	connection = food.Touched:Connect(function(hit)
		if not food or not food.Parent then
			if connection then connection:Disconnect() end
			return
		end
		
		-- Check if we hit a player
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		
		if player then
			-- Check cooldown
			local currentTime = tick()
			if hitCooldowns[player] and (currentTime - hitCooldowns[player]) < HIT_COOLDOWN then
				return -- Still in cooldown
			end
			
			-- Apply damage and knockback
			applyHitEffect(player, food)
			
			-- Set cooldown
			hitCooldowns[player] = currentTime
			
			-- Remove the food
			if food and food.Parent then
				food:Destroy()
			end
			
			-- Disconnect the connection
			if connection then
				connection:Disconnect()
			end
		else
			-- Check if we hit the table or other obstacles
			if hit.Name == "TableSurface" or hit.Name == "MainTable" then
				-- Create impact effect on table
				local impactPos = food.Position
				createFoodImpact(food.Name:gsub("Projectile", ""), impactPos)
				
				-- Remove the food
				if food and food.Parent then
					food:Destroy()
				end
				
				-- Disconnect the connection
				if connection then
					connection:Disconnect()
				end
			end
		end
	end)
	
	-- Auto-destroy food after 10 seconds if it doesn't hit anything
	Debris:AddItem(food, 10)
end

-- Apply hit effects to player
local function applyHitEffect(player, food)
	if not player or not player.Character then return end
	
	local character = player.Character
	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid or not rootPart then return end
	
	-- Apply damage
	humanoid.Health = humanoid.Health - HIT_DAMAGE
	
	-- Apply knockback
	local knockbackDirection = (rootPart.Position - food.Position).Unit
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.Velocity = knockbackDirection * KNOCKBACK_FORCE
	bodyVelocity.Parent = rootPart
	
	-- Remove knockback after 0.5 seconds
	Debris:AddItem(bodyVelocity, 0.5)
	
	-- Create hit effect
	createHitEffect(food.Position)
	
	-- Update score for the attacker
	local foodOwner = food:FindFirstChild("Owner")
	if foodOwner and foodOwner.Value then
		local attacker = foodOwner.Value
		if attacker ~= player then
			-- Add score to attacker
			if _G.MatchManager then
				_G.MatchManager.addScore(attacker, 10)
			end
		end
	end
	
	print(player.Name .. " was hit by " .. food.Name .. "! Health: " .. humanoid.Health)
end

-- Create impact effect when food hits table
local function createFoodImpact(foodType, position)
	-- Create impact particle effect
	local impact = Instance.new("Part")
	impact.Size = Vector3.new(1, 1, 1)
	impact.Position = position
	impact.Color = Color3.fromRGB(255, 255, 255)
	impact.Material = Enum.Material.Neon
	impact.Anchored = true
	impact.CanCollide = false
	impact.Shape = Enum.PartType.Ball
	impact.Parent = workspace
	
	-- Animate the impact
	local tween = game:GetService("TweenService"):Create(impact, TweenInfo.new(0.5), {
		Size = Vector3.new(5, 5, 5),
		Transparency = 1
	})
	tween:Play()
	
	-- Clean up
	Debris:AddItem(impact, 0.5)
end

-- Create hit effect on player
local function createHitEffect(position)
	-- Create hit flash effect
	local hitFlash = Instance.new("Part")
	hitFlash.Size = Vector3.new(2, 2, 2)
	hitFlash.Position = position
	hitFlash.Color = Color3.fromRGB(255, 255, 255)
	hitFlash.Material = Enum.Material.Neon
	hitFlash.Anchored = true
	hitFlash.CanCollide = false
	hitFlash.Shape = Enum.PartType.Ball
	hitFlash.Parent = workspace
	
	-- Animate the flash
	local tween = game:GetService("TweenService"):Create(hitFlash, TweenInfo.new(0.3), {
		Size = Vector3.new(8, 8, 8),
		Transparency = 1
	})
	tween:Play()
	
	-- Clean up
	Debris:AddItem(hitFlash, 0.3)
end

-- Reset cooldown for a player
local function resetCooldown(player)
	hitCooldowns[player] = nil
end

-- Get cooldown status for a player
local function getCooldownStatus(player)
	if not hitCooldowns[player] then return 0 end
	
	local currentTime = tick()
	local timeRemaining = HIT_COOLDOWN - (currentTime - hitCooldowns[player])
	return math.max(0, timeRemaining)
end

-- Module exports
local FoodCollision = {}

FoodCollision.setupFoodCollision = setupFoodCollision
FoodCollision.applyHitEffect = applyHitEffect
FoodCollision.createFoodImpact = createFoodImpact
FoodCollision.createHitEffect = createHitEffect
FoodCollision.resetCooldown = resetCooldown
FoodCollision.getCooldownStatus = getCooldownStatus

return FoodCollision 