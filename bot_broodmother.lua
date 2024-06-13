local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local bot = GetBot()

function  MinionThink(hMinionUnit) 
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then	
		if string.find(hMinionUnit:GetUnitName(), "spiderling")
		or string.find(hMinionUnit:GetUnitName(), "spiderite") then
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
		
		if hMinionUnit:IsIllusion() then
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