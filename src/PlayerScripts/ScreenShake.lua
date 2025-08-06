-- ScreenShake.lua - FIXED VERSION
-- Place this in StarterPlayer/StarterPlayerScripts/

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Wait for RemoteEvents folder and ScreenShakeEvent
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
if not remoteEventsFolder then
	warn("RemoteEvents folder not found - ScreenShake disabled")
	return
end

local screenShakeEvent = remoteEventsFolder:WaitForChild("ScreenShakeEvent", 5)
if not screenShakeEvent then
	warn("ScreenShakeEvent not found - ScreenShake disabled")
	return
end

local isShaking = false
local shakeConnection = nil

local function shakeScreen(intensity, duration)
	if isShaking then return end -- Prevent multiple shakes

	intensity = intensity or 2
	duration = duration or 0.5
	isShaking = true

	local startTime = tick()
	local originalCFrame = camera.CFrame

	shakeConnection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime

		if elapsed >= duration then
			-- Stop shaking
			if shakeConnection then
				shakeConnection:Disconnect()
				shakeConnection = nil
			end

			-- Smooth return to original position
			local resetTween = TweenService:Create(camera,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{CFrame = originalCFrame}
			)
			resetTween:Play()

			resetTween.Completed:Connect(function()
				isShaking = false
			end)
			return
		end

		-- Calculate shake intensity (fade out over time)
		local currentIntensity = intensity * (1 - (elapsed / duration))

		-- Generate random offset
		local randomOffset = Vector3.new(
			(math.random() - 0.5) * currentIntensity,
			(math.random() - 0.5) * currentIntensity,
			(math.random() - 0.5) * currentIntensity
		)

		camera.CFrame = originalCFrame + randomOffset
	end)
end

screenShakeEvent.OnClientEvent:Connect(shakeScreen)

print("✅ Screen Shake system loaded!") 