local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local bot = GetBot()

function MinionThink(hMinionUnit) 
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then	
		if string.find(hMinionUnit:GetUnitName(), "venomancer_plague_ward") then
			local target = WardTarget(hMinionUnit)
		
			if target ~= nil then
				hMinionUnit:Action_AttackUnit(target, false)
			else
			end
		end
		
		if hMinionUnit:IsIllusion() and not string.find(hMinionUnit:GetUnitName(), "venomancer_plague_ward") then
			local target = P.IllusionTarget(hMinionUnit, bot)
		
			if target ~= nil then
				hMinionUnit:Action_AttackUnit(target, false)
			else
				if GetUnitToUnitDistance(hMinionUnit, bot) > 200 then
					hMinionUnit:Action_MoveToLocation(bot:GetLocation())
				else
					hMinionUnit:Action_MoveToLocation(bot:GetLocation()+RandomVector(200))
				end
			end
		end
	end
end

function WardTarget(hMinionUnit)
	local range = hMinionUnit:GetAttackRange()
	local enemies = hMinionUnit:GetNearbyHeroes(range, true, BOT_MODE_NONE)
	local target = nil
	
	if GetUnitToUnitDistance(hMinionUnit, GetAncient(GetOpposingTeam())) <= range then
		target = GetAncient(GetOpposingTeam())
	end
	
	if #enemies >= 1 then
		target = P.GetWeakestEnemyHeroPhysical(enemies)
	end
	
	if target == nil then
		enemies = hMinionUnit:GetNearbyLaneCreeps(range, true)
		
		local weakestunit = nil
		local smallesthealth = 99999
			
		for v, unit in pairs(enemies) do
			if unit ~= nil and unit:CanBeSeen() then
				if unit:GetHealth() < smallesthealth then
					weakestunit = unit
					smallesthealth = unit:GetHealth()
				end
			end
		end
	
		target = weakestunit
	end
	
	if target == nil then
		enemies = hMinionUnit:GetNearbyCreeps(range, true)
		
		local weakestunit = nil
		local smallesthealth = 99999
			
		for v, unit in pairs(enemies) do
			if unit ~= nil and unit:CanBeSeen() then
				if unit:GetHealth() < smallesthealth then
					weakestunit = unit
					smallesthealth = unit:GetHealth()
				end
			end
		end
	
		target = weakestunit
	end
	
	if target == nil then
		enemies = hMinionUnit:GetNearbyBarracks(range, true)
		
		local weakestunit = nil
		local smallesthealth = 99999
			
		for v, unit in pairs(enemies) do
			if unit ~= nil and unit:CanBeSeen() and not unit:IsInvulnerable() then
				if unit:GetHealth() < smallesthealth then
					weakestunit = unit
					smallesthealth = unit:GetHealth()
				end
			end
		end
	
		target = weakestunit
	end
	
	if target == nil then
		enemies = hMinionUnit:GetNearbyTowers(range, true)
		
		local weakestunit = nil
		local smallesthealth = 99999
			
		for v, unit in pairs(enemies) do
			if unit ~= nil and unit:CanBeSeen() and not unit:IsInvulnerable() then
				if unit:GetHealth() < smallesthealth then
					weakestunit = unit
					smallesthealth = unit:GetHealth()
				end
			end
		end
	
		target = weakestunit
	end
	
	if target ~= nil and not target:IsAttackImmune() and not target:IsInvulnerable() then
		if GetUnitToUnitDistance(hMinionUnit, target) > range then
			target = nil
			return target
		else
			return target
		end
	end
	
	return target
end