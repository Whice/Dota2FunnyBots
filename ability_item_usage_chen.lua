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

local Penitence = bot:GetAbilityByName("chen_penitence")
local HolyPersuasion = bot:GetAbilityByName("chen_holy_persuasion")
local DivineFavor = bot:GetAbilityByName("chen_divine_favor")
local SummonConvert = bot:GetAbilityByName("chen_summon_convert")
local HandOfGod = bot:GetAbilityByName("chen_hand_of_god")

local PenitenceDesire = 0
local HolyPersuasionDesire = 0
local DivineFavorDesire = 0
local SummonConvertDesire = 0
local HandOfGodDesire = 0

local AttackRange
local BotTarget

local PersuadedUnits = {}
local AncientUnits = {}
bot.DominatedUnits = 0
bot.DominatedAncients = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	PersuadedUnits = {}
	AncientUnits = {}
	local AlliedCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS)
	
	for v, Creep in pairs(AlliedCreeps) do
		if Creep:HasModifier("modifier_chen_holy_persuasion") then
			table.insert(PersuadedUnits, Creep)
			
			if Creep:IsAncientCreep() then
				table.insert(AncientUnits, Creep)
			end
		end
	end
	
	bot.DominatedUnits = #PersuadedUnits
	bot.DominatedAncients = #AncientUnits
	
	-- The order to use abilities in
	HandOfGodDesire = UseHandOfGod()
	if HandOfGodDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(HandOfGod)
		return
	end
	
	DivineFavorDesire, DivineFavorTarget = UseDivineFavor()
	if DivineFavorDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(DivineFavor, DivineFavorTarget)
		return
	end
	
	PenitenceDesire, PenitenceTarget = UsePenitence()
	if PenitenceDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Penitence, PenitenceTarget)
		return
	end
	
	SummonConvertDesire = UseSummonConvert()
	if SummonConvertDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(SummonConvert)
		return
	end
	
	HolyPersuasionDesire, HolyPersuasionTarget = UseHolyPersuasion()
	if HolyPersuasionDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(HolyPersuasion, HolyPersuasionTarget)
		return
	end
end

function UsePenitence()
	if not Penitence:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Penitence:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	return 0
end

function UseHolyPersuasion()
	if not HolyPersuasion:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = HolyPersuasion:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local MaxUnits = HolyPersuasion:GetSpecialValueInt("max_units")
	local CreepMaxLevel = HolyPersuasion:GetSpecialValueInt("level_req")
	local AllowedAncients = HandOfGod:GetSpecialValueInt("ancient_creeps_scepter")
	
	if bot.DominatedUnits < MaxUnits or bot.DominatedAncients < AllowedAncients then
		local NeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
		local ViableCreeps = {}
		
		if #NeutralCreeps > 0 then
			for v, Creep in pairs(NeutralCreeps) do
				if bot.DominatedAncients >= AllowedAncients then
					if not Creep:IsAncientCreep() then
						if Creep:GetLevel() <= CreepMaxLevel
						and Creep:GetLevel() >= (CreepMaxLevel - 2) then
							table.insert(ViableCreeps, Creep)
						end
					end
				else
					if Creep:IsAncientCreep()
					and Creep:GetLevel() <= CreepMaxLevel
					and Creep:GetLevel() >= (CreepMaxLevel - 2) then
						table.insert(ViableCreeps, Creep)
					end
				end
			end
			
			if #ViableCreeps > 0 then
				local HighestLevelCreep = nil
				local HighestLevel = 0
				
				for v, Creep in pairs(ViableCreeps) do
					if Creep:GetLevel() > HighestLevel then
						HighestLevelCreep = Creep
						HighestLevel = Creep:GetLevel()
					end
				end
				
				if HighestLevelCreep ~= nil then
					return BOT_ACTION_DESIRE_HIGH, HighestLevelCreep
				end
			end
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseDivineFavor()
	if not DivineFavor:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DivineFavor:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.75)
		and WeakestAlly:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	
	if #PersuadedUnits > 0
	and not bot:WasRecentlyDamagedByAnyHero(3)
	and #EnemiesWithinRange <= 0 then
		for v, Creep in pairs(PersuadedUnits) do
			if GetUnitToUnitDistance(bot, Creep) > 3200 then
				return BOT_ACTION_DESIRE_HIGH, bot
			end
		end
	end
	
	return 0
end

function UseSummonConvert()
	if not SummonConvert:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local MaxUnits = HolyPersuasion:GetSpecialValueInt("max_units")
	
	if bot.DominatedUnits < MaxUnits then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseHandOfGod()
	if not HandOfGod:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	local HealAmount = HandOfGod:GetSpecialValueInt("heal_amount")
	local HealPerSecond = HandOfGod:GetSpecialValueInt("heal_per_second")
	local HealDuration = HandOfGod:GetSpecialValueInt("hot_duration")
	
	for v, Ally in pairs(FilteredAllies) do
		local TotalHeal = (HealAmount + (HealPerSecond * HealDuration))
		
		if PAF.IsInTeamFight(Ally)
		and Ally:GetHealth() < (Ally:GetMaxHealth() - TotalHeal) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

-- Ability Functions --

function HasFlag(value, flag)
	if flag == 0 then return false end
		
	return (math.floor(value / flag) % 2) == 1
end