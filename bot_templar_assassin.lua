local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local bot = GetBot()

function  MinionThink(hMinionUnit) 
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then	
		if string.find(hMinionUnit:GetUnitName(), "npc_dota_templar_assassin_psionic_trap") then
			local SelfTrap = hMinionUnit:GetAbilityByName("templar_assassin_self_trap")
			local radius = SelfTrap:GetSpecialValueInt("trap_radius")
			
			local enemies = hMinionUnit:GetNearbyHeroes(radius, true, BOT_MODE_NONE)
			
			if #enemies >= 1 then
				hMinionUnit:Action_UseAbility(SelfTrap)
			end
		end
		
		if hMinionUnit:IsIllusion() then
			PAF.IllusionTarget(hMinionUnit, bot)
			return
		end
	end
end