-- Food Fighter - Scoring System
-- Place this in ReplicatedStorage/Modules/FoodScoring

local Players = game:GetService("Players")

-- Scoring Configuration
local SCORE_VALUES = {
	Hit = 10,
	Kill = 50,
	Distance = 5, -- bonus per stud of distance
	Combo = 25 -- bonus for consecutive hits
}

-- Player score tracking
local playerScores = {}
local playerCombos = {}

-- Initialize player score
local function initializePlayerScore(player)
	if not player then return end
	
	playerScores[player] = 0
	playerCombos[player] = 0
	
	print("Initialized score for " .. player.Name)
end

-- Add score to player
local function addScore(player, amount, reason)
	if not player then return end
	
	if not playerScores[player] then
		initializePlayerScore(player)
	end
	
	playerScores[player] = playerScores[player] + amount
	playerCombos[player] = playerCombos[player] + 1
	
	print(player.Name .. " scored " .. amount .. " points! (" .. reason .. ") Total: " .. playerScores[player])
	
	-- Update global match manager if available
	if _G.MatchManager then
		_G.MatchManager.updatePlayerScore(player, amount, reason)
	end
end

-- Handle player hit
local function onPlayerHit(attacker, hitPlayer, foodType, distance)
	if not attacker or not hitPlayer then return end
	
	local baseScore = SCORE_VALUES.Hit
	local distanceBonus = math.floor(distance * SCORE_VALUES.Distance)
	local comboBonus = playerCombos[attacker] * SCORE_VALUES.Combo
	
	local totalScore = baseScore + distanceBonus + comboBonus
	
	addScore(attacker, totalScore, "Hit " .. hitPlayer.Name .. " with " .. foodType)
	
	-- Reset combo for hit player
	playerCombos[hitPlayer] = 0
end

-- Handle player kill
local function onPlayerKill(attacker, killedPlayer)
	if not attacker or not killedPlayer then return end
	
	local killScore = SCORE_VALUES.Kill
	addScore(attacker, killScore, "Killed " .. killedPlayer.Name)
	
	-- Reset combo for killed player
	playerCombos[killedPlayer] = 0
end

-- Handle player death
local function onPlayerDeath(player)
	if not player then return end
	
	-- Reset combo on death
	playerCombos[player] = 0
	
	print(player.Name .. " died - combo reset")
end

-- Get player score
local function getPlayerScore(player)
	if not player then return 0 end
	return playerScores[player] or 0
end

-- Get player combo
local function getPlayerCombo(player)
	if not player then return 0 end
	return playerCombos[player] or 0
end

-- Reset all scores
local function resetAllScores()
	playerScores = {}
	playerCombos = {}
	print("All scores reset")
end

-- Module exports
local FoodScoring = {}

FoodScoring.SCORE_VALUES = SCORE_VALUES
FoodScoring.initializePlayerScore = initializePlayerScore
FoodScoring.addScore = addScore
FoodScoring.onPlayerHit = onPlayerHit
FoodScoring.onPlayerKill = onPlayerKill
FoodScoring.onPlayerDeath = onPlayerDeath
FoodScoring.getPlayerScore = getPlayerScore
FoodScoring.getPlayerCombo = getPlayerCombo
FoodScoring.resetAllScores = resetAllScores

return FoodScoring 