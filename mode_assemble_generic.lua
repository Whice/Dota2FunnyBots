local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")

local LaneToPush, PushDesire

local MaxTeamLevel = 90
local MinTeamLevel = 5

local FinishedLaning = false

function GetDesire()
	if not FinishedLaning and P.IsPushing(bot) then
		FinishedLaning = true -- Prevent bots from prematurely entering farm mode when they can still safely lane
	end

	if FinishedLaning then
		if bot:GetLevel() >= 6 then
			LaneToPush, PushDesire = GetMostDesiredLane()
			
			local TeamLevel = 0
			for v, Player in pairs(GetTeamPlayers(bot:GetTeam())) do
				TeamLevel = (TeamLevel + GetHeroLevel(Player))
			end
			
			local PushScore = RemapValClamped(TeamLevel, MinTeamLevel, MaxTeamLevel, 0.0, PushDesire)
			
			local LaneFrontLocation = GetLaneFrontLocation(bot:GetTeam(), LaneToPush, 0)
			if GetUnitToLocationDistance(bot, LaneFrontLocation) > 1600 then
				return Clamp(PushScore, 0, 0.9)
			end
		end
	end
	
	return 0
end

function Think()
	local LaneFrontLocation = GetLaneFrontLocation(bot:GetTeam(), LaneToPush, 0)
	
	bot:Action_MoveToLocation(LaneFrontLocation)
	return
end


function GetMostDesiredLane()
	local MostDesiredLane = LANE_MID
	local LaneDesire = 0
	
	local Lanes = {LANE_TOP, LANE_MID, LANE_BOT}
	for v, Lane in pairs(Lanes) do
		if GetPushLaneDesire(Lane) > LaneDesire then
			MostDesiredLane = Lane
			LaneDesire = GetPushLaneDesire(Lane)
		end
	end
	
	return MostDesiredLane, LaneDesire
end