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

local WhirlingDeath = bot:GetAbilityByName("shredder_whirling_death")
local TimberChain = bot:GetAbilityByName("shredder_timber_chain")
local ReactiveArmor = bot:GetAbilityByName("shredder_reactive_armor")
local Chakram = bot:GetAbilityByName("shredder_chakram")
--local SecondChakram = bot:GetAbilityByName("shredder_chakram_2")
local Flamethrower = bot:GetAbilityByName("shredder_flamethrower")

local ReturnChakram = bot:GetAbilityByName("shredder_return_chakram")
--local ReturnSecondChakram = bot:GetAbilityByName("shredder_return_chakram_2")

local WhirlingDeathDesire = 0
local TimberChainDesire = 0
local ReactiveArmorDesire = 0
local ChakramDesire = 0
local SecondChakramDesire = 0
local FlamethrowerDesire = 0
local ReturnChakramDesire = 0
local ReturnSecondChakramDesire = 0

local ChakramLoc = nil
local SecondChakramLoc = nil

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = (bot:GetMaxMana() * 0.5)
	
	-- The order to use abilities in
	ReturnChakramDesire = UseReturnChakram()
	if ReturnChakramDesire > 0 then
		bot:Action_UseAbility(ReturnChakram)
		return
	end
	
	--[[ReturnSecondChakramDesire = UseReturnSecondChakram()
	if ReturnSecondChakramDesire > 0 then
		bot:Action_UseAbility(ReturnSecondChakram)
		return
	end]]--
	
	if bot:HasScepter() then
		ReactiveArmorDesire = UseReactiveArmor()
		if ReactiveArmorDesire > 0 then
			bot:Action_UseAbility(ReactiveArmor)
			return
		end
	end
	
	FlamethrowerDesire = UseFlamethrower()
	if FlamethrowerDesire > 0 then
		bot:Action_UseAbility(Flamethrower)
		return
	end
	
	TimberChainDesire, TimberChainTarget = UseTimberChain()
	if TimberChainDesire > 0 then
		bot:Action_UseAbilityOnLocation(TimberChain, TimberChainTarget)
		return
	end
	
	WhirlingDeathDesire = UseWhirlingDeath()
	if WhirlingDeathDesire > 0 then
		bot:Action_UseAbility(WhirlingDeath)
		return
	end
	
	ChakramDesire, ChakramTarget = UseChakram()
	if ChakramDesire > 0 then
		bot:Action_UseAbilityOnLocation(Chakram, ChakramTarget)
		ChakramLoc = ChakramTarget
		return
	end
	
	--[[SecondChakramDesire, SecondChakramTarget = UseSecondChakram()
	if SecondChakramDesire > 0 then
		bot:Action_UseAbilityOnLocation(SecondChakram, SecondChakramTarget)
		SecondChakramLoc = SecondChakramTarget
		return
	end]]--
end

function UseWhirlingDeath()
	if not WhirlingDeath:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = WhirlingDeath:GetSpecialValueInt("whirling_radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= Radius
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsInLaningPhase() or P.IsRetreating(bot) then
		if #FilteredEnemies > 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= Radius then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local NearbyCreeps = bot:GetNearbyCreeps(Radius, true)
		if #NearbyCreeps >= 3 and (bot:GetMana() - WhirlingDeath:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UseTimberChain()
	if not TimberChain:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = TimberChain:GetCastRange()
	local Radius = TimberChain:GetSpecialValueInt("chain_radius")
	local DmgRadius = TimberChain:GetSpecialValueInt("radius")
	
	local NearbyTrees = bot:GetNearbyTrees(CastRange)
	
	if P.IsRetreating(bot) then
		local FountainLoc = PAF.GetFountainLocation(bot)
		
		local FurthestTree = nil
		local FurthestDistance = 0
		for v, Tree in pairs(NearbyTrees) do
			if not IsTreeBetweenMeAndTarget(Tree, Radius, CastRange) then
				local TreeLoc = GetTreeLocation(Tree)
				
				if GetUnitToLocationDistance(bot, TreeLoc) > 500
				and GetUnitToLocationDistance(bot, FountainLoc) > P.GetDistance(TreeLoc, FountainLoc) then
					if GetUnitToLocationDistance(bot, TreeLoc) > FurthestDistance then
						FurthestTree = Tree
						FurthestDistance = GetUnitToLocationDistance(bot, TreeLoc)
					end
				end
				
				if FurthestTree ~= nil
				and (P.GetDistance(TreeLoc, FountainLoc) - GetUnitToLocationDistance(bot, FountainLoc)) >= 500 then
					return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(FurthestTree)
				end
			end
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				local ClosestTree = nil
				local ClosestDistance = 99999
				
				for v, Tree in pairs(NearbyTrees) do
					local TreeLoc = GetTreeLocation(Tree)
				
					if GetUnitToLocationDistance(BotTarget, TreeLoc) < ClosestDistance then
						ClosestTree = Tree
						ClosestDistance = GetUnitToLocationDistance(BotTarget, TreeLoc)
					end
				end
				
				if ClosestTree ~= nil then
					if not IsTreeBetweenMeAndTarget(ClosestTree, Radius, CastRange) then
						local tResult = PointToLineDistance(bot:GetLocation(), GetTreeLocation(ClosestTree), BotTarget:GetLocation())
					
						if (tResult ~= nil
						and tResult.within
						and tResult.distance <= DmgRadius)
						or ClosestDistance <= DmgRadius then
							return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(ClosestTree)
						end
					end
				end
			end
		end
	end
	
	return 0
end

function UseReactiveArmor()
	if not ReactiveArmor:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = ReactiveArmor:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) and GetUnitToUnitDistance(bot, BotTarget) <= Radius then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseChakram()
	if not Chakram:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Chakram:IsHidden() then return 0 end
	
	local CR = Chakram:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local Radius = Chakram:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	if bot:GetActiveMode() == BOT_MODE_FARM
	and AttackTarget ~= nil
	and AttackTarget:IsCreep() then
		local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
		
		for v, Creep in pairs(NearbyCreeps) do
			local AoECount = PAF.GetUnitsNearTarget(Creep:GetLocation(), NearbyCreeps, Radius)
			if AoECount >= 3 and (bot:GetMana() - Chakram:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH, Creep:GetLocation()
			end
		end
	end
	
	return 0
end

function UseSecondChakram()
	if not SecondChakram:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if SecondChakram:IsHidden() then return 0 end
	
	local CR = SecondChakram:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local Radius = SecondChakram:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	if bot:GetActiveMode() == BOT_MODE_FARM
	and AttackTarget ~= nil
	and AttackTarget:IsCreep() then
		local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
		
		for v, Creep in pairs(NearbyCreeps) do
			local AoECount = PAF.GetUnitsNearTarget(Creep:GetLocation(), NearbyCreeps, Radius)
			if AoECount >= 3 and (bot:GetMana() - SecondChakram:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH, Creep:GetLocation()
			end
		end
	end
	
	return 0
end

function UseReturnChakram()
	if not ReturnChakram:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if ReturnChakram:IsHidden() then return 0 end
	
	if IsChakramTraveling(1) then
		return 0
	end
	
	local Radius = Chakram:GetSpecialValueInt("radius")
	local Damage = Chakram:GetSpecialValueInt("pass_damage")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local NearbyCreeps = bot:GetNearbyCreeps(1600, true)
		local NumCreeps = 0
		local NumKillableCreeps = 0
		
		for v, Creep in pairs(NearbyCreeps) do
			if GetUnitToLocationDistance(Creep, ChakramLoc) <= Radius then
				NumCreeps = (NumCreeps + 1)
				
				if Creep:GetHealth() <= Damage then
					NumKillableCreeps = (NumKillableCreeps + 1)
				end
			end
		end
		
		if NumCreeps <= 0 or NumKillableCreeps >= 3 then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	if PAF.IsEngaging(bot) then
		local EnemyIsInsideChakram = false
		local CanKillEnemy = false
		for v, Enemy in pairs(FilteredEnemies) do
			if GetUnitToLocationDistance(Enemy, ChakramLoc) <= Radius then
				if not EnemyIsInsideChakram then
					EnemyIsInsideChakram = true
				end
				
				if Enemy:GetHealth() <= Damage then
					if not CanKillEnemy then
						CanKillEnemy = true
						break
					end
				end
			end
		end
		
		if CanKillEnemy
		or not EnemyIsInsideChakram
		or GetUnitToLocationDistance(bot, ChakramLoc) > 1600 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() ~= BOT_MODE_FARM
	and not PAF.IsEngaging(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseReturnSecondChakram()
	if not ReturnSecondChakram:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if ReturnSecondChakram:IsHidden() then return 0 end
	
	if IsChakramTraveling(2) then
		return 0
	end
	
	local Radius = SecondChakram:GetSpecialValueInt("radius")
	local Damage = SecondChakram:GetSpecialValueInt("pass_damage")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local NearbyCreeps = bot:GetNearbyCreeps(1600, true)
		local NumCreeps = 0
		local NumKillableCreeps = 0
		
		for v, Creep in pairs(NearbyCreeps) do
			if GetUnitToLocationDistance(Creep, SecondChakramLoc) <= Radius then
				NumCreeps = (NumCreeps + 1)
				
				if Creep:GetHealth() <= Damage then
					NumKillableCreeps = (NumKillableCreeps + 1)
				end
			end
		end
		
		if NumCreeps <= 0 or NumKillableCreeps >= 3 then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	if PAF.IsEngaging(bot) then
		local EnemyIsInsideChakram = false
		local CanKillEnemy = false
		for v, Enemy in pairs(FilteredEnemies) do
			if GetUnitToLocationDistance(Enemy, SecondChakramLoc) <= Radius then
				if not EnemyIsInsideChakram then
					EnemyIsInsideChakram = true
				end
				
				if Enemy:GetHealth() <= Damage then
					if not CanKillEnemy then
						CanKillEnemy = true
						break
					end
				end
			end
		end
		
		if CanKillEnemy
		or not EnemyIsInsideChakram
		or GetUnitToLocationDistance(bot, SecondChakramLoc) > 1600 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() ~= BOT_MODE_FARM
	and not PAF.IsEngaging(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseFlamethrower()
	if not Flamethrower:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Flamethrower:GetSpecialValueInt("length")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) 
			and bot:IsFacingLocation(BotTarget:GetLocation(), 10) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange
		and bot:IsFacingLocation(BotTarget:GetLocation(), 10) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	if AttackTarget:IsBuilding()
	and AttackTarget:GetTeam() ~= bot:GetTeam()
	and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange
	and bot:IsFacingLocation(BotTarget:GetLocation(), 10) then
		return BOT_ACTION_DESIRE_VERYHIGH
	end
	
	return 0
end

function IsTreeBetweenMeAndTarget(TargetTree, nRadius, CastRange)
	local vStart = bot:GetLocation()
	local vEnd = GetTreeLocation(TargetTree)
	local Trees = bot:GetNearbyTrees(CastRange)
	
	for v, Tree in pairs(Trees) do
		if Tree ~= TargetTree then
			local tResult = PointToLineDistance(vStart, vEnd, GetTreeLocation(Tree))
			if tResult ~= nil
			and tResult.within
			and tResult.distance <= (nRadius - 25) then
				return true
			end
		end
	end
	
	return false
end

function IsChakramTraveling(nChakram)
	local LinearProjectiles = GetLinearProjectiles()
	
	for v, Projectile in pairs(LinearProjectiles) do
		if Projectile ~= nil
		and ((nChakram == 1 and Projectile.ability:GetName() == "shredder_chakram")
		or (nChakram == 2 and Projectile.ability:GetName() == "shredder_chakram_2")) then
			return true
		end
	end
	
	return false
end