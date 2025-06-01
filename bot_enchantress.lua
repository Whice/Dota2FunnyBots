local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PNA = require(GetScriptDirectory() ..  "/Library/PhalanxNeutralAbilities")

local bot = GetBot()

function MinionThink(hMinionUnit)
	local Enchant = bot:GetAbilityByName("enchantress_enchant")
	local MaxLifespan = Enchant:GetSpecialValueInt("dominate_duration")
	
	if hMinionUnit:IsCreep() and hMinionUnit:IsDominated() then
		if bot.DominatedUnitOne == nil then
			bot.DominatedUnitOne = hMinionUnit
		end
	end
	
	if bot:HasScepter() then
		if hMinionUnit:IsCreep() and hMinionUnit:IsDominated() then
			if bot.DominatedUnitOne ~= nil
			and bot.DominatedUnitOne ~= hMinionUnit
			and bot.DominatedUnitTwo == nil then
				bot.DominatedUnitTwo = hMinionUnit
			end
		end
	end
	
	if bot.DominatedUnitOne == hMinionUnit then
		bot.DominatedUnitOneHeartbeat = DotaTime()
	end
	
	if bot.DominatedUnitTwo == hMinionUnit then
		bot.DominatedUnitTwoHeartbeat = DotaTime()
	end
	
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