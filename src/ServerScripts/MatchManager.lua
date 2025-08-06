-- Food Fighter - Match Manager
-- Place this in ServerScriptService/MatchManager

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create remote events folder if it doesn't exist
local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
	remoteEventsFolder = Instance.new("Folder")
	remoteEventsFolder.Name = "RemoteEvents"
	remoteEventsFolder.Parent = ReplicatedStorage
end

-- Create remote events
local matchStateEvent = Instance.new("RemoteEvent")
matchStateEvent.Name = "MatchStateChanged"
matchStateEvent.Parent = remoteEventsFolder

local timerUpdateEvent = Instance.new("RemoteEvent")
timerUpdateEvent.Name = "TimerUpdate"
timerUpdateEvent.Parent = remoteEventsFolder

local matchResultsEvent = Instance.new("RemoteEvent")
matchResultsEvent.Name = "MatchResults"
matchResultsEvent.Parent = remoteEventsFolder

local playerReadyEvent = Instance.new("RemoteEvent")
playerReadyEvent.Name = "PlayerReady"
playerReadyEvent.Parent = remoteEventsFolder

-- Game States
local GameStates = {
	WAITING = "Waiting",
	SELECTION = "Selection",
	COMBAT = "Combat", 
	RESULTS = "Results",
	SUDDEN_DEATH = "SuddenDeath"
}

-- Match Configuration
local MATCH_CONFIG = {
	MIN_PLAYERS = 2,
	MAX_PLAYERS = 4,
	SELECTION_TIME = 30,
	COMBAT_TIME = 60,
	RESULTS_TIME = 15,
	SUDDEN_DEATH_TIME = 30
}

-- Match Manager State
local MatchManager = {
	currentState = GameStates.WAITING,
	timeRemaining = 0,
	activePlayers = {},
	playerScores = {},
	readyPlayers = {},
	winner = nil,
	matchNumber = 0,
	updateConnection = nil
}

-- Player Management
function MatchManager.addPlayer(player)
	if #MatchManager.activePlayers >= MATCH_CONFIG.MAX_PLAYERS then
		return false -- Match full
	end

	-- Check if player already in match
	for _, activePlayer in pairs(MatchManager.activePlayers) do
		if activePlayer == player then
			return false -- Already in match
		end
	end

	table.insert(MatchManager.activePlayers, player)
	MatchManager.playerScores[player] = 0
	MatchManager.readyPlayers[player] = false

	print(player.Name .. " joined the match (" .. #MatchManager.activePlayers .. "/" .. MATCH_CONFIG.MAX_PLAYERS .. ")")

	-- Check if we can start
	MatchManager.checkMatchStart()

	-- Send current state to new player
	matchStateEvent:FireClient(player, MatchManager.currentState, MatchManager.timeRemaining)

	return true
end

function MatchManager.removePlayer(player)
	-- Remove from active players
	for i, activePlayer in pairs(MatchManager.activePlayers) do
		if activePlayer == player then
			table.remove(MatchManager.activePlayers, i)
			break
		end
	end

	-- Remove from scores and ready lists
	MatchManager.playerScores[player] = nil
	MatchManager.readyPlayers[player] = nil

	print(player.Name .. " left the match (" .. #MatchManager.activePlayers .. "/" .. MATCH_CONFIG.MAX_PLAYERS .. ")")

	-- Check if match should end
	MatchManager.checkMatchEnd()
end

function MatchManager.setPlayerReady(player, ready)
	MatchManager.readyPlayers[player] = ready
	print(player.Name .. " is " .. (ready and "ready" or "not ready"))

	-- Check if all players are ready
	MatchManager.checkAllPlayersReady()
end

-- Match State Management
function MatchManager.checkMatchStart()
	if #MatchManager.activePlayers >= MATCH_CONFIG.MIN_PLAYERS then
		if MatchManager.currentState == GameStates.WAITING then
			MatchManager.startSelectionPhase()
		end
	end
end

function MatchManager.checkMatchEnd()
	if #MatchManager.activePlayers < MATCH_CONFIG.MIN_PLAYERS then
		MatchManager.endMatch()
	end
end

function MatchManager.checkAllPlayersReady()
	if MatchManager.currentState ~= GameStates.SELECTION then
		return
	end

	local allReady = true
	for _, player in pairs(MatchManager.activePlayers) do
		if not MatchManager.readyPlayers[player] then
			allReady = false
			break
		end
	end

	if allReady then
		MatchManager.startCombatPhase()
	end
end

-- Phase Management
function MatchManager.startSelectionPhase()
	MatchManager.currentState = GameStates.SELECTION
	MatchManager.timeRemaining = MATCH_CONFIG.SELECTION_TIME
	MatchManager.matchNumber = MatchManager.matchNumber + 1

	print("=== MATCH " .. MatchManager.matchNumber .. " STARTING ===")
	print("Selection phase started - " .. MatchManager.timeRemaining .. " seconds")

	-- Reset ready status
	for _, player in pairs(MatchManager.activePlayers) do
		MatchManager.readyPlayers[player] = false
	end

	-- Notify all players
	matchStateEvent:FireAllClients(MatchManager.currentState, MatchManager.timeRemaining)

	-- Start timer
	MatchManager.startTimer()
end

function MatchManager.startCombatPhase()
	MatchManager.currentState = GameStates.COMBAT
	MatchManager.timeRemaining = MATCH_CONFIG.COMBAT_TIME

	print("Combat phase started - " .. MatchManager.timeRemaining .. " seconds")

	-- Notify all players
	matchStateEvent:FireAllClients(MatchManager.currentState, MatchManager.timeRemaining)

	-- Start timer
	MatchManager.startTimer()
end

function MatchManager.startResultsPhase()
	MatchManager.currentState = GameStates.RESULTS
	MatchManager.timeRemaining = MATCH_CONFIG.RESULTS_TIME

	-- Determine winner
	MatchManager.determineWinner()

	print("Results phase started - Winner: " .. (MatchManager.winner and MatchManager.winner.Name or "None"))

	-- Notify all players
	matchStateEvent:FireAllClients(MatchManager.currentState, MatchManager.timeRemaining)
	matchResultsEvent:FireAllClients(MatchManager.playerScores, MatchManager.winner)

	-- Start timer
	MatchManager.startTimer()
end

function MatchManager.startSuddenDeath()
	MatchManager.currentState = GameStates.SUDDEN_DEATH
	MatchManager.timeRemaining = MATCH_CONFIG.SUDDEN_DEATH_TIME

	print("SUDDEN DEATH - " .. MatchManager.timeRemaining .. " seconds")

	-- Notify all players
	matchStateEvent:FireAllClients(MatchManager.currentState, MatchManager.timeRemaining)

	-- Start timer
	MatchManager.startTimer()
end

function MatchManager.endMatch()
	MatchManager.currentState = GameStates.WAITING
	MatchManager.timeRemaining = 0
	MatchManager.winner = nil

	print("Match ended - returning to waiting state")

	-- Stop timer
	if MatchManager.updateConnection then
		MatchManager.updateConnection:Disconnect()
		MatchManager.updateConnection = nil
	end

	-- Notify all players
	matchStateEvent:FireAllClients(MatchManager.currentState, MatchManager.timeRemaining)
end

-- Timer Management
function MatchManager.startTimer()
	-- Stop existing timer
	if MatchManager.updateConnection then
		MatchManager.updateConnection:Disconnect()
	end

	-- Start new timer
	MatchManager.updateConnection = RunService.Heartbeat:Connect(function(deltaTime)
		MatchManager.timeRemaining = MatchManager.timeRemaining - deltaTime

		-- Update timer display every second
		if math.floor(MatchManager.timeRemaining) ~= math.floor(MatchManager.timeRemaining + deltaTime) then
			timerUpdateEvent:FireAllClients(math.floor(MatchManager.timeRemaining))
		end

		-- Check for phase transitions
		if MatchManager.timeRemaining <= 0 then
			if MatchManager.currentState == GameStates.SELECTION then
				-- Auto-start combat if time runs out
				MatchManager.startCombatPhase()
			elseif MatchManager.currentState == GameStates.COMBAT then
				-- Check for tie
				if MatchManager.isTie() then
					MatchManager.startSuddenDeath()
				else
					MatchManager.startResultsPhase()
				end
			elseif MatchManager.currentState == GameStates.SUDDEN_DEATH then
				-- End match after sudden death
				MatchManager.startResultsPhase()
			elseif MatchManager.currentState == GameStates.RESULTS then
				-- Start new match
				MatchManager.startSelectionPhase()
			end
		end
	end)
end

-- Scoring and Results
function MatchManager.addScore(player, points)
	if not MatchManager.playerScores[player] then
		MatchManager.playerScores[player] = 0
	end

	MatchManager.playerScores[player] = MatchManager.playerScores[player] + points
	print(player.Name .. " scored " .. points .. " points! Total: " .. MatchManager.playerScores[player])
end

function MatchManager.determineWinner()
	local highestScore = -1
	local winner = nil
	local tie = false

	for player, score in pairs(MatchManager.playerScores) do
		if score > highestScore then
			highestScore = score
			winner = player
			tie = false
		elseif score == highestScore then
			tie = true
		end
	end

	if tie then
		MatchManager.winner = nil
		print("TIE GAME!")
	else
		MatchManager.winner = winner
		if winner then
			print("Winner: " .. winner.Name .. " with " .. highestScore .. " points!")
		end
	end
end

function MatchManager.isTie()
	local highestScore = -1
	local playersWithHighestScore = 0

	for player, score in pairs(MatchManager.playerScores) do
		if score > highestScore then
			highestScore = score
			playersWithHighestScore = 1
		elseif score == highestScore then
			playersWithHighestScore = playersWithHighestScore + 1
		end
	end

	return playersWithHighestScore > 1
end

-- Public API
function MatchManager.getMatchInfo()
	return {
		state = MatchManager.currentState,
		timeRemaining = MatchManager.timeRemaining,
		activePlayers = MatchManager.activePlayers,
		playerScores = MatchManager.playerScores,
		winner = MatchManager.winner,
		matchNumber = MatchManager.matchNumber
	}
end

function MatchManager.getPlayerScore(player)
	return MatchManager.playerScores[player] or 0
end

function MatchManager.isPlayerInMatch(player)
	for _, activePlayer in pairs(MatchManager.activePlayers) do
		if activePlayer == player then
			return true
		end
	end
	return false
end

-- Event Handlers
playerReadyEvent.OnServerEvent:Connect(function(player, ready)
	if MatchManager.isPlayerInMatch(player) then
		MatchManager.setPlayerReady(player, ready)
	end
end)

-- Player Management
Players.PlayerAdded:Connect(function(player)
	-- Add player to match when they join
	wait(2) -- Wait for player to fully load
	MatchManager.addPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	-- Remove player from match when they leave
	MatchManager.removePlayer(player)
end)

-- Initialize
print("Match Manager initialized!")
print("Waiting for players...")

-- Export to global for other scripts
_G.MatchManager = MatchManager 