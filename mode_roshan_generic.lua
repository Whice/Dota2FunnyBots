local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

function GetDesire()
	if P.IsMeepoClone(bot) then
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
		return Clamp(GetRoshanDesire(), 0.0, 0.9)
	end
end