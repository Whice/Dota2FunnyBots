local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")

local FinishedLaning = false

function GetDesire()
	if DotaTime() < 0 then
		return BOT_MODE_DESIRE_NONE
	end
	
	local NumBots = 0
	local BotsReadyToPush = 0
	
	local IDs = GetTeamPlayers(bot:GetTeam())
	for v, ID in pairs(IDs) do
		if IsPlayerBot(ID) then
			NumBots = (NumBots + 1)
			
			if GetHeroLevel(ID) >= 6 then
				BotsReadyToPush = (BotsReadyToPush + 1)
			end
		end
	end
	
	if P.IsInLaningPhase() or BotsReadyToPush < NumBots then
		return BOT_MODE_DESIRE_MODERATE
	end

	return BOT_MODE_DESIRE_NONE
end

--// FOR TESTING PURPOSES \\--

--[[function GetDesire()
	local NetworthMin = 0
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		NetworthMin = 3055
	end
	
	if (P.IsInLaningPhase()
	or bot:GetLevel() < 6
	or bot:GetNetWorth() < NetworthMin)
	and DotaTime() >= 0 then
		return BOT_MODE_DESIRE_MODERATE
	end
	
	if DotaTime() < 60 * 15
	and DotaTime() >= 0 then
		return BOT_MODE_DESIRE_LOW
	end
	
	return BOT_MODE_DESIRE_VERYLOW
end

function GetDesire()
	if not FinishedLaning and P.IsPushing(bot) then
		FinishedLaning = true -- Prevent bots from prematurely entering farm mode when they can still safely lane
	end
	
	if not FinishedLaning and DotaTime() >= 0 then
		return BOT_MODE_DESIRE_MODERATE
	end

	return BOT_MODE_DESIRE_NONE
end]]--