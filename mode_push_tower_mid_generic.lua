local PPush = require(GetScriptDirectory() .. "/Library/PhalanxPush")

local LastMessageTime = DotaTime()
local bot = GetBot()

--[[function GetDesire()
	if GetTeam() == TEAM_RADIANT then
		return PPush.GetPushDesire(bot, LANE_MID)
	elseif GetTeam() == TEAM_DIRE then
		return PPush.GetPushDesire(bot, LANE_MID)
	end
end]]--

function OnStart()
	if (DotaTime() - LastMessageTime) > 30 then
		LastMessageTime = DotaTime()
		bot:ActionImmediate_Chat("Pushing mid", false);
	end
end

function Think()
	PPush.PushThink(bot, LANE_MID)
end