-- Food Fighter - Enhanced Food Selection System (FIXED)
-- Multiple selections, no checkmarks, improved UI
-- Place this in StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local function waitForModules()
	print("🔧 FoodSelection: Modules ready!")
	return true
end

-- Constants
local FOOD_DATA = {
	{name = "Fries", emoji = "🍟", cost = 1, damage = "Low"},
	{name = "Donut", emoji = "🍩", cost = 2, damage = "Low"},
	{name = "Hotdog", emoji = "🌭", cost = 3, damage = "Medium"},
	{name = "Juice Box", emoji = "🧃", cost = 4, damage = "Medium"},
	{name = "Pizza Slice", emoji = "🍕", cost = 5, damage = "High"},
	{name = "Chicken Leg", emoji = "🍗", cost = 6, damage = "High"}
}

local STARTING_BUDGET = 10

-- Player state - Track quantities instead of just selection
local playerData = {
	budget = STARTING_BUDGET,
	selectedFoods = {}, -- Will store {food = foodData, quantity = number}
	totalCost = 0,
	totalItems = 0
}

-- UI References
local uiReferences = {
	screenGui = nil,
	mainFrame = nil,
	budgetLabel = nil,
	trayLabel = nil,
	readyButton = nil,
	foodButtons = {},
	glowTweens = {} -- Store glow tweens separately
}

-- Safe RemoteEvent communication
local function safeFireRemoteEvent(eventPath, data)
	local remoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
	if not remoteEvents then
		warn("RemoteEvents folder not found in ReplicatedStorage")
		return false
	end

	local targetEvent = remoteEvents:FindFirstChild(eventPath)
	if not targetEvent then
		warn("RemoteEvent '" .. eventPath .. "' not found")
		return false
	end

	local success, result = pcall(function()
		targetEvent:FireServer(data)
	end)

	if not success then
		warn("Failed to fire RemoteEvent: " .. tostring(result))
		return false
	end

	return true
end

-- Create smooth button flash effect
local function flashButton(button, flashColor)
	local originalColor = button.BackgroundColor3

	local flashTween = TweenService:Create(
		button,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundColor3 = flashColor}
	)

	local returnTween = TweenService:Create(
		button,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundColor3 = originalColor}
	)

	flashTween:Play()
	flashTween.Completed:Connect(function()
		returnTween:Play()
	end)
end

-- Create glow effect for affordable items
local function createGlowEffect(button, foodName)
	local originalColor = button.BackgroundColor3

	local glowTween = TweenService:Create(
		button,
		TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{BackgroundColor3 = Color3.fromRGB(
			math.min(originalColor.R * 255 + 20, 255), 
			math.min(originalColor.G * 255 + 20, 255), 
			math.min(originalColor.B * 255 + 20, 255)
			)}
	)
	glowTween:Play()

	-- Store in separate table instead of as attribute
	uiReferences.glowTweens[foodName] = glowTween

	return glowTween
end

-- UI Creation
local function createFoodSelectionUI()
	print("🔧 [FOOD SELECTION] Creating Enhanced Food Selection UI...")

	-- Clean up existing UI
	local existingUI = player.PlayerGui:FindFirstChild("FoodSelectionUI")
	if existingUI then
		existingUI:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoodSelectionUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player.PlayerGui
	uiReferences.screenGui = screenGui

	-- Main frame with rounded corners
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "SelectionFrame"
	mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
	mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	uiReferences.mainFrame = mainFrame

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	-- Title with enhanced styling
	local title = Instance.new("TextLabel")
	title.Text = "🍕 FOOD FIGHTER - BUILD YOUR ARSENAL 🍕"
	title.Size = UDim2.new(1, 0, 0.1, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold color
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = mainFrame

	-- Instructions
	local instructions = Instance.new("TextLabel")
	instructions.Text = "💡 Click foods multiple times to buy more! 💡"
	instructions.Size = UDim2.new(1, 0, 0.04, 0)
	instructions.Position = UDim2.new(0, 0, 0.10, 0)
	instructions.BackgroundTransparency = 1
	instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
	instructions.TextScaled = true
	instructions.Font = Enum.Font.Gotham
	instructions.Parent = mainFrame

	-- Budget display with enhanced styling
	local budgetLabel = Instance.new("TextLabel")
	budgetLabel.Name = "BudgetLabel"
	budgetLabel.Text = "💰 Budget: $" .. playerData.budget .. " / $" .. STARTING_BUDGET
	budgetLabel.Size = UDim2.new(0.48, 0, 0.06, 0)
	budgetLabel.Position = UDim2.new(0.02, 0, 0.15, 0)
	budgetLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	budgetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	budgetLabel.TextScaled = true
	budgetLabel.Font = Enum.Font.GothamBold
	budgetLabel.TextXAlignment = Enum.TextXAlignment.Center
	budgetLabel.Parent = mainFrame
	uiReferences.budgetLabel = budgetLabel

	-- Add rounded corners to budget
	local budgetCorner = Instance.new("UICorner")
	budgetCorner.CornerRadius = UDim.new(0, 8)
	budgetCorner.Parent = budgetLabel

	-- Selected items display with enhanced styling
	local trayLabel = Instance.new("TextLabel")
	trayLabel.Name = "TrayLabel"
	trayLabel.Text = "🎒 Arsenal: Empty"
	trayLabel.Size = UDim2.new(0.48, 0, 0.06, 0)
	trayLabel.Position = UDim2.new(0.5, 0, 0.15, 0)
	trayLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	trayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	trayLabel.TextScaled = true
	trayLabel.Font = Enum.Font.GothamBold
	trayLabel.TextXAlignment = Enum.TextXAlignment.Center
	trayLabel.Parent = mainFrame
	uiReferences.trayLabel = trayLabel

	-- Add rounded corners to tray
	local trayCorner = Instance.new("UICorner")
	trayCorner.CornerRadius = UDim.new(0, 8)
	trayCorner.Parent = trayLabel

	-- Create enhanced food buttons
	print("🔧 [FOOD SELECTION] Creating enhanced food buttons...")

	for i, food in ipairs(FOOD_DATA) do
		-- Calculate position (2 columns, 3 rows)
		local column = (i - 1) % 2
		local row = math.floor((i - 1) / 2)

		local foodButton = Instance.new("TextButton")
		foodButton.Name = "Food_" .. food.name
		foodButton.Size = UDim2.new(0.4, 0, 0.15, 0)
		foodButton.Position = UDim2.new(0.05 + (column * 0.5), 0, 0.25 + (row * 0.17), 0)
		foodButton.BackgroundColor3 = Color3.fromRGB(70, 70, 180) -- Slightly lighter blue
		foodButton.BorderSizePixel = 0
		foodButton.Text = food.emoji .. " " .. food.name .. "\n$" .. food.cost .. " - " .. food.damage .. " DMG"
		foodButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		foodButton.TextScaled = true
		foodButton.Font = Enum.Font.GothamBold
		foodButton.Parent = mainFrame

		-- Add rounded corners to food buttons
		local foodCorner = Instance.new("UICorner")
		foodCorner.CornerRadius = UDim.new(0, 8)
		foodCorner.Parent = foodButton

		-- Store food data in button
		foodButton:SetAttribute("FoodName", food.name)
		foodButton:SetAttribute("FoodCost", food.cost)
		foodButton:SetAttribute("Quantity", 0) -- Track quantity instead of just selected
		foodButton:SetAttribute("OriginalText", foodButton.Text)

		-- Store button reference
		uiReferences.foodButtons[food.name] = foodButton

		-- Create glow effect for affordable items (stored separately)
		createGlowEffect(foodButton, food.name)

		-- Connect button click
		foodButton.MouseButton1Click:Connect(function()
			selectFood(food, foodButton)
		end)
	end

	-- Enhanced ready button
	local readyButton = Instance.new("TextButton")
	readyButton.Name = "ReadyButton"
	readyButton.Size = UDim2.new(0.3, 0, 0.08, 0)
	readyButton.Position = UDim2.new(0.35, 0, 0.88, 0)
	readyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	readyButton.BorderSizePixel = 0
	readyButton.Text = "🚀 ENTER BATTLE!"
	readyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	readyButton.TextScaled = true
	readyButton.Font = Enum.Font.GothamBold
	readyButton.Active = false
	readyButton.Parent = mainFrame
	uiReferences.readyButton = readyButton

	-- Add rounded corners to ready button
	local readyCorner = Instance.new("UICorner")
	readyCorner.CornerRadius = UDim.new(0, 8)
	readyCorner.Parent = readyButton

	-- Connect ready button
	readyButton.MouseButton1Click:Connect(function()
		if readyButton.Active then
			finishSelection()
		end
	end)

	print("✅ [FOOD SELECTION] Enhanced Food Selection UI created successfully!")
	return screenGui
end

-- Enhanced food selection logic - allows multiple of same food
function selectFood(food, button)
	print("🔧 [FOOD SELECTION] Attempting to select: " .. food.name .. " (Cost: $" .. food.cost .. ")")

	-- Check if we can afford it
	if playerData.budget >= food.cost then
		-- Find existing food in selection or add new
		local existingFood = nil
		for _, selectedFood in ipairs(playerData.selectedFoods) do
			if selectedFood.food.name == food.name then
				existingFood = selectedFood
				break
			end
		end

		if existingFood then
			-- Increase quantity
			existingFood.quantity = existingFood.quantity + 1
		else
			-- Add new food type
			table.insert(playerData.selectedFoods, {food = food, quantity = 1})
		end

		-- Update totals
		playerData.budget = playerData.budget - food.cost
		playerData.totalCost = playerData.totalCost + food.cost
		playerData.totalItems = playerData.totalItems + 1

		-- Update button display (show quantity)
		local quantity = button:GetAttribute("Quantity") + 1
		button:SetAttribute("Quantity", quantity)

		-- Enhanced button text showing quantity
		if quantity > 1 then
			button.Text = food.emoji .. " " .. food.name .. " x" .. quantity .. "\n$" .. food.cost .. " - " .. food.damage .. " DMG"
		else
			button.Text = food.emoji .. " " .. food.name .. "\n$" .. food.cost .. " - " .. food.damage .. " DMG"
		end

		-- Change color to show it's selected but keep it clickable
		button.BackgroundColor3 = Color3.fromRGB(0, 120, 200) -- Blue-green to show selection

		-- Update UI
		updateSelectionUI()

		-- Success sound effect (flash green)
		flashButton(button, Color3.fromRGB(0, 255, 0))

		print("✅ [FOOD SELECTION] Selected " .. food.name .. " (Quantity: " .. quantity .. ") Budget remaining: $" .. playerData.budget)
	else
		print("❌ [FOOD SELECTION] Cannot afford " .. food.name .. "! Budget: $" .. playerData.budget .. ", Cost: $" .. food.cost)

		-- Flash the button red
		flashButton(button, Color3.fromRGB(255, 0, 0))

		-- Disable glow for unaffordable items
		local glowTween = uiReferences.glowTweens[food.name]
		if glowTween then
			glowTween:Cancel()
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Grayed out
		end
	end
end

-- Enhanced UI updates
function updateSelectionUI()
	-- Update budget label with color coding
	if uiReferences.budgetLabel then
		uiReferences.budgetLabel.Text = "💰 Budget: $" .. playerData.budget .. " / $" .. STARTING_BUDGET

		if playerData.budget <= 0 then
			uiReferences.budgetLabel.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Red
		elseif playerData.budget <= 3 then
			uiReferences.budgetLabel.BackgroundColor3 = Color3.fromRGB(200, 150, 0) -- Orange
		else
			uiReferences.budgetLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Green
		end
	end

	-- Enhanced tray label showing quantities
	if uiReferences.trayLabel then
		if #playerData.selectedFoods > 0 then
			local trayText = "🎒 Arsenal: "
			for i, selectedFood in ipairs(playerData.selectedFoods) do
				if selectedFood.quantity > 1 then
					trayText = trayText .. selectedFood.food.emoji .. selectedFood.food.name .. " x" .. selectedFood.quantity
				else
					trayText = trayText .. selectedFood.food.emoji .. selectedFood.food.name
				end
				if i < #playerData.selectedFoods then
					trayText = trayText .. ", "
				end
			end
			trayText = trayText .. " (" .. playerData.totalItems .. " items, $" .. playerData.totalCost .. ")"
			uiReferences.trayLabel.Text = trayText
		else
			uiReferences.trayLabel.Text = "🎒 Arsenal: Empty"
		end
	end

	-- Update ready button state with enhanced styling
	if uiReferences.readyButton then
		if #playerData.selectedFoods > 0 then
			uiReferences.readyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Bright green
			uiReferences.readyButton.Text = "🚀 ENTER BATTLE! (" .. playerData.totalItems .. " items)"
			uiReferences.readyButton.Active = true
		else
			uiReferences.readyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Gray
			uiReferences.readyButton.Text = "🚀 ENTER BATTLE!"
			uiReferences.readyButton.Active = false
		end
	end

	-- Update food button affordability
	for foodName, button in pairs(uiReferences.foodButtons) do
		local cost = button:GetAttribute("FoodCost")
		local glowTween = uiReferences.glowTweens[foodName]

		if playerData.budget >= cost then
			-- Can afford - enable glow
			if glowTween and glowTween.PlaybackState == Enum.PlaybackState.Cancelled then
				glowTween:Play()
			end
		else
			-- Cannot afford - disable glow and gray out
			if glowTween then
				glowTween:Cancel()
			end
			if button:GetAttribute("Quantity") == 0 then
				button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			end
		end
	end
end

-- Enhanced finish selection
function finishSelection()
	print("🔧 [FOOD SELECTION] Finishing enhanced food selection...")

	if #playerData.selectedFoods == 0 then
		warn("⚠️ [FOOD SELECTION] No foods selected! Please select at least one food.")
		return
	end

	-- Clean up existing PlayerFoods folder
	local existingFolder = player:FindFirstChild("PlayerFoods")
	if existingFolder then
		existingFolder:Destroy()
	end

	-- Create PlayerFoods folder for the throwing system
	local playerFoodsFolder = Instance.new("Folder")
	playerFoodsFolder.Name = "PlayerFoods"
	playerFoodsFolder.Parent = player

	-- Add selected foods to the folder (including quantities)
	local itemIndex = 1
	for _, selectedFood in ipairs(playerData.selectedFoods) do
		for quantity = 1, selectedFood.quantity do
			local foodValue = Instance.new("StringValue")
			foodValue.Name = "Food_" .. itemIndex
			foodValue.Value = selectedFood.food.name

			-- Store additional food data as attributes
			foodValue:SetAttribute("Emoji", selectedFood.food.emoji)
			foodValue:SetAttribute("Cost", selectedFood.food.cost)
			foodValue:SetAttribute("Damage", selectedFood.food.damage)

			foodValue.Parent = playerFoodsFolder
			itemIndex = itemIndex + 1
		end
	end

	print("✅ [FOOD SELECTION] Created PlayerFoods folder with " .. playerData.totalItems .. " items")

	-- Enhanced fade out effect
	if uiReferences.screenGui then
		local fadeOut = TweenService:Create(
			uiReferences.screenGui,
			TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Enabled = false
			}
		)

		-- Scale down effect
		local scaleDown = TweenService:Create(
			uiReferences.mainFrame,
			TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0)
			}
		)

		fadeOut:Play()
		scaleDown:Play()

		fadeOut.Completed:Connect(function()
			uiReferences.screenGui:Destroy()
			print("🔧 [FOOD SELECTION] Enhanced selection UI removed")
		end)
	end

	-- Notify server that player is ready
	safeFireRemoteEvent("PlayerReady", true)

	print("✅ [FOOD SELECTION] Enhanced food selection complete! Ready to fight!")
end

-- Initialize when player spawns
local function initializeFoodSelection()
	print("🔧 [FOOD SELECTION] Initializing Enhanced Food Selection System...")

	waitForModules()
	task.wait(1)

	local success, result = pcall(createFoodSelectionUI)

	if success then
		print("✅ [FOOD SELECTION] Enhanced Food Selection UI created successfully!")
	else
		warn("❌ [FOOD SELECTION] Failed to create Enhanced Food Selection UI: " .. tostring(result))
	end
end

-- Start the system
if player.Character then
	initializeFoodSelection()
else
	player.CharacterAdded:Connect(function(character)
		print("🔧 [FOOD SELECTION] Character spawned, waiting for full load...")
		task.wait(2)
		initializeFoodSelection()
	end)
end

print("✅ [FOOD SELECTION] Enhanced Food Selection System loaded!")
