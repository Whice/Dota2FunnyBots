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

local MirrorImage = bot:GetAbilityByName("naga_siren_mirror_image")
local Ensnare = bot:GetAbilityByName("naga_siren_ensnare")
local Riptide = bot:GetAbilityInSlot(2) -- Actually Deluge now xd
local SongOfTheSiren = bot:GetAbilityByName("naga_siren_song_of_the_siren")

local MirrorImageDesire = 0
local EnsnareDesire = 0
local RipetideDesire = 0
local SongOfTheSirenDesire = 0

local AttackRange
local BotTarget
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = 100
	
	for x = 5, 1, -1 do
		local hAbility = bot:GetAbilityInSlot(x)
		if hAbility ~= nil
		and hAbility:IsTrained()
		and not hAbility:IsHidden() then
			local nManaCost = hAbility:GetManaCost()
			
			if nManaCost > 0 then
				ManaThreshold = (ManaThreshold + nManaCost)
			end
		end
	end
	
	-- The order to use abilities in
	--[[RiptideDesire = UseRiptide()
	if RiptideDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Riptide)
		return
	end]]--
	
	SongOfTheSirenDesire, SongOfTheSirenTarget = UseSongOfTheSiren()
	if SongOfTheSirenDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(SongOfTheSiren)
		return
	end
	
	MirrorImageDesire = UseMirrorImage()
	if MirrorImageDesire > 0 then
		PAF.SwitchTreadsToAgi(bot)
		bot:ActionQueue_UseAbility(MirrorImage)
		return
	end
	
	EnsnareDesire, EnsnareTarget = UseEnsnare()
	if EnsnareDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Ensnare, EnsnareTarget)
		return
	end
end

function UseMirrorImage()
	if not MirrorImage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ManaCost = MirrorImage:GetManaCost()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return 1, BotTarget
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam()
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				if AttackTarget:IsCreep()
				or AttackTarget:IsBuilding() then
					return 1
				end
			end
		end
	end
	
	return 0
end

function UseEnsnare()
	if not Ensnare:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Ensnare:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsReflectingSpells(BotTarget) then
				if not PAF.IsDisabled(BotTarget) then
					return 1, BotTarget
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local StrongestEnemy = PAF.GetStrongestPowerUnit(EnemiesWithinCastRange)
		
		if StrongestEnemy ~= nil
		and not PAF.IsMagicImmune(StrongestEnemy)
		and not PAF.IsReflectingSpells(StrongestEnemy) then
			return 1, StrongestEnemy
		end
	end
	
	local NearbyAlliedTowers = bot:GetNearbyTowers(1600, false)
	
	for x, Tower in pairs(NearbyAlliedTowers) do
		local TowerTarget = Tower:GetAttackTarget()
		
		if PAF.IsValidHeroAndNotIllusion(TowerTarget)
		and not PAF.IsMagicImmune(TowerTarget)
		and not PAF.IsDisabled(TowerTarget)
		and not PAF.IsReflectingSpells(TowerTarget) then
			return 1, TowerTarget
		end
	end
	
	return 0
end

function UseRiptide()
	if not Riptide:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Riptide:GetSpecialValueInt("radius")
	
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

function UseSongOfTheSiren()
	if not SongOfTheSiren:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1200, true, BOT_MODE_NONE)
		
		if #EnemiesWithinRange >= 1 then
			if bot:GetHealth() <= (bot:GetMaxHealth() * 0.25) then
				return 1
			end
		end
	end
	
	return 0
end