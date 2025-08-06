-- Baseplate
-- Creates a simple baseplate

print("BASEPLATE SCRIPT STARTING")

-- Create a simple baseplate
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Size = Vector3.new(100, 1, 100)
baseplate.Position = Vector3.new(0, 0, 0)
baseplate.Material = Enum.Material.Grass
baseplate.BrickColor = BrickColor.new("Bright green")
baseplate.Anchored = true
baseplate.Parent = workspace

print("BASEPLATE CREATED") 