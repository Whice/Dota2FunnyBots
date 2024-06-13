local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local bot = GetBot()

local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
local DireBase = Vector(6977.84, 5797.69, 1357.99)
local team = bot:GetTeam()

local DispelMagicDesire = 0
local CycloneDesire = 0
local WindWalkDesire = 0
local HurlBoulderDesire = 0
local AstralPulseDesire = 0
local AttackDesire = 0
local MoveDesire = 0
local RetreatDesire = 0
local radius = 1000

function MinionThink(  hMinionUnit ) 
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then 
		if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_storm") then
			if (hMinionUnit:IsUsingAbility()) then return end
			
			DispelMagic = hMinionUnit:GetAbilityByName("brewmaster_storm_dispel_magic")
			Cyclone = hMinionUnit:GetAbilityByName("brewmaster_storm_cyclone")
			WindWalk = hMinionUnit:GetAbilityByName("brewmaster_storm_wind_walk")
			
			DispelMagicDesire, DispelMagicTarget = UseDispelMagic(hMinionUnit)
			if DispelMagicDesire > 0 then
				hMinionUnit:Action_UseAbilityOnLocation(DispelMagic, DispelMagicTarget)
				return
			end
			
			CycloneDesire, CycloneTarget = UseCyclone(hMinionUnit)
			if CycloneDesire > 0 then
				hMinionUnit:Action_UseAbilityOnEntity(Cyclone, CycloneTarget)
				return
			end
			
			WindWalkDesire, WindWalkTarget = UseWindWalk(hMinionUnit)
			if WindWalkDesire > 0 then
				hMinionUnit:Action_UseAbility(WindWalk)
				return
			end
			
			hMinionUnit:Action_AttackUnit(AttackUnits(hMinionUnit), false)
			
		end
		
		if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_earth") then
			
			if (hMinionUnit:IsUsingAbility()) then return end
			
			HurlBoulder = hMinionUnit:GetAbilityByName("brewmaster_earth_hurl_boulder")
			
			HurlBoulderDesire, HurlBoulderTarget = UseHurlBoulder(hMinionUnit)
			if HurlBoulderDesire > 0 then
				hMinionUnit:Action_UseAbilityOnEntity(HurlBoulder, HurlBoulderTarget)
				return
			end
			
			if hMinionUnit:GetHealth() <= hMinionUnit:GetMaxHealth() * 0.3 then
				if team == TEAM_RADIANT then
					hMinionUnit:Action_MoveToLocation(RadiantBase)
				elseif team == TEAM_DIRE then
					hMinionUnit:Action_MoveToLocation(DireBase)
				end
				
				return
			end
			
			if AttackUnits(hMinionUnit) ~= nil then
				hMinionUnit:Action_AttackUnit(AttackUnits(hMinionUnit), false)
			else
				hMinionUnit:Action_MoveToLocation(bot:GetLocation())
			end
			
		end
		
		if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_fire") then
			
			hMinionUnit:Action_AttackUnit(AttackUnits(hMinionUnit), false)
			
		end
		
		if string.find(hMinionUnit:GetUnitName(), "npc_dota_brewmaster_void") then
			
			if (hMinionUnit:IsUsingAbility()) then return end
			
			AstralPull = hMinionUnit:GetAbilityByName("brewmaster_void_astral_pull")
			
			AstralPullDesire, AstralPullTarget = UseAstralPull(hMinionUnit)
			if AstralPullDesire > 0 then
				hMinionUnit:Action_UseAbility(AstralPull)
				return
			end
			
			hMinionUnit:Action_AttackUnit(AttackUnits(hMinionUnit), false)
			
		end
		
		if hMinionUnit:IsIllusion() then
			hMinionUnit:Action_AttackUnit(AttackUnits(hMinionUnit), false)
		end
	end
end

function AttackUnits(hMinionUnit)
    local enemies = hMinionUnit:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local target = nil
	
	if GetUnitToUnitDistance(hMinionUnit, bot) > 1600 then
		target = nil
		return target
	end
	
	if #enemies >= 1 then
		target = P.GetWeakestEnemyHero(enemies)
	end
	
	if #enemies <= 0 then
		enemies = hMinionUnit:GetNearbyLaneCreeps(1600, true)
	end
	
	if #enemies <= 0 then
		enemies = hMinionUnit:GetNearbyBarracks(1600, true)
	end
	
	if #enemies <= 0 then
		enemies = hMinionUnit:GetNearbyTowers(1600, true)
	end
	
	if target == nil and #enemies >= 1 then
		target = enemies[1]
	end
	
	if target ~= nil and not target:IsAttackImmune() and not target:IsInvulnerable() then
		return target
	end
	
	return target
end

function UseDispelMagic(hMinionUnit)
	if not DispelMagic:IsFullyCastable() then return 0, nil end
	if P.CantUseAbility(hMinionUnit) then return 0, nil end
	
	local CastRange = DispelMagic:GetCastRange()
	local Radius = DispelMagic:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, hMinionUnit:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
	end
	
	return 0, nil
end

function UseCyclone(hMinionUnit)
	if not Cyclone:IsFullyCastable() then return 0, nil end
	if P.CantUseAbility(hMinionUnit) then return 0, nil end
	
	local CastRange = Cyclone:GetCastRange()
	
	local enemies = hMinionUnit:GetNearbyHeroes(CastRange + 500, true, BOT_MODE_NONE)
	local filteredenemies = P.FilterEnemiesForStun(enemies)
	local target = nil
	
	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) and enemy:IsChanneling() and P.IsNotImmune(enemy) then
			target = enemy
			break
		end
	end
	
	if target == nil and #filteredenemies >= 2 then
		target = P.GetStrongestEnemyHero(filteredenemies)
	end
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0, nil
end

function UseWindWalk(hMinionUnit)
	if not WindWalk:IsFullyCastable() then return 0, nil end
	if DispelMagic:IsFullyCastable() then return 0, nil end
	if Cyclone:IsFullyCastable() then return 0 , nil end
	if P.CantUseAbility(hMinionUnit) then return 0, nil end
	
	return BOT_ACTION_DESIRE_HIGH
end

function UseHurlBoulder(hMinionUnit)
	if not HurlBoulder:IsFullyCastable() then return 0, nil end
	if P.CantUseAbility(hMinionUnit) then return 0, nil end
	
	local CastRange = HurlBoulder:GetCastRange()
	
	local enemies = hMinionUnit:GetNearbyHeroes(CastRange + 500, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0, nil
end

function UseAstralPull(hMinionUnit)
	if not AstralPull:IsFullyCastable() then return 0, nil end
	if P.CantUseAbility(hMinionUnit) then return 0, nil end
	
	local SearchRange = 800
	
	local enemies = hMinionUnit:GetNearbyHeroes(SearchRange, true, BOT_MODE_NONE)
	
	for v, enemy in pairs(enemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	return 0, nil
end
