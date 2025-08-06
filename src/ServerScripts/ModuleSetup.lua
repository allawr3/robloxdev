-- =============================================================================
-- REPLACE YOUR ENTIRE ModuleSetup.lua FILE WITH THIS CODE
-- =============================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🔧 Starting FIXED Module Setup...")

-- Create Modules folder if it doesn't exist
local modulesFolder = ReplicatedStorage:FindFirstChild("Modules")
if not modulesFolder then
    modulesFolder = Instance.new("Folder")
    modulesFolder.Name = "Modules"
    modulesFolder.Parent = ReplicatedStorage
    print("✅ Created Modules folder")
else
    print("✅ Modules folder exists")
end

-- Create RemoteEvents folder if it doesn't exist
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
    remoteEventsFolder = Instance.new("Folder")
    remoteEventsFolder.Name = "RemoteEvents"
    remoteEventsFolder.Parent = ReplicatedStorage
    print("✅ Created RemoteEvents folder")
else
    print("✅ RemoteEvents folder exists")
end

-- Create essential RemoteEvents (only if they don't exist)
local remoteEvents = {
    "ScreenShakeEvent",
    "MatchStateChanged",
    "PlayerReady", 
    "ScoreUpdate",
    "TimerUpdate",
    "MatchResults"
}

for _, eventName in pairs(remoteEvents) do
    if not remoteEventsFolder:FindFirstChild(eventName) then
        local remoteEvent = Instance.new("RemoteEvent")
        remoteEvent.Name = eventName
        remoteEvent.Parent = remoteEventsFolder
        print("✅ Created RemoteEvent: " .. eventName)
    else
        print("✅ RemoteEvent exists: " .. eventName)
    end
end

-- Verify modules exist (Rojo should have created them)
local modules = {
    "FoodPhysics",
    "FoodSounds", 
    "FoodParticles",
    "FoodScoring",
    "FoodCollision"
}

for _, moduleName in pairs(modules) do
    local module = modulesFolder:FindFirstChild(moduleName)
    if module then
        print("✅ Module verified: " .. moduleName)
    else
        print("⚠️ Module missing: " .. moduleName .. " (should be created by Rojo)")
    end
end

print("🎯 FIXED Module Setup Complete!")

-- =============================================================================
-- NO MORE DYNAMIC SOURCE CREATION - ROJO HANDLES THE MODULES
-- ============================================================================= 