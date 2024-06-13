------------------------------
-- CREATED BY: MANSLAUGHTER --
------------------------------

local bot = GetBot()
if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() then return end

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

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

local ShadowStrike = bot:GetAbilityByName("queenofpain_shadow_strike")
local Blink = bot:GetAbilityByName("queenofpain_blink")
local ScreamOfPain = bot:GetAbilityByName("queenofpain_scream_of_pain")
local SonicWave = bot:GetAbilityByName("queenofpain_sonic_wave")

local ShadowStrikeDesire = 0
local BlinkDesire = 0
local ScreamOfPainDesire = 0
local SonicWaveDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
local DireBase = Vector(6977.84, 5797.69, 1357.99)
local team = bot:GetTeam()

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + ShadowStrike:GetManaCost()
	manathreshold = manathreshold + Blink:GetManaCost()
	manathreshold = manathreshold + SonicWave:GetManaCost()
	
	
	-- The order to use abilities in
	SonicWaveDesire, SonicWaveTarget = UseSonicWave()
	if SonicWaveDesire > 0 then
		bot:Action_UseAbilityOnLocation(SonicWave, SonicWaveTarget)
		return
	end
	
	BlinkDesire, BlinkTarget = UseBlink()
	if BlinkDesire > 0 then
		bot:Action_UseAbilityOnLocation(Blink, BlinkTarget)
		return
	end
	
	ScreamOfPainDesire = UseScreamOfPain()
	if ScreamOfPainDesire > 0 then
		bot:Action_UseAbility(ScreamOfPain)
		return
	end
	
	ShadowStrikeDesire, ShadowStrikeTarget = UseShadowStrike()
	if ShadowStrikeDesire > 0 then
		if bot:HasScepter() then
			bot:Action_UseAbilityOnLocation(ShadowStrike, ShadowStrikeTarget)
		else
			bot:Action_UseAbilityOnEntity(ShadowStrike, ShadowStrikeTarget)
		end
		return
	end
end

function UseShadowStrike()
	if not ShadowStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ShadowStrike:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				if bot:HasScepter() then
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget
				end
			end
		end
	end
	
	if P.IsInLaningPhase() then
		local EnemiesWithinRange = bot:GetNearbyHeroes((CastRange + 200), true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		local WeakestTarget = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestTarget ~= nil then
			if not PAF.IsMagicImmune(WeakestTarget) then
				if bot:HasScepter() then
					return BOT_ACTION_DESIRE_HIGH, WeakestTarget:GetLocation()
				else
					return BOT_ACTION_DESIRE_HIGH, WeakestTarget
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			if bot:HasScepter() then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			else
				return BOT_ACTION_DESIRE_HIGH, AttackTarget
			end
		end
	end
	
	return 0
end

function UseBlink()
	if not Blink:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Blink:GetSpecialValueInt("blink_range")
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_ABSOLUTE, PAF.GetFountainLocation(bot)
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local EstimatedDamage = bot:GetEstimatedDamageToTarget(true, BotTarget, 3, DAMAGE_TYPE_ALL)
			local SOPRadius = ScreamOfPain:GetSpecialValueInt("area_of_effect")
			
			if EstimatedDamage > BotTarget:GetHealth() then
				if GetUnitToUnitDistance(bot, BotTarget) < CastRange
				and GetUnitToUnitDistance(bot, BotTarget) > SOPRadius then
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
				end
			end
			
			if PAF.IsChasing(bot, BotTarget) then
				local AoECount = PAF.GetUnitsNearTarget(BotTarget:GetLocation(), FilteredEnemies, 800)
				
				if AoECount <= 2 then
					if GetUnitToUnitDistance(bot, BotTarget) > AttackRange then
						return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
					end
				end
			end
		end
	end
	
	return 0
end

function UseScreamOfPain()
	if not ScreamOfPain:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ScreamOfPain:GetSpecialValueInt("area_of_effect")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local NonImmuneEnemies = {}
	
	for v, enemy in pairs(FilteredEnemies) do
		if not PAF.IsMagicImmune(enemy) then
			table.insert(NonImmuneEnemies, enemy)
		end
	end
	
	if #NonImmuneEnemies >= 1 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local Neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #Neutrals >= 2 and (bot:GetMana() - ScreamOfPain:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end
	
	return 0
end

function UseSonicWave()
	if not SonicWave:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	
	local CastRange = SonicWave:GetCastRange()
	local Radius = SonicWave:GetSpecialValueInt("final_aoe")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
	end
	
	return 0
end