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

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	SunderDesire, SunderTarget = UseSunder()
	if SunderDesire > 0 then
		bot:Action_UseAbilityOnEntity(Sunder, SunderTarget)
		return
	end
	
	MetamorphosisDesire = UseMetamorphosis()
	if MetamorphosisDesire > 0 then
		bot:Action_UseAbility(Metamorphosis)
		return
	end
	
	DemonZealDesire = UseDemonZeal()
	if DemonZealDesire > 0 then
		bot:Action_UseAbility(DemonZeal)
		return
	end
	
	ReflectionDesire, ReflectionTarget = UseReflection()
	if ReflectionDesire > 0 then
		bot:Action_UseAbilityOnLocation(Reflection, ReflectionTarget)
		return
	end
	
	ConjureImageDesire = UseConjureImage()
	if ConjureImageDesire > 0 then
		bot:Action_UseAbility(ConjureImage)
		return
	end
end

function UseReflection()
	if not Reflection:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Reflection:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Reflection:GetSpecialValueInt("range")
	
	if PAF.IsEngaging(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
		end
	end
	
	return 0
end

function UseConjureImage()
	if not ConjureImage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local combocost = Sunder:GetManaCost()
	
	if PAF.IsEngaging(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget ~= nil then
			if bot:GetActiveMode() == BOT_MODE_FARM
			or bot:GetActiveMode() == BOT_MODE_PUSH_TOP
			or bot:GetActiveMode() == BOT_MODE_PUSH_MID
			or bot:GetActiveMode() == BOT_MODE_PUSH_BOT then
				if AttackTarget:IsCreep()
				or AttackTarget:IsBuilding() then
					if AttackTarget:GetTeam() ~= bot:GetTeam() then
						return BOT_ACTION_DESIRE_HIGH
					end
				end
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	return 0
end

function UseMetamorphosis()
	if not Metamorphosis:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end

function UseSunder()
	if not Sunder:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Sunder:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = PAF.GetHealthiestUnit(enemies)
	
	if bot:GetHealth() <= bot:GetMaxHealth() * 0.35 then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseDemonZeal()
	if not DemonZeal:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsInTeamFight(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
end