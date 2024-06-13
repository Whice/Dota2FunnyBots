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
local Riptide = bot:GetAbilityByName("naga_siren_rip_tide")
local SongOfTheSiren = bot:GetAbilityByName("naga_siren_song_of_the_siren")

local MirrorImageDesire = 0
local EnsnareDesire = 0
local SongOfTheSirenDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	SongOfTheSirenDesire, SongOfTheSirenTarget = UseSongOfTheSiren()
	if SongOfTheSirenDesire > 0 then
		bot:Action_UseAbility(SongOfTheSiren)
		return
	end
	
	MirrorImageDesire, MirrorImageTarget = UseMirrorImage()
	if MirrorImageDesire > 0 then
		bot:Action_UseAbility(MirrorImage)
		return
	end
	
	EnsnareDesire, EnsnareTarget = UseEnsnare()
	if EnsnareDesire > 0 then
		bot:Action_UseAbilityOnEntity(Ensnare, EnsnareTarget)
		return
	end
end

function UseMirrorImage()
	if not MirrorImage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return BOT_ACTION_DESIRE_HIGH, BotTarget
		end
	end
	
	local attacktarget = bot:GetAttackTarget()
	
	if attacktarget ~= nil then
		if attacktarget:IsBuilding() then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		if attacktarget ~= nil and attacktarget:IsCreep() then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if attacktarget ~= nil and PAF.IsRoshan(attacktarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseEnsnare()
	if not Ensnare:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Ensnare:GetCastRange()
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

function UseSongOfTheSiren()
	if not SongOfTheSiren:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = SongOfTheSiren:GetSpecialValueInt("radius")
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if P.IsRetreating(bot) and #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end