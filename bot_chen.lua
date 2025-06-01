local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PNA = require(GetScriptDirectory() ..  "/Library/PhalanxNeutralAbilities")

local bot = GetBot()

function MinionThink(hMinionUnit)
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then
		if hMinionUnit:IsIllusion() then
			PAF.IllusionTarget(hMinionUnit, bot)
			return
		elseif hMinionUnit:IsCreep() then
			-- Creep ability usage
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
			
			PAF.IllusionTarget(hMinionUnit, bot)
			return
		end
	end
end