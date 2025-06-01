------------------------------
-- CREATED BY: MANSLAUGHTER --
------------------------------

local bot = GetBot()
if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() then return end

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PSkills = require(GetScriptDirectory() ..  "/Library/PhalanxSkills")

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local Telekinesis = bot:GetAbilityByName("rubick_telekinesis")
local FadeBolt = bot:GetAbilityByName("rubick_fade_bolt")
local ArcaneSupremacy = bot:GetAbilityByName("rubick_arcane_supremacy")
local SpellSteal = bot:GetAbilityByName("rubick_spell_steal")
local TelekinesisLand = bot:GetAbilityByName("rubick_telekinesis_land")

local TelekinesisDesire = 0
local FadeBoltDesire = 0
local SpellStealDesire = 0
local TelekinesisLandDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	local AbilityOne = bot:GetAbilityInSlot(3)
	local AbilityTwo = bot:GetAbilityInSlot(4)
		
	local MorphedAbilities = {AbilityOne, AbilityTwo}
		
	for v, ability in pairs(MorphedAbilities) do
		local CanCastAbility = true
			
		if not ability:IsFullyCastable() then CanCastAbility = false end
		if P.CantUseAbility(bot) then CanCastAbility = false end
		if ability:IsNull() or ability == nil or string.find(ability:GetName(), "empty") then CanCastAbility = false end
			
		if CanCastAbility then
			if PSkills.UseStolenAbility(bot, ability) == true then
				return
			end
		end
	end
	
	SpellStealDesire, SpellStealTarget = UseSpellSteal()
	if SpellStealDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(SpellSteal, SpellStealTarget)
		return
	end
	
	TelekinesisDesire, TelekinesisTarget = UseTelekinesis()
	if TelekinesisDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Telekinesis, TelekinesisTarget)
		return
	end
	
	FadeBoltDesire, FadeBoltTarget = UseFadeBolt()
	if FadeBoltDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(FadeBolt, FadeBoltTarget)
		return
	end
	
	TelekinesisLandDesire, TelekinesisLandTarget = UseTelekinesisLand()
	if TelekinesisLandDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(TelekinesisLand, TelekinesisLandTarget)
		return
	end
end

function UseTelekinesis()
	if not Telekinesis:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Telekinesis:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end

function UseFadeBolt()
	if not FadeBolt:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FadeBolt:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseSpellSteal()
	if not SpellSteal:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SpellSteal:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local ViableEnemies = {}
	
	for v, Enemy in pairs(FilteredEnemies) do
		if PSkills.IsViableEnemy(Enemy) then
			table.insert(ViableEnemies, Enemy)
		end
	end
	
	if #ViableEnemies > 0 then
		local StrongestEnemy = PAF.GetStrongestPowerUnit(ViableEnemies)
		
		if PAF.IsInTeamFight(bot) then
			if PAF.IsValidHeroAndNotIllusion(StrongestEnemy) then
				if GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
					return BOT_ACTION_DESIRE_HIGH, StrongestEnemy
				end
			end
		end
	end
	
	return 0
end

function UseTelekinesisLand()
	if not TelekinesisLand:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if TelekinesisLand:IsHidden() then return 0 end
	
	if P.IsRetreating(bot) then
		if bot:GetTeam() == TEAM_RADIANT then
			return 1, Vector( 6974, 6402, 392 )
		end
		
		if bot:GetTeam() == TEAM_DIRE then
			return 1, Vector( -7169, -6654, 392 )
		end
	else
		return 1, PAF.GetFountainLocation(bot)
	end
	
	return 0
end