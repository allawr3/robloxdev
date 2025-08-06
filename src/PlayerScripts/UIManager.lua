-- Food Fighter - UI Manager (Client-side)
-- Place this in StarterPlayer/StarterPlayerScripts/UIManager

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- Wait for remote events
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local matchStateEvent = remoteEvents:WaitForChild("MatchStateChanged")
local timerUpdateEvent = remoteEvents:WaitForChild("TimerUpdate")
local matchResultsEvent = remoteEvents:WaitForChild("MatchResults")
local playerReadyEvent = remoteEvents:WaitForChild("PlayerReady")

-- UI Manager
local UIManager = {
	screenGuis = {},
	currentUI = nil,
	matchState = "Waiting",
	timeRemaining = 0,
	isReady = false
}

-- UI Creation Functions
function UIManager.createMainUI()
	-- Remove existing main UI
	local existingUI = player.PlayerGui:FindFirstChild("MainUI")
	if existingUI then
		existingUI:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player.PlayerGui

	-- Match Status Frame
	local statusFrame = Instance.new("Frame")
	statusFrame.Name = "StatusFrame"
	statusFrame.Size = UDim2.new(0.4, 0, 0.15, 0)
	statusFrame.Position = UDim2.new(0.3, 0, 0.02, 0)
	statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	statusFrame.BorderSizePixel = 0
	statusFrame.Parent = screenGui

	-- Round corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = statusFrame

	-- Match State Label
	local stateLabel = Instance.new("TextLabel")
	stateLabel.Name = "StateLabel"
	stateLabel.Size = UDim2.new(1, 0, 0.5, 0)
	stateLabel.Position = UDim2.new(0, 0, 0, 0)
	stateLabel.BackgroundTransparency = 1
	stateLabel.Text = "🎮 WAITING FOR PLAYERS"
	stateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	stateLabel.TextScaled = true
	stateLabel.Font = Enum.Font.GothamBold
	stateLabel.Parent = statusFrame

	-- Timer Label
	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.new(1, 0, 0.5, 0)
	timerLabel.Position = UDim2.new(0, 0, 0.5, 0)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Text = "⏱️ --:--"
	timerLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	timerLabel.TextScaled = true
	timerLabel.Font = Enum.Font.Gotham
	timerLabel.Parent = statusFrame

	-- Money Display
	local moneyFrame = Instance.new("Frame")
	moneyFrame.Name = "MoneyFrame"
	moneyFrame.Size = UDim2.new(0.25, 0, 0.08, 0)
	moneyFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
	moneyFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	moneyFrame.BorderSizePixel = 0
	moneyFrame.Parent = screenGui

	local moneyCorner = Instance.new("UICorner")
	moneyCorner.CornerRadius = UDim.new(0, 8)
	moneyCorner.Parent = moneyFrame

	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(1, 0, 1, 0)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "💰 $0"
	moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	moneyLabel.TextScaled = true
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.Parent = moneyFrame

	-- Ready Button
	local readyButton = Instance.new("TextButton")
	readyButton.Name = "ReadyButton"
	readyButton.Size = UDim2.new(0.2, 0, 0.08, 0)
	readyButton.Position = UDim2.new(0.78, 0, 0.02, 0)
	readyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	readyButton.BorderSizePixel = 0
	readyButton.Text = "✅ READY"
	readyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	readyButton.TextScaled = true
	readyButton.Font = Enum.Font.GothamBold
	readyButton.Parent = screenGui

	local readyCorner = Instance.new("UICorner")
	readyCorner.CornerRadius = UDim.new(0, 8)
	readyCorner.Parent = readyButton

	-- Connect ready button
	readyButton.MouseButton1Click:Connect(function()
		UIManager.toggleReady()
	end)

	UIManager.screenGuis.MainUI = screenGui
	return screenGui
end

-- Toggle ready state
function UIManager.toggleReady()
	UIManager.isReady = not UIManager.isReady
	local readyButton = UIManager.screenGuis.MainUI:FindFirstChild("ReadyButton")
	
	if readyButton then
		if UIManager.isReady then
			readyButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
			readyButton.Text = "❌ NOT READY"
		else
			readyButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
			readyButton.Text = "✅ READY"
		end
	end
	
	-- Notify server
	playerReadyEvent:FireServer(UIManager.isReady)
end

-- Update match state
function UIManager.updateMatchState(state, timeRemaining)
	UIManager.matchState = state
	UIManager.timeRemaining = timeRemaining or 0
	
	local mainUI = UIManager.screenGuis.MainUI
	if not mainUI then return end
	
	local statusFrame = mainUI:FindFirstChild("StatusFrame")
	if not statusFrame then return end
	
	local stateLabel = statusFrame:FindFirstChild("StateLabel")
	local timerLabel = statusFrame:FindFirstChild("TimerLabel")
	
	if stateLabel then
		local stateText = ""
		local stateColor = Color3.fromRGB(255, 255, 255)
		
		if state == "Waiting" then
			stateText = "🎮 WAITING FOR PLAYERS"
			stateColor = Color3.fromRGB(255, 255, 255)
		elseif state == "Selection" then
			stateText = "🍽️ SELECT YOUR FOOD"
			stateColor = Color3.fromRGB(255, 255, 0)
		elseif state == "Combat" then
			stateText = "⚔️ FOOD FIGHT!"
			stateColor = Color3.fromRGB(255, 100, 100)
		elseif state == "Results" then
			stateText = "🏆 MATCH RESULTS"
			stateColor = Color3.fromRGB(100, 255, 100)
		elseif state == "SuddenDeath" then
			stateText = "💀 SUDDEN DEATH!"
			stateColor = Color3.fromRGB(255, 0, 0)
		end
		
		stateLabel.Text = stateText
		stateLabel.TextColor3 = stateColor
	end
	
	if timerLabel then
		if timeRemaining and timeRemaining > 0 then
			local minutes = math.floor(timeRemaining / 60)
			local seconds = math.floor(timeRemaining % 60)
			timerLabel.Text = string.format("⏱️ %02d:%02d", minutes, seconds)
		else
			timerLabel.Text = "⏱️ --:--"
		end
	end
end

-- Show match results
function UIManager.showMatchResults(scores, winner)
	local mainUI = UIManager.screenGuis.MainUI
	if not mainUI then return end
	
	-- Create results overlay
	local resultsFrame = Instance.new("Frame")
	resultsFrame.Name = "ResultsFrame"
	resultsFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
	resultsFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
	resultsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	resultsFrame.BorderSizePixel = 0
	resultsFrame.Parent = mainUI
	
	local resultsCorner = Instance.new("UICorner")
	resultsCorner.CornerRadius = UDim.new(0, 16)
	resultsCorner.Parent = resultsFrame
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🏆 MATCH RESULTS 🏆"
	titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = resultsFrame
	
	-- Winner announcement
	if winner then
		local winnerLabel = Instance.new("TextLabel")
		winnerLabel.Size = UDim2.new(1, 0, 0.1, 0)
		winnerLabel.Position = UDim2.new(0, 0, 0.15, 0)
		winnerLabel.BackgroundTransparency = 1
		winnerLabel.Text = "👑 WINNER: " .. winner.Name .. " 👑"
		winnerLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		winnerLabel.TextScaled = true
		winnerLabel.Font = Enum.Font.GothamBold
		winnerLabel.Parent = resultsFrame
	else
		local tieLabel = Instance.new("TextLabel")
		tieLabel.Size = UDim2.new(1, 0, 0.1, 0)
		tieLabel.Position = UDim2.new(0, 0, 0.15, 0)
		tieLabel.BackgroundTransparency = 1
		tieLabel.Text = "🤝 IT'S A TIE! 🤝"
		tieLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		tieLabel.TextScaled = true
		tieLabel.Font = Enum.Font.GothamBold
		tieLabel.Parent = resultsFrame
	end
	
	-- Scores list
	local scoresFrame = Instance.new("Frame")
	scoresFrame.Size = UDim2.new(0.8, 0, 0.5, 0)
	scoresFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
	scoresFrame.BackgroundTransparency = 1
	scoresFrame.Parent = resultsFrame
	
	-- Sort scores
	local sortedScores = {}
	for player, score in pairs(scores) do
		table.insert(sortedScores, {player = player, score = score})
	end
	table.sort(sortedScores, function(a, b) return a.score > b.score end)
	
	-- Display scores
	for i, scoreData in ipairs(sortedScores) do
		local scoreLabel = Instance.new("TextLabel")
		scoreLabel.Size = UDim2.new(1, 0, 0.1, 0)
		scoreLabel.Position = UDim2.new(0, 0, (i-1) * 0.1, 0)
		scoreLabel.BackgroundTransparency = 1
		scoreLabel.Text = i .. ". " .. scoreData.player.Name .. " - " .. scoreData.score .. " points"
		scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		scoreLabel.TextScaled = true
		scoreLabel.Font = Enum.Font.Gotham
		scoreLabel.TextXAlignment = Enum.TextXAlignment.Left
		scoreLabel.Parent = scoresFrame
	end
	
	-- Auto-remove after 10 seconds
	spawn(function()
		wait(10)
		if resultsFrame and resultsFrame.Parent then
			resultsFrame:Destroy()
		end
	end)
end

-- Initialize UI Manager
function UIManager.init()
	print("Initializing UI Manager...")
	
	-- Create main UI
	UIManager.createMainUI()
	
	-- Connect to remote events
	matchStateEvent.OnClientEvent:Connect(function(state, timeRemaining)
		UIManager.updateMatchState(state, timeRemaining)
	end)
	
	timerUpdateEvent.OnClientEvent:Connect(function(timeRemaining)
		UIManager.updateMatchState(UIManager.matchState, timeRemaining)
	end)
	
	matchResultsEvent.OnClientEvent:Connect(function(scores, winner)
		UIManager.showMatchResults(scores, winner)
	end)
	
	print("UI Manager initialized successfully!")
end

-- Start the UI Manager
spawn(function()
	wait(2) -- Wait for everything to load
	UIManager.init()
end)

print("UI Manager script loaded!") 