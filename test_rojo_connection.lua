-- Test Rojo Connection Script
-- Place this in a Script in Roblox Studio to test the connection

local HttpService = game:GetService("HttpService")

-- Test connection to Rojo server
local success, result = pcall(function()
    local response = HttpService:GetAsync("http://localhost:34872/api/rojo")
    return HttpService:JSONDecode(response)
end)

if success then
    print("✅ Rojo connection successful!")
    print("Session ID: " .. result.sessionId)
    print("Server Version: " .. result.serverVersion)
    print("Project Name: " .. result.projectName)
    
    -- Now you can manually sync files
    print("🔄 Ready to sync Food Fighter files!")
else
    print("❌ Rojo connection failed: " .. tostring(result))
end 