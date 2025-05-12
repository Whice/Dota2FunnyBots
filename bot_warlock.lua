local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local bot = GetBot()

function  MinionThink(hMinionUnit) 
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then	
		if string.find(hMinionUnit:GetUnitName(), "warlock_golem") then
			PAF.IllusionTarget(hMinionUnit, bot)
			return
		end
		
		if hMinionUnit:IsIllusion() then
			PAF.IllusionTarget(hMinionUnit, bot)
			return
		end
	end
end