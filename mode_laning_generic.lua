local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")

function GetDesire()
	local NetworthMin = 0
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		NetworthMin = 3055
	end
	
	if P.IsInLaningPhase()
	or bot:GetLevel() < 6
	or bot:GetNetWorth() < NetworthMin then
		return BOT_MODE_DESIRE_MODERATE
	end
	
	if DotaTime() < 60 * 15 then
		return BOT_MODE_DESIRE_LOW
	end
	
	return BOT_MODE_DESIRE_VERYLOW
end