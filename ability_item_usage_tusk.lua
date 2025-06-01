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

local IceShards = bot:GetAbilityByName("tusk_ice_shards")
local Snowball = bot:GetAbilityByName("tusk_snowball")
local TagTeam = bot:GetAbilityInSlot(2)
local WalrusPunch = bot:GetAbilityByName("tusk_walrus_punch")
local LaunchSnowball = bot:GetAbilityByName("tusk_launch_snowball")

local IceShardsDesire = 0
local SnowballDesire = 0
local TagTeamDesire = 0
local WalrusPunchDesire = 0
local LaunchSnowballDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	LaunchSnowballDesire = UseLaunchSnowball()
	if LaunchSnowballDesire > 0 then
		--print("Launching snowball")
		bot:Action_UseAbility(LaunchSnowball)
		return
	end
	
	WalrusPunchDesire, WalrusPunchTarget = UseWalrusPunch()
	if WalrusPunchDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(WalrusPunch, WalrusPunchTarget)
		return
	end
	
	TagTeamDesire = UseTagTeam()
	if TagTeamDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(TagTeam)
		return
	end
	
	SnowballDesire, SnowballTarget = UseSnowball()
	if SnowballDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Snowball, SnowballTarget)
		return
	end
	
	IceShardsDesire, IceShardsTarget = UseIceShards()
	if IceShardsDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(IceShards, IceShardsTarget)
		return
	end
end

function UseIceShards()
	if not IceShards:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = IceShards:GetCastRange()
	local CastPoint = IceShards:GetCastPoint()
	local Speed = IceShards:GetSpecialValueInt("shard_speed")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and PAF.IsChasing(bot, BotTarget) then
				local ExtrapNum = (CastPoint + (GetUnitToUnitDistance(bot, BotTarget) / Speed))
			
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation((ExtrapNum + 2))
			end
		end
	end
	
	return 0
end

function UseSnowball()
	if not Snowball:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Snowball:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

--[[function UseTagTeam()
	if not TagTeam:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = TagTeam:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1200 then
				local NearbyAllies = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
				local FilteredAllies = PAF.FilterTrueUnits(NearbyAllies)
				
				if #FilteredAllies > 1 then
					local HighestDPSHero = nil
					local HighestDPS = 0
					
					for v, Ally in pairs(FilteredAllies) do
						if Ally ~= bot then
							if PAF.GetAttackDPS(Ally) > HighestDPS then
								HighestDPS = PAF.GetAttackDPS(Ally)
								HighestDPSHero = Ally
							end
						end
					end
					
					if HighestDPSHero ~= nil then
						return BOT_ACTION_DESIRE_HIGH, HighestDPSHero
					end
				end
			end
		end
	end
	
	return 0
end]]--

function UseTagTeam()
	if not TagTeam:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = TagTeam:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= Radius then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseWalrusPunch()
	if not WalrusPunch:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = WalrusPunch:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseLaunchSnowball()
	if LaunchSnowball:IsHidden() then return 0 end
	
	return BOT_ACTION_DESIRE_ABSOLUTE
end