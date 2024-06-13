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

local NaturesGrasp = bot:GetAbilityByName("treant_natures_grasp")
local LeechSeed = bot:GetAbilityByName("treant_leech_seed")
local LivingArmor = bot:GetAbilityByName("treant_living_armor")
local NaturesGuise = bot:GetAbilityByName("treant_natures_guise")
local Overgrowth = bot:GetAbilityByName("treant_overgrowth")

local NaturesGraspDesire = 0
local LeechSeedDesire = 0
local LivingArmorDesire = 0
local OvergrowthDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	OvergrowthDesire = UseOvergrowth()
	if OvergrowthDesire > 0 then
		bot:Action_UseAbility(Overgrowth)
		return
	end
	
	LeechSeedDesire, LeechSeedTarget = UseLeechSeed()
	if LeechSeedDesire > 0 then
		bot:Action_UseAbilityOnEntity(LeechSeed, LeechSeedTarget)
		return
	end
	
	NaturesGraspDesire, NaturesGraspTarget = UseNaturesGrasp()
	if NaturesGraspDesire > 0 then
		bot:Action_UseAbilityOnLocation(NaturesGrasp, NaturesGraspTarget)
		return
	end
	
	LivingArmorDesire, LivingArmorTarget = UseLivingArmor()
	if LivingArmorDesire > 0 then
		bot:Action_UseAbilityOnEntity(LivingArmor, LivingArmorTarget)
		return
	end
end

function UseNaturesGrasp()
	if not NaturesGrasp:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = NaturesGrasp:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseLeechSeed()
	if not LeechSeed:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LeechSeed:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if P.IsRetreating(bot) then
		local closetarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, closetarget
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

function UseLivingArmor()
	if not LivingArmor:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local listallies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local allies = {}
	for v, ally in pairs(listallies) do
		if not ally:HasModifier("modifier_treant_living_armor") then
			table.insert(allies, ally)
		end
	end
	local listbuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS)
	local buildings = {}
	for v, building in pairs(listbuildings) do
		if not building:HasModifier("modifier_treant_living_armor") then
			table.insert(buildings, building)
		end
	end
	local ancient = GetAncient(bot:GetTeam())
	
	local target = nil
	
	target = P.GetWeakestAllyHero(allies)
	
	if target == nil and ancient:GetHealth() <= (ancient:GetMaxHealth() * 0.90) and not ancient:HasModifier("modifier_treant_living_armor") then
		target = ancient
	end
	
	if target == nil then
		local weakestbuilding = nil
		local lowesthealth = 99999

		for v, building in pairs(buildings) do
		--	if string.find(hMinionUnit:GetUnitName(), "tower") or string.find(hMinionUnit:GetUnitName(), "barracks") then
				if building:GetHealth() <= (building:GetMaxHealth() * 0.90) then
					if building:GetHealth() < lowesthealth then
						weakestbuilding = building
						lowesthealth = building:GetHealth()
					end
				end
		--	end
		end
		
		target = weakestbuilding
	end
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseOvergrowth()
	if not Overgrowth:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Overgrowth:GetSpecialValueInt("radius")
	local enemies = bot:GetNearbyHeroes(CastRange - 100, true, BOT_MODE_NONE)
	local trueenemies = P.FilterEnemiesForStun(enemies)
	
	if #trueenemies >= 2 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end