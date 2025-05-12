local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local bot = GetBot()

function  MinionThink(hMinionUnit) 
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then	
		if string.find(hMinionUnit:GetUnitName(), "lycan_wolf1")
		or string.find(hMinionUnit:GetUnitName(), "lycan_wolf2")
		or string.find(hMinionUnit:GetUnitName(), "lycan_wolf3")
		or string.find(hMinionUnit:GetUnitName(), "lycan_wolf4")
		or string.find(hMinionUnit:GetUnitName(), "lycan_wolf5")
		or string.find(hMinionUnit:GetUnitName(), "lycan_wolf6") then
			PAF.IllusionTarget(hMinionUnit, bot)
			return
		end
		
		if hMinionUnit:IsIllusion() then
			PAF.IllusionTarget(hMinionUnit, bot)
			return
		end
	end
end