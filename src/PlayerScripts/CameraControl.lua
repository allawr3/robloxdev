-- Food Fighter - Client Camera Control
-- Place this in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Camera configuration
local CAMERA_HEIGHT = 45
local CAMERA_DISTANCE = 25
local CAMERA_SMOOTH_SPEED = 0.1
local ZOOM_SPEED = 5
local MIN_ZOOM = 35
local MAX_ZOOM = 60

-- Camera state
local cameraState = {
	currentHeight = CAMERA_HEIGHT,
	targetHeight = CAMERA_HEIGHT,
	isLocked = true,
	chairPosition = nil,
	chairAngle = 0
}

-- Wait for game data to load
local function waitForGameData()
	local chairPositions = ReplicatedStorage:WaitForChild("ChairPositions")
	return chairPositions
end

-- Find player's assigned chair
local function findPlayerChair()
	local chairPositions = waitForGameData()

	-- In a real game, this would come from the server
	-- For now, assign based on join order
	local players = Players:GetPlayers()
	local playerIndex = 1

	for i, p in pairs(players) do
		if p == player then
			playerIndex = i
			break
		end
	end

	local chairName = "Chair_" .. playerIndex
	local chairPosValue = chairPositions:FindFirstChild(chairName)

	if chairPosValue then
		cameraState.chairPosition = chairPosValue.Value
		-- Calculate angle facing center
		local centerPos = Vector3.new(0, 0, 0)
		local direction = (centerPos - cameraState.chairPosition).Unit
		cameraState.chairAngle = math.atan2(direction.Z, direction.X)

		print("Player assigned to " .. chairName .. " at position " .. tostring(cameraState.chairPosition))
		return true
	end

	return false
end

-- Update camera position smoothly
local function updateCamera()
	if not cameraState.chairPosition then return end

	-- Smooth height adjustment
	cameraState.currentHeight = cameraState.currentHeight + 
		(cameraState.targetHeight - cameraState.currentHeight) * CAMERA_SMOOTH_SPEED

	-- Calculate camera position above the table, slightly offset towards player's chair
	local offsetX = math.cos(cameraState.chairAngle) * 8
	local offsetZ = math.sin(cameraState.chairAngle) * 8

	local cameraPosition = Vector3.new(
		offsetX,
		cameraState.currentHeight,
		offsetZ
	)

	local lookAtPosition = Vector3.new(0, 2, 0) -- Center of table

	-- Apply camera transform
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.lookAt(cameraPosition, lookAtPosition)
	camera.FieldOfView = 75
end

-- Handle zoom input
local function handleZoom(input, gameProcessed)
	if gameProcessed then return end

	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local zoomDelta = input.Position.Z * ZOOM_SPEED
		cameraState.targetHeight = math.clamp(
			cameraState.targetHeight + zoomDelta,
			MIN_ZOOM,
			MAX_ZOOM
		)
	end
end

-- Handle camera lock toggle
local function handleCameraLock(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.C then
		cameraState.isLocked = not cameraState.isLocked
		print("Camera lock: " .. (cameraState.isLocked and "ON" or "OFF"))
	end
end

-- Initialize camera system
local function initializeCamera()
	print("Initializing Camera Control...")

	-- Wait for character to spawn
	if not player.Character then
		player.CharacterAdded:Wait()
	end

	-- Wait for game data
	wait(2)

	-- Find player's chair
	if findPlayerChair() then
		-- Connect input events
		UserInputService.InputChanged:Connect(handleZoom)
		UserInputService.InputBegan:Connect(handleCameraLock)

		-- Start camera update loop
		RunService.Heartbeat:Connect(updateCamera)

		print("Camera Control initialized successfully!")
	else
		print("Failed to find player chair - camera control disabled")
	end
end

-- Start the camera system
spawn(initializeCamera)

print("Camera Control script loaded!") 