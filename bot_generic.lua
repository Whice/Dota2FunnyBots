local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local bot = GetBot()

function MinionThink(hMinionUnit) 
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then
		if hMinionUnit:IsIllusion() then
			PAF.IllusionTarget(hMinionUnit, bot)
			return
		end
	end
end