------------------------------
-- CREATED BY: MANSLAUGHTER --
------------------------------

local bot = GetBot()
if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() then return end

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

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

local FrostArrows = bot:GetAbilityByName("drow_ranger_frost_arrows")
local Gust = bot:GetAbilityByName("drow_ranger_wave_of_silence")
local Multishot = bot:GetAbilityByName("drow_ranger_multishot")
local Marksmanship = bot:GetAbilityByName("drow_ranger_marksmanship")

local FrostArrowsDesire = 0
local GustDesire = 0
local MultishotDesire = 0

local AttackRange = 0
local manathreshold = 0

function AbilityUsageThink()
	
	manathreshold = (bot:GetMaxMana() * 0.4)
	
	if FrostArrows:GetAutoCastState() == false then
		FrostArrows:ToggleAutoCast()
	end
	
	-- The order to use abilities in
	MultishotDesire, MultishotTarget = UseMultishot()
	if MultishotDesire > 0 then
		bot:Action_UseAbilityOnLocation(Multishot, MultishotTarget)
		return
	end
	
	GustDesire, GustTarget = UseGust()
	if GustDesire > 0 then
		bot:Action_UseAbilityOnLocation(Gust, GustTarget)
		return
	end
	
	if bot:GetActiveMode() ~= BOT_MODE_SIDE_SHOP then
		FrostArrowsDesire, FrostArrowsTarget = UseFrostArrows()
		if FrostArrowsDesire > 0 then
			bot:Action_UseAbilityOnEntity(FrostArrows, FrostArrowsTarget)
			return
		end
	end
end

function UseFrostArrows()
--[[	if not FrostArrows:IsFullyCastable() or bot:IsDisarmed() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then return 0 end
	
	local CastRange = FrostArrows:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 50, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil and not target:IsAttackImmune() and not P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, target
	end]]--
	
	return 0
end

function UseGust()
	if not Gust:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Gust:GetCastRange() + 100
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local filteredenemies = P.FilterEnemiesForStun(enemies)
	local target = nil
	
	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) and enemy:IsChanneling() and P.IsNotImmune(enemy) then
			target = enemy
			break
		end
	end
	
	if target == nil and #enemies >= 1 then
		if P.IsRetreating(bot) then
			target = P.GetClosestEnemy(bot, enemies)
			
			if target ~= nil then
				if GetUnitToUnitDistance(bot, target) > Gust:GetCastRange() then
					target = nil
				end
			end
		else
			target = P.GetWeakestEnemyHero(enemies)
			
			if target ~= nil and P.IsPDisabled(target) then
				target = P.GetStrongestEnemyHero(filteredenemies)
			end
		end
	end
	
	if target ~= nil and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	return 0
end

function UseMultishot()
	if not Multishot:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 1000
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil and #enemies >= 2 then
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 and (bot:GetMana() - Multishot:GetManaCost()) > manathreshold then
			local weakestneutral = nil
			local smallesthealth = 99999
		
			for v, neutral in pairs(neutrals) do
				if neutral ~= nil and neutral:CanBeSeen() then
					if neutral:GetHealth() < smallesthealth then
						weakestneutral = neutral
						smallesthealth = neutral:GetHealth()
					end
				end
			end
		
			return BOT_ACTION_DESIRE_HIGH, weakestneutral:GetLocation()
		end
	end
	
	return 0
end