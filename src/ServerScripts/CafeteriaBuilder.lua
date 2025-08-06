-- Food Fighter - Cafeteria Builder (Step 1: Simplified - 1 Door + 1 Window)
-- Place this in ServerScriptService/CafeteriaBuilder.lua

print("🏗️ Starting Cafeteria Construction - Step 1: Simplified Structure")

-- Configuration
local CAFETERIA_SIZE = 100
local WALL_HEIGHT = 12
local WALL_THICKNESS = 1
local FLOOR_HEIGHT = 0.5

-- Create main cafeteria model container
local function createCafeteriaModel()
	local cafeteriaModel = Instance.new("Model")
	cafeteriaModel.Name = "SchoolCafeteria"
	cafeteriaModel.Parent = workspace
	return cafeteriaModel
end

-- Create the cafeteria floor
local function createCafeteriaFloor(parent)
	local floor = Instance.new("Part")
	floor.Name = "CafeteriaFloor"
	floor.Size = Vector3.new(CAFETERIA_SIZE, FLOOR_HEIGHT, CAFETERIA_SIZE)
	floor.Position = Vector3.new(0, FLOOR_HEIGHT/2, 0)
	floor.Material = Enum.Material.Plastic
	floor.BrickColor = BrickColor.new("Light gray")
	floor.Anchored = true
	floor.CanCollide = true
	floor.Parent = parent

	print("✅ Cafeteria floor created: " .. CAFETERIA_SIZE .. "×" .. CAFETERIA_SIZE)
	return floor
end

-- Create north wall (solid)
local function createNorthWall(parent)
	local northWall = Instance.new("Part")
	northWall.Name = "NorthWall"
	northWall.Size = Vector3.new(CAFETERIA_SIZE, WALL_HEIGHT, WALL_THICKNESS)
	northWall.Position = Vector3.new(0, WALL_HEIGHT/2, CAFETERIA_SIZE/2)
	northWall.Material = Enum.Material.Concrete
	northWall.BrickColor = BrickColor.new("Brick yellow")
	northWall.Anchored = true
	northWall.CanCollide = true
	northWall.Parent = parent

	print("✅ North wall created (solid)")
	return northWall
end

-- Create south wall (solid)
local function createSouthWall(parent)
	local southWall = Instance.new("Part")
	southWall.Name = "SouthWall"
	southWall.Size = Vector3.new(CAFETERIA_SIZE, WALL_HEIGHT, WALL_THICKNESS)
	southWall.Position = Vector3.new(0, WALL_HEIGHT/2, -CAFETERIA_SIZE/2)
	southWall.Material = Enum.Material.Concrete
	southWall.BrickColor = BrickColor.new("Brick yellow")
	southWall.Anchored = true
	southWall.CanCollide = true
	southWall.Parent = parent

	print("✅ South wall created (solid)")
	return southWall
end

-- Create west wall with door opening
local function createWestWallWithDoor(parent)
	local wallParts = {}

	-- Bottom section (below door)
	local bottomWall = Instance.new("Part")
	bottomWall.Name = "WestWall_Bottom"
	bottomWall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, 35)
	bottomWall.Position = Vector3.new(-CAFETERIA_SIZE/2, WALL_HEIGHT/2, -32.5)
	bottomWall.Material = Enum.Material.Concrete
	bottomWall.BrickColor = BrickColor.new("Brick yellow")
	bottomWall.Anchored = true
	bottomWall.CanCollide = true
	bottomWall.Parent = parent
	table.insert(wallParts, bottomWall)

	-- Top section (above door)
	local topWall = Instance.new("Part")
	topWall.Name = "WestWall_Top"
	topWall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, 35)
	topWall.Position = Vector3.new(-CAFETERIA_SIZE/2, WALL_HEIGHT/2, 32.5)
	topWall.Material = Enum.Material.Concrete
	topWall.BrickColor = BrickColor.new("Brick yellow")
	topWall.Anchored = true
	topWall.CanCollide = true
	topWall.Parent = parent
	table.insert(wallParts, topWall)

	-- Door in the middle gap
	local door = Instance.new("Part")
	door.Name = "MainDoor"
	door.Size = Vector3.new(WALL_THICKNESS + 0.2, 10, 20)
	door.Position = Vector3.new(-CAFETERIA_SIZE/2, 5, 0)
	door.Material = Enum.Material.Wood
	door.BrickColor = BrickColor.new("Brown")
	door.Anchored = true
	door.CanCollide = false -- Players can walk through
	door.Parent = parent
	table.insert(wallParts, door)

	-- Door frame
	local doorFrame = Instance.new("Part")
	doorFrame.Name = "DoorFrame"
	doorFrame.Size = Vector3.new(WALL_THICKNESS + 0.4, 11, 21)
	doorFrame.Position = Vector3.new(-CAFETERIA_SIZE/2, 5.5, 0)
	doorFrame.Material = Enum.Material.Plastic
	doorFrame.BrickColor = BrickColor.new("Really red") -- Bright for visibility
	doorFrame.Anchored = true
	doorFrame.CanCollide = false
	doorFrame.Parent = parent
	table.insert(wallParts, doorFrame)

	print("✅ West wall created with door opening")
	return wallParts
end

-- Create east wall with window opening
local function createEastWallWithWindow(parent)
	local wallParts = {}

	-- Bottom section (below window)
	local bottomWall = Instance.new("Part")
	bottomWall.Name = "EastWall_Bottom"
	bottomWall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, 40)
	bottomWall.Position = Vector3.new(CAFETERIA_SIZE/2, WALL_HEIGHT/2, -30)
	bottomWall.Material = Enum.Material.Concrete
	bottomWall.BrickColor = BrickColor.new("Brick yellow")
	bottomWall.Anchored = true
	bottomWall.CanCollide = true
	bottomWall.Parent = parent
	table.insert(wallParts, bottomWall)

	-- Top section (above window)
	local topWall = Instance.new("Part")
	topWall.Name = "EastWall_Top"
	topWall.Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, 40)
	topWall.Position = Vector3.new(CAFETERIA_SIZE/2, WALL_HEIGHT/2, 30)
	topWall.Material = Enum.Material.Concrete
	topWall.BrickColor = BrickColor.new("Brick yellow")
	topWall.Anchored = true
	topWall.CanCollide = true
	topWall.Parent = parent
	table.insert(wallParts, topWall)

	-- Window in the middle gap
	local window = Instance.new("Part")
	window.Name = "MainWindow"
	window.Size = Vector3.new(WALL_THICKNESS + 0.2, 8, 15)
	window.Position = Vector3.new(CAFETERIA_SIZE/2, WALL_HEIGHT/2 + 1, 0)
	window.Material = Enum.Material.ForceField
	window.BrickColor = BrickColor.new("Bright blue")
	window.Transparency = 0.3
	window.Anchored = true
	window.CanCollide = false
	window.Parent = parent
	table.insert(wallParts, window)

	-- Window frame
	local windowFrame = Instance.new("Part")
	windowFrame.Name = "WindowFrame"
	windowFrame.Size = Vector3.new(WALL_THICKNESS + 0.4, 9, 16)
	windowFrame.Position = Vector3.new(CAFETERIA_SIZE/2, WALL_HEIGHT/2 + 1, 0)
	windowFrame.Material = Enum.Material.Plastic
	windowFrame.BrickColor = BrickColor.new("White")
	windowFrame.Anchored = true
	windowFrame.CanCollide = false
	windowFrame.Parent = parent
	table.insert(wallParts, windowFrame)

	print("✅ East wall created with window opening")
	return wallParts
end

-- Create basic ambient lighting
local function createCafeteriaLighting(parent)
	local lightHolder = Instance.new("Part")
	lightHolder.Name = "LightHolder"
	lightHolder.Size = Vector3.new(1, 1, 1)
	lightHolder.Position = Vector3.new(0, WALL_HEIGHT + 2, 0)
	lightHolder.Transparency = 1
	lightHolder.Anchored = true
	lightHolder.CanCollide = false
	lightHolder.Parent = parent

	local mainLight = Instance.new("SpotLight")
	mainLight.Name = "MainCafeteriaLight"
	mainLight.Brightness = 2
	mainLight.Range = 80
	mainLight.Angle = 120
	mainLight.Color = Color3.new(1, 1, 0.9)
	mainLight.Face = Enum.NormalId.Bottom
	mainLight.Parent = lightHolder

	print("✅ Cafeteria lighting setup complete")
	return mainLight
end

-- Main construction function
local function buildSimpleCafeteria()
	print("🏗️ Building simplified cafeteria (1 door + 1 window)...")

	-- Remove any existing cafeteria
	local existing = workspace:FindFirstChild("SchoolCafeteria")
	if existing then
		existing:Destroy()
		print("🧹 Removed existing cafeteria")
	end

	-- Create main model
	local cafeteria = createCafeteriaModel()

	-- Build components
	createCafeteriaFloor(cafeteria)
	createNorthWall(cafeteria)          -- Solid wall
	createSouthWall(cafeteria)          -- Solid wall
	createWestWallWithDoor(cafeteria)   -- Door opening
	createEastWallWithWindow(cafeteria) -- Window opening
	createCafeteriaLighting(cafeteria)

	print("🎉 Simplified cafeteria complete!")
	print("📐 Size: " .. CAFETERIA_SIZE .. "×" .. CAFETERIA_SIZE .. " studs")
	print("🚪 Door: West wall (brown with red frame)")
	print("🪟 Window: East wall (blue with white frame)")
	print("💡 Lighting: Overhead spotlight")

	return cafeteria
end

-- Initialize the cafeteria
local cafeteria = buildSimpleCafeteria()

-- Export for other scripts to use
_G.SchoolCafeteria = cafeteria

print("✅ Simplified CafeteriaBuilder Step 1 complete!")