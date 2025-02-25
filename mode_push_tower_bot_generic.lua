local PPush = require(GetScriptDirectory() .. "/Library/PhalanxPush")

local LastMessageTime = DotaTime()
local bot = GetBot()

--[[function GetDesire()
	if GetTeam() == TEAM_RADIANT then
		return PPush.GetPushDesire(bot, LANE_BOT)
	elseif GetTeam() == TEAM_DIRE then
		return PPush.GetPushDesire(bot, LANE_BOT)
	end
end]]--

function OnStart()
	if (DotaTime() - LastMessageTime) > 60 then
		LastMessageTime = DotaTime()
		bot:ActionImmediate_Chat("Pushing bottom", false)
	end
end

function Think()
	PPush.PushThink(bot, LANE_BOT)
end