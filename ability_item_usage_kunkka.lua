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

local Torrent = bot:GetAbilityByName("kunkka_torrent")
local Tidebringer = bot:GetAbilityByName("kunkka_tidebringer")
local XMarksTheSpot = bot:GetAbilityByName("kunkka_x_marks_the_spot")
local Ghostship = bot:GetAbilityByName("kunkka_ghostship")
local XMTSReturn = bot:GetAbilityByName("kunkka_return")
local TorrentStorm = bot:GetAbilityByName("kunkka_torrent_storm")
local TidalWave = bot:GetAbilityByName("kunkka_tidal_wave")

local TorrentDesire = 0
local TidebringerDesire = 0
local XMarksTheSpotDesire = 0
local GhostshipDesire = 0
local XMTSReturnDesire = 0
local TorrentStormDesire = 0
local TidalWaveDesire = 0

-- Combo Desires
local XMarksComboDesire = 0
local TorrentComboDesire = 0

local AttackRange
local BotTarget
local AttackRange = 0

local XMarksTime = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + Torrent:GetManaCost()
	manathreshold = manathreshold + XMarksTheSpot:GetManaCost()
	manathreshold = manathreshold + Ghostship:GetManaCost()
	
	-- The order to use abilities in
	if (DotaTime() - XMarksTime) >= 1.9 then
		if not XMTSReturn:IsHidden() then
			bot:Action_UseAbility(XMTSReturn)
			XMarksTime = 0
		end
	end
	
	XMarksComboDesire, XMarksComboTarget = UseXMarksCombo()
	if XMarksComboDesire > 0 then
		bot:Action_ClearActions(false)
		local XMarksCastPoint = XMarksTheSpot:GetCastPoint()
		XMarksTime = DotaTime()
		
		bot:ActionQueue_UseAbilityOnEntity(XMarksTheSpot, XMarksComboTarget)
		bot:ActionQueue_UseAbilityOnLocation(Torrent, XMarksComboTarget:GetExtrapolatedLocation(XMarksCastPoint))
		bot:ActionQueue_UseAbilityOnLocation(Ghostship, XMarksComboTarget:GetExtrapolatedLocation(XMarksCastPoint))
		return
	end
	
	if not CanCastXMarksCombo() then
		TorrentComboDesire, TorrentComboTarget = UseXMarksCombo()
		if TorrentComboDesire > 0 then
			bot:Action_ClearActions(false)
			local XMarksCastPoint = XMarksTheSpot:GetCastPoint()
			XMarksTime = DotaTime()
			
			bot:ActionQueue_UseAbilityOnEntity(XMarksTheSpot, TorrentComboTarget)
			bot:ActionQueue_UseAbilityOnLocation(Torrent, TorrentComboTarget:GetExtrapolatedLocation(XMarksCastPoint))
			return
		end
	end
	
	TorrentStormDesire, TorrentStormTarget = UseTorrentStorm()
	if TorrentStormDesire > 0 then
		bot:Action_UseAbilityOnLocation(TorrentStorm, TorrentStormTarget)
		return
	end
	
	TidalWaveDesire, TidalWaveTarget = UseTidalWave()
	if TidalWaveDesire > 0 then
		bot:Action_UseAbilityOnLocation(TidalWave, TidalWaveTarget)
		return
	end
	
	if XMTSReturn:IsHidden() then
		GhostshipDesire, GhostshipTarget = UseGhostship()
		if GhostshipDesire > 0 then
			bot:Action_UseAbilityOnLocation(Ghostship, GhostshipTarget)
			return
		end
	
		TorrentDesire, TorrentTarget = UseTorrent()
		if TorrentDesire > 0 then
			bot:Action_UseAbilityOnLocation(Torrent, TorrentTarget)
			return
		end
	end
end

function UseXMarksCombo()
	if not CanCastTorrentCombo() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ComboCastRange = XMarksTheSpot:GetCastRange()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= ComboCastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseTorrent()
	if not Torrent:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Torrent:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = Torrent:GetCastPoint()
	local TorrentDelay = Torrent:GetSpecialValueInt("delay")
	local ExtrapLoc = (CastPoint + TorrentDelay)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
		end
	end
	
	if PAF.IsEngaging(bot) and not CanCastXMarksCombo() and not CanCastTorrentCombo() then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				if GetUnitToLocationDistance(bot, BotTarget:GetExtrapolatedLocation(ExtrapLoc)) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(BotTarget:GetExtrapolatedLocation(ExtrapLoc), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(ExtrapLoc)
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetExtrapolatedLocation(ExtrapLoc)
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local Neutrals = bot:GetNearbyNeutralCreeps(CastRange)
	
		if AttackTarget ~= nil 
		and AttackTarget:IsCreep() 
		and #Neutrals >= 2
		and (bot:GetMana() - Torrent:GetManaCost()) > manathreshold
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetExtrapolatedLocation(ExtrapLoc)
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseTidebringer()
	if not Tidebringer:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if Tidebringer:GetAutoCastState() == false then
		Tidebringer:ToggleAutoCast()
	end
	
	return 0
end

function UseGhostship()
	if not Ghostship:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if CanCastXMarksCombo() then return 0 end
	
	local CR = Ghostship:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH, BotTarget:GetLocation()
		end
	end
	
	return 0
end

function UseTorrentStorm()
	if not TorrentStorm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = TorrentStorm:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = TorrentStorm:GetSpecialValueInt("torrent_max_distance")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	return 0
end

function UseTidalWave()
	if not TidalWave:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = TidalWave:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Distance = TidalWave:GetSpecialValueInt("knockback_distance")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (Distance / 2) then
				return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(PAF.GetFountainLocation(bot), CastRange)
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
	end
	
	return 0
end

function CanCastXMarksCombo()
	if Torrent:IsFullyCastable()
	and XMarksTheSpot:IsFullyCastable()
	and Ghostship:IsFullyCastable() then
		local TotalManaCost = 0
		
		TotalManaCost = (TotalManaCost + Torrent:GetManaCost())
		TotalManaCost = (TotalManaCost + XMarksTheSpot:GetManaCost())
		TotalManaCost = (TotalManaCost + Ghostship:GetManaCost())
		
		if bot:GetMana() > TotalManaCost then
			return true
		end
	end
	
	return false
end

function CanCastTorrentCombo()
	if Torrent:IsFullyCastable()
	and XMarksTheSpot:IsFullyCastable() then
		local TotalManaCost = 0
		
		TotalManaCost = (TotalManaCost + Torrent:GetManaCost())
		TotalManaCost = (TotalManaCost + XMarksTheSpot:GetManaCost())
		
		if bot:GetMana() > TotalManaCost then
			return true
		end
	end
	
	return false
end