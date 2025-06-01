local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")

local HumanToFollow = nil
local HumanPingLoc = nil

function GetDesire()
	if not P.IsInLaningPhase() then
		for v, Human in pairs(PAF.GetAllyHumanHeroes()) do
			local LastPing = Human:GetMostRecentPing()
			if (GameTime() - LastPing.time) < 0.2
			and LastPing.normal_ping == true
			and GetUnitToLocationDistance(Human, LastPing.location) <= 300 then
				HumanToFollow = Human
				HumanPingLoc = Human:GetMostRecentPing().location
			end
		end
		
		if HumanToFollow ~= nil and HumanPingLoc ~= nil then
			local HTFPing = HumanToFollow:GetMostRecentPing()
			if HTFPing.location ~= HumanPingLoc or HTFPing.normal_ping == false then
				HumanToFollow = nil
				HumanPingLoc = nil
			end
			
			if HumanToFollow:IsAlive() and GetUnitToUnitDistance(bot, HumanToFollow) > 1200 then
				return BOT_MODE_DESIRE_VERYHIGH
			end
		end
	end
	
	return 0
end

function Think()
	if not P.IsInLaningPhase() then
		if HumanToFollow ~= nil then
			bot:Action_MoveToLocation(HumanToFollow:GetLocation())
			return
		end
	end
	
	return
end