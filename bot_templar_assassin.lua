local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PNA = require(GetScriptDirectory() ..  "/Library/PhalanxNeutralAbilities")

local bot = GetBot()

function  MinionThink(hMinionUnit) 
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then	
		if string.find(hMinionUnit:GetUnitName(), "npc_dota_templar_assassin_psionic_trap") then
			local SelfTrap = hMinionUnit:GetAbilityByName("templar_assassin_self_trap")
			local radius = SelfTrap:GetSpecialValueInt("trap_radius")
			
			local enemies = hMinionUnit:GetNearbyHeroes(radius, true, BOT_MODE_NONE)
			
			if #enemies >= 1 then
				hMinionUnit:Action_UseAbility(SelfTrap)
				return
			end
		end
		
		
		if hMinionUnit:IsCreep() then
			local MinionAbilities = {
				hMinionUnit:GetAbilityInSlot(0),
				hMinionUnit:GetAbilityInSlot(1),
				hMinionUnit:GetAbilityInSlot(2),
				hMinionUnit:GetAbilityInSlot(3),
				hMinionUnit:GetAbilityInSlot(4),
				hMinionUnit:GetAbilityInSlot(5),
			}
			
			for v, hAbility in pairs(MinionAbilities) do
				if hAbility ~= nil and hAbility:GetName() ~= "" and not hAbility:IsPassive() then
					if PNA.UseNeutralAbility(hAbility, bot, hMinionUnit) == true then
						return
					end
				end
			end
		end
		
		PAF.IllusionTarget(hMinionUnit, bot)
		return
		
	end
end