local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local CanRoshan = true

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