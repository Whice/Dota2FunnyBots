local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

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
			local target = P.IllusionTarget(hMinionUnit, bot)
		
			if target ~= nil then
				hMinionUnit:Action_AttackUnit(target, false)
			else
				if GetUnitToUnitDistance(hMinionUnit, bot) > 200 then
					hMinionUnit:Action_MoveToLocation(bot:GetLocation())
				else
					hMinionUnit:Action_MoveToLocation(bot:GetLocation()+RandomVector(200))
				end
			end
		end
	end
end