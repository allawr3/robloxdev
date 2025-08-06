-- Food Fighter - Food Physics Module
-- Place this in ReplicatedStorage/Modules/FoodPhysics

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local FoodPhysics = {}

-- Physics Configuration for each food type
FoodPhysics.FOOD_CONFIG = {
	Fries = {
		speed = 150,
		arc = 0.2,
		size = Vector3.new(1, 0.5, 3),
		color = Color3.fromRGB(255, 215, 0),
		mass = 0.5,
		drag = 0.1,
		spinRate = 180, -- degrees per second
		bounces = 0,
		damage = 10,
		cost = 1
	},

	Donut = {
		speed = 120,
		arc = 0.3,
		size = Vector3.new(2, 0.5, 2),
		color = Color3.fromRGB(210, 180, 140),
		mass = 0.7,
		drag = 0.15,
		spinRate = 360,
		bounces = 1, -- Bounces once
		damage = 12,
		cost = 2
	},

	Hotdog = {
		speed = 140,
		arc = 0.25,
		size = Vector3.new(1, 1, 4),
		color = Color3.fromRGB(160, 82, 45),
		mass = 0.8,
		drag = 0.12,
		spinRate = 90,
		bounces = 0,
		damage = 15,
		cost = 3
	},

	["Juice Box"] = {
		speed = 130,
		arc = 0.3,
		size = Vector3.new(1.5, 2, 1.5),
		color = Color3.fromRGB(255, 165, 0),
		mass = 1.2,
		drag = 0.2,
		spinRate = 45,
		bounces = 0,
		damage = 18,
		cost = 4,
		specialEffect = "ScreenShake"
	},

	["Pizza Slice"] = {
		speed = 110,
		arc = 0.4,
		size = Vector3.new(3, 0.5, 2),
		color = Color3.fromRGB(255, 99, 71),
		mass = 1.0,
		drag = 0.25,
		spinRate = 270,
		bounces = 0,
		damage = 22,
		cost = 5,
		specialEffect = "SplashDamage",
		splashRadius = 5
	},

	["Chicken Leg"] = {
		speed = 100,
		arc = 0.5,
		size = Vector3.new(1.5, 3, 1.5),
		color = Color3.fromRGB(139, 69, 19),
		mass = 1.5,
		drag = 0.3,
		spinRate = 120,
		bounces = 0,
		damage = 25,
		cost = 6,
		specialEffect = "GreaseTrail"
	}
}

-- Create food projectile with physics
function FoodPhysics.createFoodProjectile(foodType, startPos, targetPos, owner)
	local config = FoodPhysics.FOOD_CONFIG[foodType]
	if not config then
		warn("Unknown food type: " .. tostring(foodType))
		return nil
	end

	-- Create the food part
	local food = Instance.new("Part")
	food.Name = foodType .. "Projectile"
	food.Size = config.size
	food.Position = startPos
	food.Color = config.color
	food.Material = Enum.Material.Plastic
	food.Shape = Enum.PartType.Block
	food.CanCollide = true
	food.Anchored = false
	food.Parent = workspace

	-- Add physics properties
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Parent = food

	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyAngularVelocity.AngularVelocity = Vector3.new(0, math.rad(config.spinRate), 0)
	bodyAngularVelocity.Parent = food

	-- Calculate launch velocity
	local launchVelocity = FoodPhysics.calculateLaunchVelocity(startPos, targetPos, foodType)
	bodyVelocity.Velocity = launchVelocity

	-- Add bounce counter
	local bounceValue = Instance.new("IntValue")
	bounceValue.Name = "BounceCount"
	bounceValue.Value = 0
	bounceValue.Parent = food

	-- Add owner reference
	if owner then
		local ownerValue = Instance.new("ObjectValue")
		ownerValue.Name = "Owner"
		ownerValue.Value = owner
		ownerValue.Parent = food
	end

	-- Add food type reference
	local typeValue = Instance.new("StringValue")
	typeValue.Name = "FoodType"
	typeValue.Value = foodType
	typeValue.Parent = food

	return food, bodyVelocity
end

-- Calculate launch velocity for trajectory
function FoodPhysics.calculateLaunchVelocity(startPos, targetPos, foodType)
	local config = FoodPhysics.FOOD_CONFIG[foodType]
	if not config then
		return Vector3.new(0, 0, 0)
	end

	local direction = (targetPos - startPos).Unit
	local distance = (targetPos - startPos).Magnitude
	
	-- Calculate base velocity
	local baseSpeed = config.speed
	local arc = config.arc
	
	-- Apply arc for trajectory
	local horizontalSpeed = baseSpeed * (1 - arc)
	local verticalSpeed = baseSpeed * arc
	
	-- Calculate velocity components
	local horizontalVelocity = direction * horizontalSpeed
	local verticalVelocity = Vector3.new(0, verticalSpeed, 0)
	
	return horizontalVelocity + verticalVelocity
end

-- Calculate trajectory points for preview
function FoodPhysics.calculateTrajectoryPoints(startPos, targetPos, foodType, numPoints)
	local points = {}
	local config = FoodPhysics.FOOD_CONFIG[foodType]
	if not config then
		return points
	end

	local velocity = FoodPhysics.calculateLaunchVelocity(startPos, targetPos, foodType)
	local gravity = Vector3.new(0, -9.8, 0)
	local timeStep = 0.1

	for i = 1, numPoints do
		local t = i * timeStep
		local pos = startPos + velocity * t + 0.5 * gravity * t * t
		table.insert(points, pos)
	end

	return points
end

-- Handle food bouncing
function FoodPhysics.handleBounce(food)
	local bounceValue = food:FindFirstChild("BounceCount")
	if not bounceValue then return false end

	local foodType = food:FindFirstChild("FoodType")
	if not foodType then return false end

	local config = FoodPhysics.FOOD_CONFIG[foodType.Value]
	if not config then return false end

	if bounceValue.Value < config.bounces then
		bounceValue.Value = bounceValue.Value + 1
		
		-- Apply bounce physics
		local bodyVelocity = food:FindFirstChild("BodyVelocity")
		if bodyVelocity then
			local currentVelocity = bodyVelocity.Velocity
			local bounceVelocity = Vector3.new(currentVelocity.X * 0.7, math.abs(currentVelocity.Y) * 0.5, currentVelocity.Z * 0.7)
			bodyVelocity.Velocity = bounceVelocity
		end

		return true
	else
		-- Max bounces reached, destroy food
		food:Destroy()
		return false
	end
end

-- Get food stats for UI display
function FoodPhysics.getFoodStats(foodType)
	return FoodPhysics.FOOD_CONFIG[foodType]
end

-- Apply special effects
function FoodPhysics.applySpecialEffect(foodType, position, owner)
	local config = FoodPhysics.FOOD_CONFIG[foodType]
	if not config or not config.specialEffect then return end

	if config.specialEffect == "ScreenShake" then
		-- Apply screen shake to nearby players
		local players = game:GetService("Players"):GetPlayers()
		for _, player in pairs(players) do
			if player ~= owner then
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					local distance = (character.HumanoidRootPart.Position - position).Magnitude
					if distance < 20 then
						-- Send screen shake to client
						local screenShakeEvent = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents"):FindFirstChild("ScreenShakeEvent")
						if screenShakeEvent then
							screenShakeEvent:FireClient(player, 0.5, distance / 20)
						end
					end
				end
			end
		end

	elseif config.specialEffect == "SplashDamage" then
		-- Apply splash damage to nearby players
		local players = game:GetService("Players"):GetPlayers()
		for _, player in pairs(players) do
			if player ~= owner then
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					local distance = (character.HumanoidRootPart.Position - position).Magnitude
					if distance < config.splashRadius then
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid then
							local damage = config.damage * (1 - distance / config.splashRadius)
							humanoid.Health = humanoid.Health - damage
						end
					end
				end
			end
		end

	elseif config.specialEffect == "GreaseTrail" then
		-- Create grease trail effect
		local trail = Instance.new("Trail")
		trail.Lifetime = 2
		trail.MinLength = 0.1
		trail.MaxLength = 5
		trail.WidthScale = NumberSequence.new(0.5)
		trail.Transparency = NumberSequence.new(0.3)
		trail.Color = ColorSequence.new(Color3.fromRGB(139, 69, 19))
		trail.Parent = food
	end
end

-- Clean up food after impact
function FoodPhysics.cleanupFood(food, impactPosition)
	-- Create impact effect
	local impact = Instance.new("Part")
	impact.Size = Vector3.new(1, 1, 1)
	impact.Position = impactPosition
	impact.Color = Color3.fromRGB(255, 255, 255)
	impact.Material = Enum.Material.Neon
	impact.Anchored = true
	impact.CanCollide = false
	impact.Shape = Enum.PartType.Ball
	impact.Parent = workspace

	-- Animate impact
	local tween = TweenService:Create(impact, TweenInfo.new(0.5), {
		Size = Vector3.new(5, 5, 5),
		Transparency = 1
	})
	tween:Play()

	-- Clean up
	Debris:AddItem(impact, 0.5)
	Debris:AddItem(food, 0.1)
end

return FoodPhysics 