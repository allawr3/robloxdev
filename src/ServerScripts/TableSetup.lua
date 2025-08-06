-- Food Fighter - Table Setup with Fixed Orientation & Seat Locking
-- Place this in ServerScriptService

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local MAX_PLAYERS = 4
local TABLE_SIZE = 24
local CHAIR_HEIGHT = 4
local CAMERA_HEIGHT = 50
local CAMERA_ANGLE = math.rad(-75) -- Looking down at 75 degrees

-- Create main table structure
local function createMainTable()
	local tableModel = Instance.new("Model")
	tableModel.Name = "MainTable"
	tableModel.Parent = workspace

	-- Simple square table
	local tablePart = Instance.new("Part")
	tablePart.Name = "TableSurface"
	tablePart.Size = Vector3.new(TABLE_SIZE, 1, TABLE_SIZE)
	tablePart.Position = Vector3.new(0, 2, 0)
	tablePart.Shape = Enum.PartType.Block
	tablePart.Material = Enum.Material.Wood
	tablePart.BrickColor = BrickColor.new("Brown")
	tablePart.Anchored = true
	tablePart.CanCollide = true
	tablePart.TopSurface = Enum.SurfaceType.Smooth
	tablePart.Parent = tableModel

	return tableModel
end

-- Create player chairs around the table
local function createPlayerChairs(numPlayers)
	local chairsModel = Instance.new("Model")
	chairsModel.Name = "PlayerChairs"
	chairsModel.Parent = workspace

	local chairs = {}

	-- Chair positions for 4 players (North, East, South, West)
	local chairPositions = {
		{x = 0, z = TABLE_SIZE/2 + 4},     -- North
		{x = TABLE_SIZE/2 + 4, z = 0},     -- East  
		{x = 0, z = -(TABLE_SIZE/2 + 4)},  -- South
		{x = -(TABLE_SIZE/2 + 4), z = 0}   -- West
	}

	for i = 1, numPlayers do
		local pos = chairPositions[i]

		-- Chair seat
		local chairSeat = Instance.new("Seat")
		chairSeat.Name = "Chair_" .. i
		chairSeat.Size = Vector3.new(4, 1, 4)
		chairSeat.Position = Vector3.new(pos.x, CHAIR_HEIGHT, pos.z)
		chairSeat.Material = Enum.Material.Plastic
		chairSeat.BrickColor = BrickColor.new("Bright red")
		chairSeat.Anchored = true
		chairSeat.Parent = chairsModel

		-- SIMPLIFIED: Let the setupPlayerSeating handle all orientation
		-- Don't rotate the seat itself, just position it
		chairSeat.Rotation = Vector3.new(0, 0, 0)

		-- Chair back (positioned away from table)
		local chairBack = Instance.new("Part")
		chairBack.Name = "ChairBack_" .. i
		chairBack.Size = Vector3.new(4, 5, 0.5)
		chairBack.Material = Enum.Material.Plastic
		chairBack.BrickColor = BrickColor.new("Bright red")
		chairBack.Anchored = true
		chairBack.Parent = chairsModel

		-- Position chair backs away from table (behind the seat)
		if i == 1 then -- North chair - back goes north (away from table)
			chairBack.Position = Vector3.new(pos.x, CHAIR_HEIGHT + 2.5, pos.z + 2.25)
		elseif i == 2 then -- East chair - back goes east (away from table)
			chairBack.Position = Vector3.new(pos.x + 2.25, CHAIR_HEIGHT + 2.5, pos.z)
			chairBack.Size = Vector3.new(0.5, 5, 4)
		elseif i == 3 then -- South chair - back goes south (away from table)
			chairBack.Position = Vector3.new(pos.x, CHAIR_HEIGHT + 2.5, pos.z - 2.25)
		else -- West chair - back goes west (away from table)
			chairBack.Position = Vector3.new(pos.x - 2.25, CHAIR_HEIGHT + 2.5, pos.z)
			chairBack.Size = Vector3.new(0.5, 5, 4)
		end

		-- Store chair data with proper angles for facing table center
		chairs[i] = {
			seat = chairSeat,
			position = Vector3.new(pos.x, CHAIR_HEIGHT, pos.z),
			-- FIXED: Calculate angle to face table center
			angle = math.atan2(0 - pos.z, 0 - pos.x), -- Angle pointing toward (0,0)
			occupied = false,
			player = nil,
			playerConnection = nil -- Store connection for cleanup
		}
	end

	return chairs
end

-- Lock player in seat and restrict movement
local function lockPlayerInSeat(player, chairData)
	if not player.Character then return end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart then return end

	-- Force sit and disable jumping/moving horizontally
	humanoid.Sit = true
	humanoid.PlatformStand = true -- Prevents getting up

	-- Create invisible walls around the chair to prevent movement
	local function createInvisibleWall(position, size)
		local wall = Instance.new("Part")
		wall.Name = "ChairWall"
		wall.Size = size
		wall.Position = position
		wall.Anchored = true
		wall.CanCollide = true
		wall.Transparency = 1 -- Invisible
		wall.Parent = chairData.seat
		return wall
	end

	-- Create walls around the chair
	local chairPos = chairData.position
	createInvisibleWall(Vector3.new(chairPos.X + 3, chairPos.Y + 2, chairPos.Z), Vector3.new(1, 4, 6)) -- Right wall
	createInvisibleWall(Vector3.new(chairPos.X - 3, chairPos.Y + 2, chairPos.Z), Vector3.new(1, 4, 6)) -- Left wall
	createInvisibleWall(Vector3.new(chairPos.X, chairPos.Y + 2, chairPos.Z + 3), Vector3.new(6, 4, 1)) -- Front wall
	createInvisibleWall(Vector3.new(chairPos.X, chairPos.Y + 2, chairPos.Z - 3), Vector3.new(6, 4, 1)) -- Back wall

	-- Override player movement - only allow jumping (Y movement)
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.MaxForce = Vector3.new(4000, 0, 4000) -- Lock X and Z, allow Y
	bodyPosition.Position = Vector3.new(chairPos.X, chairPos.Y + 1, chairPos.Z)
	bodyPosition.Parent = rootPart

	-- Allow jumping by monitoring input
	local function onJumpRequest()
		if humanoid.Jump then
			bodyPosition.MaxForce = Vector3.new(4000, 0, 4000) -- Temporarily allow Y movement
			wait(0.5) -- Allow jump duration
			bodyPosition.MaxForce = Vector3.new(4000, 0, 4000) -- Restore X,Z lock
		end
	end

	-- Connect jump monitoring
	local jumpConnection = humanoid.Changed:Connect(function(property)
		if property == "Jump" then
			onJumpRequest()
		end
	end)

	-- Store connection for cleanup
	chairData.playerConnection = jumpConnection

	print("🔒 " .. player.Name .. " locked in seat - can only jump!")
end

-- Setup player seating with FIXED orientation
local function setupPlayerSeating(player, chairPosition, chairAngle, chairSeat)
	if not player.Character then return end

	local humanoid = player.Character:FindFirstChild("Humanoid")
	local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart then return end

	-- MAJOR FIX: Use direct angle calculation to face table center
	local tableCenter = Vector3.new(0, chairPosition.Y, 0)
	local direction = (tableCenter - chairPosition).Unit
	local faceTableAngle = math.atan2(-direction.X, -direction.Z)

	-- Position and orient player to face table center
	rootPart.CFrame = CFrame.new(chairPosition + Vector3.new(0, 1, 0)) * CFrame.Angles(0, faceTableAngle, 0)

	-- Force sit in chair
	humanoid.Sit = true

	-- Wait and verify sitting
	wait(0.2)
	if not humanoid.Sit then
		humanoid.Sit = true
		wait(0.1)
	end

	print("✅ " .. player.Name .. " positioned facing table center (angle: " .. math.deg(faceTableAngle) .. "°)")
end

-- Player management
local gameData = {
	chairs = {},
	activePlayers = {},
	gameActive = false,
	gameStarted = false
}

-- Handle player joining
local function onPlayerAdded(player)
	-- Find available chair
	local availableChair = nil
	for i, chair in pairs(gameData.chairs) do
		if not chair.occupied then
			availableChair = chair
			break
		end
	end

	if availableChair then
		availableChair.occupied = true
		availableChair.player = player
		gameData.activePlayers[player] = availableChair

		-- Setup player seating with correct orientation
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			setupPlayerSeating(player, availableChair.position, availableChair.angle, availableChair.seat)

			-- Lock player in seat if game has started
			if gameData.gameStarted then
				lockPlayerInSeat(player, availableChair)
			end
		else
			player.CharacterAdded:Connect(function(character)
				wait(1) -- Give time for character to fully load
				setupPlayerSeating(player, availableChair.position, availableChair.angle, availableChair.seat)

				-- Lock player in seat if game has started
				if gameData.gameStarted then
					lockPlayerInSeat(player, availableChair)
				end
			end)
		end

		print(player.Name .. " assigned to chair table: " .. tostring(availableChair))
	else
		print("No available chairs for " .. player.Name)
	end
end

-- Handle player leaving
local function onPlayerRemoving(player)
	local chairData = gameData.activePlayers[player]
	if chairData then
		-- Clean up movement restrictions
		if chairData.playerConnection then
			chairData.playerConnection:Disconnect()
		end

		-- Remove invisible walls
		if chairData.seat then
			for _, wall in pairs(chairData.seat:GetChildren()) do
				if wall.Name == "ChairWall" then
					wall:Destroy()
				end
			end
		end

		chairData.occupied = false
		chairData.player = nil
		chairData.playerConnection = nil
		gameData.activePlayers[player] = nil
		print(player.Name .. " left their chair")
	end
end

-- Function to start game and lock all players
local function startGameLockdown()
	gameData.gameStarted = true
	print("🔒 Game started - locking all players in seats!")

	-- Lock all currently seated players
	for player, chairData in pairs(gameData.activePlayers) do
		if chairData and chairData.occupied then
			lockPlayerInSeat(player, chairData)
		end
	end
end

-- Function to end game and unlock players
local function endGameUnlock()
	gameData.gameStarted = false
	print("🔓 Game ended - players can move freely!")

	-- Unlock all players
	for player, chairData in pairs(gameData.activePlayers) do
		if chairData and chairData.player and chairData.player.Character then
			local humanoid = chairData.player.Character:FindFirstChild("Humanoid")
			local rootPart = chairData.player.Character:FindFirstChild("HumanoidRootPart")

			if humanoid then
				humanoid.PlatformStand = false
				humanoid.Sit = false
			end

			-- Remove body position constraint
			if rootPart then
				local bodyPos = rootPart:FindFirstChild("BodyPosition")
				if bodyPos then bodyPos:Destroy() end
			end

			-- Clean up connections
			if chairData.playerConnection then
				chairData.playerConnection:Disconnect()
				chairData.playerConnection = nil
			end

			-- Remove walls
			for _, wall in pairs(chairData.seat:GetChildren()) do
				if wall.Name == "ChairWall" then
					wall:Destroy()
				end
			end
		end
	end
end

-- Initialize the game
local function initializeGame()
	print("Initializing Food Fighter...")

	-- Create table and chairs
	createMainTable()
	gameData.chairs = createPlayerChairs(MAX_PLAYERS)

	-- Connect player events
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	-- Handle existing players
	for _, player in pairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end

	print("Food Fighter initialized with " .. MAX_PLAYERS .. " chairs")

	-- Export game data for other scripts
	local gameDataValue = Instance.new("ObjectValue")
	gameDataValue.Name = "GameData"
	gameDataValue.Parent = ReplicatedStorage

	-- Store chair positions for client scripts
	local chairPositions = Instance.new("Folder")
	chairPositions.Name = "ChairPositions"
	chairPositions.Parent = ReplicatedStorage

	for i, chair in pairs(gameData.chairs) do
		local posValue = Instance.new("Vector3Value")
		posValue.Name = "Chair_" .. i
		posValue.Value = chair.position
		posValue.Parent = chairPositions
	end

	-- Export control functions
	_G.FoodFighterGame = {
		startGameLockdown = startGameLockdown,
		endGameUnlock = endGameUnlock,
		isGameStarted = function() return gameData.gameStarted end
	}
end

-- Start the game
initializeGame()

-- Connect to MatchManager for automatic locking
spawn(function()
	wait(2) -- Wait for MatchManager to load
	if _G.MatchManager then
		print("TableSetup connected to MatchManager")

		-- Auto-lock players when combat starts
		local lastState = "Waiting"
		spawn(function()
			while true do
				if _G.MatchManager then
					local matchInfo = _G.MatchManager.getMatchInfo()
					if matchInfo.state ~= lastState then
						lastState = matchInfo.state

						if matchInfo.state == "Combat" then
							startGameLockdown()
						elseif matchInfo.state == "Results" or matchInfo.state == "Waiting" then
							endGameUnlock()
						end

						-- Change table color based on match state
						local tablePart = workspace:FindFirstChild("MainTable"):FindFirstChild("TableSurface")
						if tablePart then
							if matchInfo.state == "Combat" then
								tablePart.BrickColor = BrickColor.new("Bright red") -- Combat mode
							elseif matchInfo.state == "Selection" then
								tablePart.BrickColor = BrickColor.new("Bright yellow") -- Selection mode
							else
								tablePart.BrickColor = BrickColor.new("Brown") -- Default
							end
						end
					end
				end
				wait(1)
			end
		end)
	else
		-- Manual testing: start lockdown after 10 seconds
		wait(10)
		print("⏰ Auto-starting game lockdown for testing...")
		startGameLockdown()
	end
end)