local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then return end

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local BotBuild = dofile(GetScriptDirectory() .. "/BotLib/" .. string.gsub(botName, "npc_dota_", ""));

if BotBuild == nil
then
	print('[ERROR] No build config file found for bot: '..botName)
	return
end

function MinionThink(hMinionUnit)
	if not Utils.IsValidUnit(hMinionUnit) then return end
	if hMinionUnit.lastMinionFrameProcessTime == nil then hMinionUnit.lastMinionFrameProcessTime = DotaTime() end
	if DotaTime() - hMinionUnit.lastMinionFrameProcessTime < 0.3 then return end
	hMinionUnit.lastMinionFrameProcessTime = DotaTime()

	BotBuild.MinionThink(hMinionUnit)
end
