local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local CanRoshan = true

local RadiantLoc = Vector(7871, -7803, 13)
local DireLoc = Vector(-7782, 7626, 13)
local RoshanPitLoc = DireLoc

function GetDesire()
	if P.IsMeepoClone(bot) then
		return 0
	end
	
	if CanRoshan and bot:GetHealth() < (bot:GetMaxHealth() * 0.25) then
		CanRoshan = false
	end
	if not CanRoshan and bot:GetHealth() > (bot:GetMaxHealth() * 0.9) then
		CanRoshan = true
	end
	
	if not CanRoshan then
		return 0
	end
	
	--[[if GetTimeOfDay() < 0.5 then
		RoshanPitLoc = DireLoc
	elseif GetTimeOfDay() >= 0.5 then
		RoshanPitLoc = RadiantLoc
	end
	
	for v, Human in pairs(PAF.GetAllyHumanHeroes()) do
		local LastPing = Human:GetMostRecentPing()
		if (GameTime() - LastPing.time) < 30
		and LastPing.normal_ping == false
		and P.GetDistance(RoshanPitLoc, LastPing.location) <= 800 then
			return 0
		end
	end
	
	for v, Human in pairs(PAF.GetAllyHumanHeroes()) do
		local LastPing = Human:GetMostRecentPing()
		if (GameTime() - LastPing.time) < 30
		and LastPing.normal_ping == true
		and P.GetDistance(RoshanPitLoc, LastPing.location) <= 800 then
			return BOT_MODE_DESIRE_VERYHIGH
		end
	end]]--

	local MinMinute = (20 * 60)
	local MaxMinute = (45 * 60)
	local CurrentTime = DotaTime()
	
	local Multiplier = RemapValClamped(CurrentTime, MinMinute, MaxMinute, 1.0, 2.0)
	local nDesire = (GetRoshanDesire() * Multiplier)

	if CurrentTime >= (20 * 60) then
		return Clamp(nDesire, 0.0, 0.9)
	else
		--return 0
		return Clamp(GetRoshanDesire(), 0.0, 0.9)
	end
end