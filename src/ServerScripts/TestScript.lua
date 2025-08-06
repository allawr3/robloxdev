-- TestScript
-- Simple test to verify server scripts are running

print("=== TEST SCRIPT STARTING ===")

-- Create a simple part
local part = Instance.new("Part")
part.Name = "TestPart"
part.Size = Vector3.new(10, 10, 10)
part.Position = Vector3.new(0, 20, 0)
part.BrickColor = BrickColor.new("Really red")
part.Anchored = true
part.Parent = workspace

print("=== TEST PART CREATED ===")
print("=== TEST SCRIPT COMPLETE ===") 