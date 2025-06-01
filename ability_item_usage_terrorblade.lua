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

local Reflection = bot:GetAbilityByName("terrorblade_reflection")
local ConjureImage = bot:GetAbilityByName("terrorblade_conjure_image")
local Metamorphosis = bot:GetAbilityByName("terrorblade_metamorphosis")
local Sunder = bot:GetAbilityByName("terrorblade_sunder")
local DemonZeal = bot:GetAbilityByName("terrorblade_demon_zeal")

local ReflectionDesire = 0
local ConjureImageDesire = 0
local MetamorphosisDesire = 0
local SunderDesire = 0
local DemonZealDesire = 0

local AttackRange
local BotTarget
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = (100 + Reflection:GetManaCost() + ConjureImage:GetManaCost() + Metamorphosis:GetManaCost() + Sunder:GetManaCost())
	
	-- The order to use abilities in
	SunderDesire, SunderTarget = UseSunder()
	if SunderDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Sunder, SunderTarget)
		return
	end
	
	MetamorphosisDesire = UseMetamorphosis()
	if MetamorphosisDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Metamorphosis)
		return
	end
	
	DemonZealDesire = UseDemonZeal()
	if DemonZealDesire > 0 then
		PAF.SwitchTreadsToStr(bot)
		bot:ActionQueue_UseAbility(DemonZeal)
		return
	end
	
	ReflectionDesire, ReflectionTarget = UseReflection()
	if ReflectionDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(Reflection, ReflectionTarget)
		return
	end
	
	ConjureImageDesire = UseConjureImage()
	if ConjureImageDesire > 0 then
		PAF.SwitchTreadsToAgi(bot)
		bot:ActionQueue_UseAbility(ConjureImage)
		return
	end
end

function UseReflection()
	if not Reflection:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Reflection:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = Reflection:GetCastPoint()
	local Radius = Reflection:GetSpecialValueInt("range")
	
	if bot:GetActiveMode() == BOT_MODE_LANING or PAF.IsEngaging(bot) then
		local AoELocation = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius, CastPoint, 0)
		
		if AoELocation.count >= 2 then
			return 1, AoELocation.targetloc
		end
	end
	
	return 0
end

function UseConjureImage()
	if not ConjureImage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ManaCost = ConjureImage:GetManaCost()
	
	local ManaThresholdTwo = 0
	if Metamorphosis:IsFullyCastable() then
		ManaThresholdTwo = (ManaThresholdTwo + Metamorphosis:GetManaCost())
	end
	if Sunder:IsFullyCastable() then
		ManaThresholdTwo = (ManaThresholdTwo + Sunder:GetManaCost())
	end
	
	if PAF.IsEngaging(bot) or not P.IsInLaningPhase() then
		if PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThresholdTwo, false) then
			return 1
		end
	end
	
	return 0
end

function UseMetamorphosis()
	if not Metamorphosis:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsInTeamFight(bot) then
		return 1
	end
	
	return 0
end

function UseSunder()
	if not Sunder:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Sunder:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	if bot:GetHealth() <= (bot:GetMaxHealth() * 0.35) then
		local HealthiestEnemy = PAF.GetHealthiestUnit(EnemiesWithinCastRange)
		
		if HealthiestEnemy ~= nil then
			return 1, HealthiestEnemy
		end
	end
	
	return 0
end

function UseDemonZeal()
	if not DemonZeal:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Duration = DemonZeal:GetSpecialValueInt("duration")
	local MetamorphosisCooldown = Metamorphosis:GetCooldownTimeRemaining()
	
	if MetamorphosisCooldown <= Duration then
		return 0
	end
	
	if PAF.IsInTeamFight(bot) then
		return 1
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if AttackTarget:GetTeam() ~= bot:GetTeam() then
			return 1
		end
	end
	
	return 0
end