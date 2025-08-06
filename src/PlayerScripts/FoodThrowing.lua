-- Food Fighter - Food Throwing System (FINAL WORKING VERSION)
-- Place this in StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

-- Load modules safely
local FoodPhysics = nil
local FoodSounds = nil

-- Try to load modules with error handling
local success, error = pcall(function()
	local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
	if Modules then
		FoodPhysics = require(Modules:WaitForChild("FoodPhysics"))
		FoodSounds = require(Modules:WaitForChild("FoodSounds"))
		print("✅ FoodThrowing: Dependencies loaded")
	end
end)

if not success then
	warn("FoodThrowing: Failed to load modules: " .. tostring(error))
	FoodPhysics = nil
	FoodSounds = nil
end

-- Wait for player and mouse to be ready
repeat wait() until player and player:GetMouse()
local mouse = player:GetMouse()

-- Game State
local throwingActive = false
local playerFoods = {}
local currentFoodIndex = 1
local trajectoryParts = {}

-- UI Elements
local throwingUI = nil

-- Create throwing UI
local function createThrowingUI()
	print("Creating throwing UI...")

	if not player or not player.PlayerGui then
		print("Player or PlayerGui not found!")
		return false
	end

	local foodCount = #playerFoods

	-- Check if UI already exists
	local existingUI = player.PlayerGui:FindFirstChild("ThrowingUI")
	if existingUI then
		existingUI:Destroy()
	end

	-- Create UI elements
	local success1, screenGui = pcall(function()
		local gui = Instance.new("ScreenGui")
		gui.Name = "ThrowingUI"
		gui.ResetOnSpawn = false
		gui.Parent = player.PlayerGui
		return gui
	end)

	if not success1 then
		print("Failed to create ScreenGui")
		return false
	end

	-- Create food label
	local success2, foodLabel = pcall(function()
		local label = Instance.new("TextLabel")
		label.Name = "FoodDisplay"
		label.Size = UDim2.new(0.3, 0, 0.1, 0)
		label.Position = UDim2.new(0.02, 0, 0.02, 0)
		label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.BorderSizePixel = 0
		label.Text = "🍟 Food Ready | 🎯 " .. tostring(foodCount) .. " Left"
		label.Parent = screenGui
		return label
	end)

	-- Create instruction label
	local success3, instructionLabel = pcall(function()
		local label = Instance.new("TextLabel")
		label.Name = "Instructions"
		label.Text = "🎯 AIM: Mouse | 🚀 THROW: Left Click | 🔄 SWITCH: Q"
		label.Size = UDim2.new(0.4, 0, 0.05, 0)
		label.Position = UDim2.new(0.02, 0, 0.13, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.TextScaled = true
		label.Font = Enum.Font.Gotham
		label.Parent = screenGui
		return label
	end)

	throwingUI = screenGui
	print("Throwing UI created successfully!")
	return true
end

-- Update current food display
local function updateFoodDisplay()
	if not throwingUI or #playerFoods == 0 then return end

	local currentFood = playerFoods[currentFoodIndex]
	local foodDisplay = throwingUI:FindFirstChild("FoodDisplay")

	if not foodDisplay then return end

	-- Get food emoji
	local emoji = "🍔"
	if currentFood == "Fries" then emoji = "🍟"
	elseif currentFood == "Donut" then emoji = "🍩"
	elseif currentFood == "Hotdog" then emoji = "🌭"
	elseif currentFood == "Juice Box" then emoji = "🧃"
	elseif currentFood == "Pizza Slice" then emoji = "🍕"
	elseif currentFood == "Chicken Leg" then emoji = "🍗"
	end

	foodDisplay.Text = emoji .. " " .. currentFood .. " | 🎯 " .. #playerFoods .. " Left"
end

-- Clear trajectory preview
local function clearTrajectory()
	for _, part in pairs(trajectoryParts) do
		if part and part.Parent then
			part:Destroy()
		end
	end
	trajectoryParts = {}
end

-- Show simple trajectory preview
local function showTrajectory(startPos, targetPos)
	clearTrajectory()

	-- Create simple trajectory dots
	local direction = (targetPos - startPos).Unit
	local distance = (targetPos - startPos).Magnitude

	for i = 1, 10 do
		local t = i / 10
		local pos = startPos + direction * (distance * t) + Vector3.new(0, 20 * math.sin(math.pi * t), 0)

		local dot = Instance.new("Part")
		dot.Name = "TrajectoryDot"
		dot.Size = Vector3.new(0.3, 0.3, 0.3)
		dot.Position = pos
		dot.Shape = Enum.PartType.Ball
		dot.Material = Enum.Material.Neon
		dot.BrickColor = BrickColor.new("Bright green")
		dot.Anchored = true
		dot.CanCollide = false
		dot.Transparency = 0.3
		dot.Parent = workspace

		table.insert(trajectoryParts, dot)
		Debris:AddItem(dot, 0.1)
	end
end

-- Launch food projectile (FIXED VERSION - NO DEPENDENCY ON COMPLEX PHYSICS)
local function launchFood(targetPos)
	if #playerFoods == 0 then return end

	local currentFood = playerFoods[currentFoodIndex]
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	local startPos = character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)

	-- Create simple food projectile
	local food = Instance.new("Part")
	food.Name = currentFood .. "Projectile"
	food.Size = Vector3.new(1, 1, 1)
	food.Position = startPos
	food.Shape = Enum.PartType.Ball
	food.Material = Enum.Material.Plastic
	food.CanCollide = true
	food.Anchored = false
	food.Parent = workspace

	-- Color based on food type
	if currentFood == "Fries" then
		food.Color = Color3.fromRGB(255, 215, 0) -- Gold
	elseif currentFood == "Donut" then
		food.Color = Color3.fromRGB(210, 180, 140) -- Tan
	elseif currentFood == "Hotdog" then
		food.Color = Color3.fromRGB(160, 82, 45) -- Brown
	elseif currentFood == "Juice Box" then
		food.Color = Color3.fromRGB(255, 165, 0) -- Orange
	elseif currentFood == "Pizza Slice" then
		food.Color = Color3.fromRGB(255, 99, 71) -- Tomato
	elseif currentFood == "Chicken Leg" then
		food.Color = Color3.fromRGB(139, 69, 19) -- Saddle brown
	else
		food.Color = Color3.fromRGB(255, 255, 255) -- White default
	end

	-- Add simple physics
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Parent = food

	-- Calculate simple launch velocity
	local direction = (targetPos - startPos).Unit
	local distance = (targetPos - startPos).Magnitude
	local speed = math.min(distance * 2, 100) -- Limit max speed

	bodyVelocity.Velocity = direction * speed + Vector3.new(0, 20, 0) -- Add upward arc

	-- Add spinning effect
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyAngularVelocity.AngularVelocity = Vector3.new(0, 10, 0)
	bodyAngularVelocity.Parent = food

	-- Apply gravity over time
	spawn(function()
		wait(0.2)
		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity.Velocity = bodyVelocity.Velocity + Vector3.new(0, -30, 0)
		end

		wait(0.4)
		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity.Velocity = bodyVelocity.Velocity + Vector3.new(0, -20, 0)
		end
	end)

	-- Simple collision detection
	spawn(function()
		wait(0.1)
		if food and food.Parent then
			local connection
			connection = food.Touched:Connect(function(hit)
				if not food or not food.Parent then
					if connection then connection:Disconnect() end
					return
				end

				local hitCharacter = hit.Parent
				local playerHit = Players:GetPlayerFromCharacter(hitCharacter)

				if playerHit and playerHit ~= player then
					print("🎯 Food hit " .. playerHit.Name .. "!")

					-- Play hit sound if available
					if FoodSounds and FoodSounds.playHitSound then
						pcall(function()
							FoodSounds.playHitSound(currentFood, playerHit.Character.HumanoidRootPart.Position)
						end)
					end

					-- Apply simple knockback
					local humanoidRootPart = playerHit.Character:FindFirstChild("HumanoidRootPart")
					if humanoidRootPart then
						local knockback = Instance.new("BodyVelocity")
						knockback.MaxForce = Vector3.new(4000, 0, 4000)
						knockback.Velocity = (humanoidRootPart.Position - food.Position).Unit * 20
						knockback.Parent = humanoidRootPart

						-- Remove knockback after short time
						spawn(function()
							wait(0.3)
							if knockback and knockback.Parent then
								knockback:Destroy()
							end
						end)
					end

					-- Update score if MatchManager available
					if _G.MatchManager and _G.MatchManager.addScore then
						_G.MatchManager.addScore(player, 100, "Hit " .. playerHit.Name)
					end

					-- Destroy food
					if food and food.Parent then
						food:Destroy()
					end
					if connection then
						connection:Disconnect()
					end
				end
			end)
		end
	end)

	-- Clean up food after 5 seconds
	Debris:AddItem(food, 5)

	-- Play throw sound if available
	if FoodSounds and FoodSounds.playThrowSound then
		pcall(function()
			FoodSounds.playThrowSound(currentFood, startPos)
		end)
	end

	-- Remove used food from inventory
	table.remove(playerFoods, currentFoodIndex)
	if currentFoodIndex > #playerFoods and #playerFoods > 0 then
		currentFoodIndex = 1
	end

	updateFoodDisplay()
	print("🚀 Launched " .. currentFood .. " toward " .. tostring(targetPos))
end

-- Connect input events
local function connectInputEvents()
	print("Connecting input events...")

	if not mouse then
		mouse = player:GetMouse()
		if not mouse then
			print("Failed to get mouse")
			return
		end
	end

	-- Handle input
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not throwingActive then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Left click to throw
			if mouse and mouse.Hit then
				local targetPos = mouse.Hit.Position
				launchFood(targetPos)
				clearTrajectory()
			end

		elseif input.KeyCode == Enum.KeyCode.Q then
			-- Q to switch food
			if #playerFoods > 1 then
				currentFoodIndex = currentFoodIndex + 1
				if currentFoodIndex > #playerFoods then
					currentFoodIndex = 1
				end
				updateFoodDisplay()

				-- Play switch sound if available
				if FoodSounds and FoodSounds.playUISound then
					pcall(function()
						FoodSounds.playUISound("FoodSwitch", player)
					end)
				end
			end
		end
	end)

	-- Handle mouse movement for trajectory preview
	if mouse then
		mouse.Move:Connect(function()
			if not throwingActive or #playerFoods == 0 then return end

			local character = player.Character
			if not character or not character:FindFirstChild("HumanoidRootPart") then return end
			if not mouse.Hit then return end

			local startPos = character.HumanoidRootPart.Position + Vector3.new(0, 3, 0)
			local targetPos = mouse.Hit.Position

			showTrajectory(startPos, targetPos)
		end)
	end

	print("Input events connected successfully!")
end

-- Initialize throwing system
local function initializeThrowingSystem()
	print("Initializing Food Throwing System...")

	-- Wait for player foods from selection
	local foodsFolder = player:FindFirstChild("PlayerFoods")
	if not foodsFolder then
		print("Waiting for PlayerFoods folder...")
		foodsFolder = player:WaitForChild("PlayerFoods", 10)
		if not foodsFolder then
			print("No foods selected - throwing system disabled")
			return
		end
	end

	-- Load selected foods
	playerFoods = {}
	for _, foodValue in pairs(foodsFolder:GetChildren()) do
		if foodValue:IsA("StringValue") then
			table.insert(playerFoods, foodValue.Value)
			print("Loaded food: " .. foodValue.Value)
		end
	end

	print("Loaded " .. #playerFoods .. " foods for throwing")

	if #playerFoods > 0 then
		-- Try to create UI with error handling
		local success = createThrowingUI()

		if success then
			print("UI created successfully!")
			throwingActive = true

			-- Connect input events AFTER UI is created
			local inputSuccess, inputError = pcall(function()
				connectInputEvents()
			end)

			if inputSuccess then
				print("Food throwing system ready!")

				-- Update display
				spawn(function()
					wait(0.1)
					if throwingUI and playerFoods and #playerFoods > 0 then
						updateFoodDisplay()
					end
				end)
			else
				print("Input connection failed: " .. tostring(inputError))
			end
		else
			print("UI creation failed!")
		end
	else
		print("No foods loaded - system inactive")
	end
end

-- Wait for game to start, then initialize
spawn(function()
	-- Wait for the food selection to complete
	repeat
		wait(1)
		print("Checking for PlayerFoods folder...")
	until player:FindFirstChild("PlayerFoods")

	print("PlayerFoods folder found! Starting throwing system...")
	wait(1)
	initializeThrowingSystem()
end)