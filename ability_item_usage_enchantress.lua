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

local Impetus = bot:GetAbilityByName("enchantress_impetus")
local Enchant = bot:GetAbilityByName("enchantress_enchant")
local NaturesAttendants = bot:GetAbilityByName("enchantress_natures_attendants")
local Untouchable = bot:GetAbilityByName("enchantress_untouchable")
local LittleFriends = bot:GetAbilityByName("enchantress_little_friends") -- Scepter
local Sproink = bot:GetAbilityByName("enchantress_bunny_hop") -- Shard

local ImpetusDesire = 0
local EnchantDesire = 0
local NaturesAttendantsDesire = 0
local LittleFriendsDesire = 0
local SproinkDesire = 0

local AttackRange
local BotTarget

bot.DominatedUnitOne = nil
bot.DominatedUnitTwo = nil
bot.DominatedUnitOneHeartbeat = -90
bot.DominatedUnitTwoHeartbeat = -90

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- Enchantress can't fetch the units she controls directly, so we're using a heartbeat system
	-- to keep track of alive dominated creeps
	if (DotaTime() - bot.DominatedUnitOneHeartbeat) > 3 then
		bot.DominatedUnitOne = nil
	end
	if (DotaTime() - bot.DominatedUnitTwoHeartbeat) > 3 then
		bot.DominatedUnitTwo = nil
	end
	
	-- The order to use abilities in
	SproinkDesire = UseSproink()
	if SproinkDesire > 0 then
		bot:Action_UseAbility(Sproink)
		return
	end
	
	LittleFriendsDesire, LittleFriendsTarget = UseLittleFriends()
	if LittleFriendsDesire > 0 then
		bot:Action_UseAbilityOnEntity(LittleFriends, LittleFriendsTarget)
		return
	end
	
	NaturesAttendantsDesire = UseNaturesAttendants()
	if NaturesAttendantsDesire > 0 then
		bot:Action_UseAbility(NaturesAttendants)
		return
	end
	
	EnchantDesire, EnchantTarget = UseEnchant()
	if EnchantDesire > 0 then
		bot:Action_UseAbilityOnEntity(Enchant, EnchantTarget)
		return
	end
	
	ImpetusDesire, ImpetusTarget = UseImpetus()
	if ImpetusDesire > 0 then
		bot:Action_UseAbilityOnEntity(Impetus, ImpetusTarget)
		return
	end
end

function UseImpetus()
	if not Impetus:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsHero()
		or PAF.IsRoshan(AttackTarget)
		or PAF.IsTormentor(AttackTarget) then
			if Impetus:GetAutoCastState() == false then
				Impetus:ToggleAutoCast()
				return 0
			else
				return 0
			end
		end
	end
	
	if Impetus:GetAutoCastState() == true then
		Impetus:ToggleAutoCast()
		return 0
	end
	
	return 0
end

function UseEnchant()
	if not Enchant:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Enchant:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local Cooldown = Enchant:GetSpecialValueInt("AbilityCooldown")
	local DominateDuration = Enchant:GetSpecialValueInt("dominate_duration")
	local CreepMaxLevel = Enchant:GetSpecialValueInt("level_req")
	
	--[[local NearbyCreeps = bot:GetNearbyCreeps(1600, false)
	for v, Creep in pairs(NearbyCreeps) do
		if bot.UnitOne == Creep or bot.UnitTwo == Creep then
			if Creep:GetRemainingLifespan() <= Cooldown then
				return BOT_ACTION_DESIRE_ABSOLUTE, Creep
			end
		end	
	end]]--
	
	if bot.DominatedUnitOne == nil
	or (bot:HasScepter() and bot.DominatedUnitTwo == nil) then
		local NeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
		local ViableCreeps = {}
		
		if #NeutralCreeps > 0 then
			for v, Creep in pairs(NeutralCreeps) do
				if not Creep:IsAncientCreep() then
					if Creep:GetLevel() <= CreepMaxLevel
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

function UseNaturesAttendants()
	if not NaturesAttendants:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local WispCount = NaturesAttendants:GetSpecialValueInt("wisp_count")
	local HealRadius = NaturesAttendants:GetSpecialValueInt("radius")
	local HealValue = NaturesAttendants:GetSpecialValueInt("heal")
	local HealDuration = NaturesAttendants:GetSpecialValueInt("heal_duration")
	local TotalNAHeal = ((HealValue * WispCount) * HealDuration)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(HealRadius, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		local HPRegen = Ally:GetHealthRegen()
		local HPRegenTotalHeal = (HPRegen * HealDuration)
		local TotalHeal = (TotalNAHeal + HPRegenTotalHeal)
		
		if Ally:GetHealth() < (Ally:GetMaxHealth() - TotalHeal) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if PAF.IsInTeamFight(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseSproink()
	if not Sproink:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	if not P.IsRetreating(bot) then
		for v, proj in pairs(projectiles) do
			if GetUnitToLocationDistance(bot, proj.location) <= 200
			and proj.is_dodgeable
			and proj.is_attack == false then
				return BOT_ACTION_DESIRE_ABSOLUTE
			end
		end
	end
	
	return 0
end

function UseLittleFriends()
	if not LittleFriends:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LittleFriends:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
	
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_ABSOLUTE, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_ABSOLUTE, ClosestTarget
	end
	
	return 0
end