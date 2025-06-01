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

local Devour = bot:GetAbilityByName("doom_bringer_devour")
local ScorchedEarth = bot:GetAbilityByName("doom_bringer_scorched_earth")
local InfernalBlade = bot:GetAbilityByName("doom_bringer_infernal_blade")
local Doom = bot:GetAbilityByName("doom_bringer_doom")

local CreepAbilityOne = bot:GetAbilityInSlot(3)
local CreepAbilityTwo = bot:GetAbilityInSlot(4)

local DevourDesire = 0
local ScorchedEarthDesire = 0
local InfernalBladeDesire = 0
local DoomDesire = 0

local AttackRange
local BotTarget

local DevourAltCast = false
bot.CreepLevelConsumed = 0

local HasAncientTalent = false

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	--[[if Devour:IsTrained() then
		if bot:IsAlive() then
			if not DevourAltCast and DotaTime() > -60 then
				DevourAltCast = true
				bot:Action_UseAbility(Devour)
				return
			end
		end
	end]]--
	
	--[[if Devour:IsTrained() then
		if bot:IsAlive() then
			if CreepAbilityOne == nil
			or CreepAbilityOne:GetName() == ""
			or CreepAbilityOne:GetName() == "doom_bringer_empty1" then
				if not DevourAltCast then
					DevourAltCast = true
					bot:Action_UseAbility(Devour)
					bot:Action_UseAbility(Devour)
				end
			end
		end
	end]]--
	
	if bot:GetLevel() >= 15 then
		if not HasAncientTalent then
			HasAncientTalent = true
			bot.CreepLevelConsumed = 0
		end
	end
	
	-- The order to use abilities in
	DoomDesire, DoomTarget = UseDoom()
	if DoomDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Doom, DoomTarget)
		return
	end
	
	ScorchedEarthDesire = UseScorchedEarth()
	if ScorchedEarthDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(ScorchedEarth)
		return
	end
	
	DevourDesire, DevourTarget = UseDevour()
	if DevourDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Devour, DevourTarget)
		return
	end
	
	InfernalBladeDesire, InfernalBladeTarget = UseInfernalBlade()
	if InfernalBladeDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(InfernalBlade, InfernalBladeTarget)
		return
	end
	
	if CreepAbilityOne ~= nil and CreepAbilityOne:GetName() ~= "" and not CreepAbilityOne:IsPassive() then
		if PNA.UseNeutralAbility(CreepAbilityOne, bot, bot) == true then
			return
		end
	end
	
	if CreepAbilityTwo ~= nil and CreepAbilityTwo:GetName() ~= "" and not CreepAbilityTwo:IsPassive() then
		if PNA.UseNeutralAbility(CreepAbilityTwo, bot, bot) == true then
			return
		end
	end
end

function UseDevour()
	if not Devour:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	
	local CR = Devour:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local CreepLevel = Devour:GetSpecialValueInt("creep_level")
	
	--[[if CreepAbilityOne == nil
	or CreepAbilityOne:GetName() == ""
	or CreepAbilityOne:GetName() == "doom_bringer_empty1"
	or bot.CreepLevelConsumed < CreepLevel then
		local NeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
		
		for v, Creep in pairs(NeutralCreeps) do
			if HasAncientTalent then
				if Creep:IsAncientCreep() then
					if Creep:GetLevel() == CreepLevel then
						bot.CreepLevelConsumed = Creep:GetLevel()
						return BOT_ACTION_DESIRE_HIGH, Creep
					end
				end
			else
				if not Creep:IsAncientCreep() then
					if Creep:GetLevel() == CreepLevel then
						bot.CreepLevelConsumed = Creep:GetLevel()
						return BOT_ACTION_DESIRE_HIGH, Creep
					end
				end
			end
		end
	else
		local LaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
		
		local CreepTarget = nil
		
		for v, Creep in pairs(LaneCreeps) do
			if Creep:GetLevel() <= CreepLevel then
				if string.find(Creep:GetUnitName(), "siege") then
					CreepTarget = Creep
					break
				elseif string.find(Creep:GetUnitName(), "flagbearer") then
					CreepTarget = Creep
					break
				elseif string.find(Creep:GetUnitName(), "ranged") then
					CreepTarget = Creep
					break
				else
					return BOT_ACTION_DESIRE_HIGH, Creep
				end
			end
		end
		
		if CreepTarget ~= nil then
			return BOT_ACTION_DESIRE_HIGH, CreepTarget
		end
	end]]--
	
	local LaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
		
	for v, Creep in pairs(LaneCreeps) do
		if Creep:GetLevel() <= CreepLevel then
			if string.find(Creep:GetUnitName(), "siege") then
				return BOT_ACTION_DESIRE_HIGH, Creep
			end
		end
	end
	
	for v, Creep in pairs(LaneCreeps) do
		if Creep:GetLevel() <= CreepLevel then
			if string.find(Creep:GetUnitName(), "flagbearer") then
				return BOT_ACTION_DESIRE_HIGH, Creep
			end
		end
	end
	
	for v, Creep in pairs(LaneCreeps) do
		if Creep:GetLevel() <= CreepLevel then
			if string.find(Creep:GetUnitName(), "ranged") then
				return BOT_ACTION_DESIRE_HIGH, Creep
			end
		end
	end
	
	for v, Creep in pairs(LaneCreeps) do
		if Creep:GetLevel() <= CreepLevel then
			return BOT_ACTION_DESIRE_HIGH, Creep
		end
	end
	
	return 0
end

function UseScorchedEarth()
	if not ScorchedEarth:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ScorchedEarth:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot) then
		return 1
	end
	
	if PAF.IsEngaging(bot) then
		if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM and not P.IsInLaningPhase() then
		local NeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
		
		if #NeutralCreeps >= 3 then
			return 1
		end
	end
	
	local NearbyEnemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(NearbyEnemies)
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return 1
	end
	
	return 0
end

function UseInfernalBlade()
	if not InfernalBlade:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsInLaningPhase() then
		local EnemiesWithinRange = bot:GetNearbyHeroes(300, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		local WeakestUnit = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestUnit ~= nil then
			return BOT_ACTION_DESIRE_HIGH, WeakestUnit
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if PAF.IsEngaging(bot)
		or PAF.IsRoshan(AttackTarget)
		or PAF.IsTormentor(AttackTarget) then
			if InfernalBlade:GetAutoCastState() == false then
				InfernalBlade:ToggleAutoCast()
				return 0
			else
				return 0
			end
		end
	end
	
	if InfernalBlade:GetAutoCastState() == true then
		InfernalBlade:ToggleAutoCast()
		return 0
	end
	
	return 0
end

function UseDoom()
	if not Doom:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Doom:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsInTeamFight(bot) then
		local NearbyEnemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(NearbyEnemies)
		
		local StrongestEnemy = PAF.GetStrongestDPSUnit(FilteredEnemies)
		
		if StrongestEnemy ~= nil then
			return 1, StrongestEnemy
		end
	end
	
	return 0
end