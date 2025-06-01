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

local HellfireBlast = bot:GetAbilityByName("skeleton_king_hellfire_blast")
local BoneGuard = bot:GetAbilityInSlot(1)
local MortalStrike = bot:GetAbilityByName("skeleton_king_mortal_strike")
local Reincarnation = bot:GetAbilityByName("skeleton_king_reincarnation")

local HellfireBlastDesire = 0
local VampiricAuraDesire = 0

local AttackRange
local BotTarget
local AttackTarget
local ManaThreshold
local ReincarnationMC = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = (100 + HellfireBlast:GetManaCost() + BoneGuard:GetManaCost())
	
	if Reincarnation:IsTrained() then
		ReincarnationMC = Reincarnation:GetManaCost()
	else
		ReincarnationMC = 0
	end
	
	-- The order to use abilities in
	HellfireBlastDesire, HellfireBlastTarget = UseHellfireBlast()
	if HellfireBlastDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(HellfireBlast, HellfireBlastTarget)
		return
	end
	
	BoneGuardDesire = UseBoneGuard()
	if BoneGuardDesire > 0 then
		bot:Action_UseAbility(BoneGuard)
		return
	end
end

function UseHellfireBlast()
	if not HellfireBlast:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if (bot:GetMana() - HellfireBlast:GetManaCost()) < ReincarnationMC then return 0 end
	
	local CR = HellfireBlast:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Damage = HellfireBlast:GetSpecialValueInt("damage")
	local BurnDamage = HellfireBlast:GetSpecialValueInt("blast_dot_damage")
	local StunDuration = HellfireBlast:GetSpecialValueFloat("blast_stun_duration")
	local TotalDamage = ((BurnDamage * StunDuration) + Damage)
	local DamageType = HellfireBlast:GetDamageType()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if Enemy:IsChanneling() or PAF.CanDamageKillEnemy(Enemy, TotalDamage, DamageType) then
			return 1, Enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				if not PAF.IsDisabled(BotTarget) then
					return 1, BotTarget
				else
					local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1600, true, BOT_MODE_NONE)
					local FilteredUnits = PAF.FilterExceptedUnit(EnemiesWithinRange, BotTarget)
					
					local StrongestEnemy = PAF.GetStrongestPowerUnit(FilteredUnits)
					
					if StrongestEnemy ~= nil
					and not PAF.IsDisabled(StrongestEnemy)
					and GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
						return 1, StrongestEnemy
					end
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local StrongestEnemy = PAF.GetStrongestPowerUnit(EnemiesWithinCastRange)
		
		if StrongestEnemy ~= nil then
			return 1, StrongestEnemy
		end
	end
	
	local NearbyAlliedTowers = bot:GetNearbyTowers(1600, false)
	
	for x, Tower in pairs(NearbyAlliedTowers) do
		local TowerTarget = Tower:GetAttackTarget()
		
		if PAF.IsValidHeroAndNotIllusion(TowerTarget)
		and not PAF.IsMagicImmune(TowerTarget)
		and not PAF.IsDisabled(TowerTarget) then
			return 1, TowerTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	return 0
end

function UseBoneGuard()
	if not BoneGuard:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if (bot:GetMana() - BoneGuard:GetManaCost()) < ReincarnationMC then return 0 end
	
	local modifier = bot:GetModifierByName("modifier_skeleton_king_bone_guard")
	local skeletoncharges = bot:GetModifierStackCount(modifier)
	local maxcharges = BoneGuard:GetSpecialValueInt("max_skeleton_charges")

	if skeletoncharges >= maxcharges then
		if PAF.IsInTeamFight(bot) then
			return BOT_ACTION_DESIRE_HIGH
		end
		
		if PAF.IsInCreepAttackingMode(bot) then
			if PAF.IsValidCreepTarget(AttackTarget) then
				if AttackTarget:GetTeam() ~= bot:GetTeam() then
					return 1
				end
			end
		end
	end
	
	return 0
end