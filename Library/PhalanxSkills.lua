local PSkills = {}

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local HeroesToAvoidStealing = {
	"npc_dota_hero_primal_beast",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_muerta",
	"npc_dota_hero_hoodwink",
	"npc_dota_hero_kez",
	"npc_dota_hero_monkey_king",
	"npc_dota_hero_marci",
}

function PSkills.UseStolenAbility(bot, hAbility)
	local CastRange
	
	CastRange = hAbility:GetCastRange()
	if CastRange < bot:GetAttackRange() or CastRange == nil then
		CastRange = (bot:GetAttackRange() + 50)
	end
	
	if hAbility:GetName() == "pudge_rot" then
		local Radius = hAbility:GetSpecialValueInt("rot_radius")
		
		local EnemiesWithinRange = bot:GetNearbyHeroes((Radius + 50), true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 then
			if hAbility:GetToggleState() == false then
				return true
			else
				return false
			end
		else
			if hAbility:GetToggleState() == true then
				return true
			else
				return false
			end
		end
		
		return false
	end
	
	if hAbility:GetName() == "morphling_morph_str" then
		if hAbility:GetToggleState() == false then
			return true
		else
			return false
		end
		
		return false
	end
	
	if hAbility:GetName() == "morphling_morph_agi" then
		return false
	end
	
	--if PSkills.HasFlag(hAbility:GetTargetType(), ABILITY_TARGET_TYPE_HERO) then
		if PSkills.HasFlag(hAbility:GetTargetTeam(), ABILITY_TARGET_TEAM_ENEMY)
		or not PSkills.HasFlag(hAbility:GetTargetTeam(), ABILITY_TARGET_TEAM_FRIENDLY) then
			PSkills.ShouldCastAbilityOnEnemy(bot, hAbility, CastRange)
			return true
		end
			
		if PSkills.HasFlag(hAbility:GetTargetTeam(), ABILITY_TARGET_TEAM_FRIENDLY) then
			PSkills.ShouldCastAbilityOnAlly(bot, hAbility, CastRange)
			return true
		end
	--end
	
	return false
end

function PSkills.ShouldCastAbilityOnEnemy(bot, hAbility, CastRange)
	if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
	
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				if PSkills.HasFlag(hAbility:GetTargetFlags(), ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES) then
					if not PAF.IsMagicImmune(BotTarget) then
						if PSkills.HasFlag(hAbility:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET) then
							bot:Action_UseAbilityOnEntity(hAbility, BotTarget)
							return
						end
						
						if PSkills.HasFlag(hAbility:GetBehavior(), ABILITY_BEHAVIOR_POINT) then
							bot:Action_UseAbilityOnLocation(hAbility, BotTarget:GetLocation())
							return
						end
						
						if PSkills.HasFlag(hAbility:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET) then
							bot:Action_UseAbility(hAbility)
							return
						end
					end
				else
					if PSkills.HasFlag(hAbility:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET) then
						bot:Action_UseAbilityOnEntity(hAbility, BotTarget)
						return
					end
						
					if PSkills.HasFlag(hAbility:GetBehavior(), ABILITY_BEHAVIOR_POINT) then
						bot:Action_UseAbilityOnLocation(hAbility, BotTarget:GetLocation())
						return
					end
						
					if PSkills.HasFlag(hAbility:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET) then
						bot:Action_UseAbility(hAbility)
						return
					end
				end
			end
		end
	end
	
	return false
end

function PSkills.ShouldCastAbilityOnAlly(bot, hAbility, CastRange)
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local StrongestAlly = PAF.GetStrongestPowerUnit(FilteredAllies)
	
	if GetUnitToUnitDistance(bot, StrongestAlly) <= CastRange then
		if PSkills.HasFlag(hAbility:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET) then
			bot:Action_UseAbilityOnEntity(hAbility, StrongestAlly)
			return
		end
							
		if PSkills.HasFlag(hAbility:GetBehavior(), ABILITY_BEHAVIOR_POINT) then
			bot:Action_UseAbilityOnEntity(hAbility, StrongestAlly:GetLocation())
			return
		end
							
		if PSkills.HasFlag(hAbility:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET) then
			bot:Action_UseAbility(hAbility)
			return
		end
	end
end

function PSkills.IsViableEnemy(Enemy)
	for v, Hero in pairs(HeroesToAvoidStealing) do
		if Enemy:GetUnitName() == Hero then
			return false
		end
	end
	
	return true
end

function PSkills.HasFlag(value, flag)
	if flag == 0 then return false end
		
	return (math.floor(value / flag) % 2) == 1
end

return PSkills