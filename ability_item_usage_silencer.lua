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

local CurseOfTheSilent = bot:GetAbilityByName("silencer_curse_of_the_silent")
local GlaivesOfWisdom = bot:GetAbilityByName("silencer_glaives_of_wisdom")
local LastWord = bot:GetAbilityByName("silencer_last_word")
local GlobalSilence = bot:GetAbilityByName("silencer_global_silence")

local CurseOfTheSilentDesire = 0
local GlaivesOfWisdomDesire = 0
local LastWordDesire = 0
local GlobalSilenceDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	GlobalSilenceDesire = UseGlobalSilence()
	if GlobalSilenceDesire > 0 then
		bot:Action_UseAbility(GlobalSilence)
		return
	end
	
	CurseOfTheSilentDesire, CurseOfTheSilentTarget = UseCurseOfTheSilent()
	if CurseOfTheSilentDesire > 0 then
		bot:Action_UseAbilityOnLocation(CurseOfTheSilent, CurseOfTheSilentTarget)
		return
	end
	
	LastWordDesire, LastWordTarget = UseLastWord()
	if LastWordDesire > 0 then
		bot:Action_UseAbilityOnEntity(LastWord, LastWordTarget)
		return
	end
	
	GlaivesOfWisdomDesire, GlaivesOfWisdomTarget = UseGlaivesOfWisdom()
	if GlaivesOfWisdomDesire > 0 then
		bot:Action_UseAbilityOnEntity(GlaivesOfWisdom, GlaivesOfWisdomTarget)
		return
	end
end

function UseCurseOfTheSilent()
	if not CurseOfTheSilent:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = CurseOfTheSilent:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = CurseOfTheSilent:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	for v, enemy in pairs(EnemiesWithinRange) do
		if PAF.IsValidHeroAndNotIllusion(enemy) 
		and enemy:IsSilenced() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseGlaivesOfWisdom()
	if not GlaivesOfWisdom:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsHero()
		or AttackTarget:IsBuilding()
		or PAF.IsRoshan(AttackTarget) then
			if GlaivesOfWisdom:GetAutoCastState() == false then
				GlaivesOfWisdom:ToggleAutoCast()
				return 0
			else
				return 0
			end
		end
	end
	
	if GlaivesOfWisdom:GetAutoCastState() == true then
		GlaivesOfWisdom:ToggleAutoCast()
		return 0
	end
	
	return 0
end

function UseLastWord()
	if not LastWord:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LastWord:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local EnemiesWithinExtraRange = bot:GetNearbyHeroes(CastRange + 300, true, BOT_MODE_NONE)
	
	for v, enemy in pairs(EnemiesWithinRange) do
		if PAF.IsValidHeroAndNotIllusion(enemy) 
		and not PAF.IsPossibleIllusion(enemy) 
		and not PAF.IsMagicImmune(enemy) 
		and not PAF.IsDisabled(enemy)
		and not enemy:IsSilenced()
		and not enemy:IsMuted() then
			if enemy:IsChanneling() then
				return BOT_ACTION_DESIRE_HIGH, enemy
			end
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
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

function UseGlobalSilence()
	if not GlobalSilence:IsFullyCastable() then return 0 end
	if not PAF.IsEngaging(bot) then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if not P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end