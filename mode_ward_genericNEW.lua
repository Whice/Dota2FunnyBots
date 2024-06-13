if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return
end

local bot = GetBot()
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")

local BaseRadiantWardSpots = {
	Vector(-5265, 4894, 128),
	Vector(-1176, -451, 128),
	Vector(6102, -7444, 256),
	Vector(-3047, 1831, 128),
}

local BaseDireWardSpots = {
	Vector(-532, 315, 128),
	Vector(5134, -4894, 128),
	Vector(-6355, 7180, 256),
	Vector(-3047, 1831, 128),
}

local RadiantPreGameWards = {
	Vector(-1584, 261, 128),
	Vector(-78, -1783, 256),
}

local DirePreGameWards = {
	Vector(820, -490, 128),
	Vector(-662, 920, 128),
}

--// RADIANT TOP LANE \\--
local RadiantTopTierOneWardSpots = {
	Vector(-7933, 1827, 535),
	Vector(-4100, 1538, 535),
}
local RadiantTopTierTwoWardSpots = {
	Vector(-7651, -369, 256),
}
local RadiantTopTierThreeWardSpots = {
	Vector(-5447, -3290, 256)
}

--// RADIANT MID LANE \\--
local RadiantMidTierOneWardSpots = {
	Vector(-947, -2162, 256),
}
local RadiantMidTierTwoWardSpots = {
	Vector(-1364, -3675, 256),
	Vector(-4347, -1013, 535),
}
local RadiantMidTierThreeWardSpots = {
	Vector(-4372, -3921)
}

--// RADIANT BOT LANE \\--
local RadiantBottomTierOneWardSpots = {
	Vector(3862, -4603, 535),
	Vector(2556, -7154, 407),
}
local RadiantBottomTierTwoWardSpots = {
	Vector(769, -4600, 535),
	Vector(-2102, -6340, 128),
}
local RadiantBottomTierThreeWardSpots = {
	Vector(-3871, -4983, 256)
}

--// DIRE TOP LANE \\--
local DireTopTierOneWardSpots = {
	Vector(-1543, 6910, 399),
	Vector(-2505, 4815, 256),
}
local DireTopTierTwoWardSpots = {
	Vector(1379, 6039, 128),
}
local DireTopTierThreeWardSpots = {
	Vector(3292, 4541, 256)
}

--// DIRE MID LANE \\--
local DireMidTierOneWardSpots = {
	Vector(-765, 3591, 527),
	Vector(2045, -774, 527),
}
local DireMidTierTwoWardSpots = {
	Vector(1028, 3323, 399),
	Vector(3665, 2695, 128),
}
local DireMidTierThreeWardSpots = {
	Vector(4021, 3477)
}

--// DIRE BOT LANE \\--
local DireBottomTierOneWardSpots = {
	Vector(7680, -1528, 527),
}
local DireBottomTierTwoWardSpots = {
	Vector(7946, 249, 256),
	Vector(4598, 781, 527),
}
local DireBottomTierThreeWardSpots = {
	Vector(5125, 2846, 256)
}

local ObserverWardRadius = 1600
local SentryWardRadius = 1000
local CastRange = 500
local hWard = nil

local WardLoc = nil

function GetDesire()
	local WardSpots = GetWardSpots()
	--local AvailableWardSpots = FilterWardSpots(WardSpots)
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		hWard = "item_ward_observer"
	elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		hWard = "item_ward_sentry"
	end
	
	local NearbyEnemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	if #NearbyEnemies > 0 then
		return 0
	end
	local WardSlot = nil
	for i = 0,8 do
		local item = bot:GetItemInSlot(i)
		if item ~= nil and (item:GetName() == "item_ward_observer" or item:GetName() == "item_ward_sentry") then
			WardSlot = item
		end
	end
	if WardSlot == nil then
		return 0
	end
	
	local ClosestWardSpot = nil
	local ClosestDistance = 3200
	if IsInPreGame() then
		ClosestDistance = 99999
	end
	for v, WardSpot in pairs(WardSpots) do
		if GetUnitToLocationDistance(bot, WardSpot) < ClosestDistance then
			ClosestWardSpot = WardSpot
			ClosestDistance = GetUnitToLocationDistance(bot, WardSpot)
		end
	end
	
	if ClosestWardSpot ~= nil then
		local WardNearLocation = false
		local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS)
		
		for v, Ward in pairs(WardList) do
			if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
				if Ward:GetUnitName() == "npc_dota_observer_wards" then
					if GetUnitToLocationDistance(Ward, ClosestWardSpot) <= ObserverWardRadius then
						WardNearLocation = true
					end
				end
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
				if Ward:GetUnitName() == "npc_dota_sentry_wards" then
					if GetUnitToLocationDistance(Ward, ClosestWardSpot) <= (SentryWardRadius * 2) then
						WardNearLocation = true
					end
				end
			end
		end
		
		if WardNearLocation then
			return 0
		end
	
		local DistanceToWardSpot = GetUnitToLocationDistance(bot, ClosestWardSpot)
		local DesireDistance = (3200 - DistanceToWardSpot)
		local WardDesire = (RemapValClamped(DesireDistance, 0, 3200, 0.0, 1.0) * 1.5)
		
		WardLoc = ClosestWardSpot
		if IsInPreGame() then
			return BOT_MODE_DESIRE_VERYHIGH
		else
			return Clamp(WardDesire, 0.0, 0.9)
		end
	end
	
	return 0
end

function Think()
	if WardLoc ~= nil then
		if GetUnitToLocationDistance(bot, WardLoc) <= CastRange then
			local WardItem = nil
			for i = 0,8 do
				local item = bot:GetItemInSlot(i)
				if item ~= nil and (item:GetName() == "item_ward_observer" or item:GetName() == "item_ward_sentry") then
					WardItem = item
				end
			end
			
			if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
				bot:Action_UseAbilityOnLocation(WardItem, WardLoc)
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
				bot:Action_UseAbilityOnLocation(WardItem, WardLoc+RandomVector(50))
			end
			return
		else
			bot:Action_MoveToLocation(WardLoc)
			return
		end
	end
end

function OnEnd()
	WardLoc = nil
end

function GetWardSpots()
	local WardSpots = {}
	
	if IsInPreGame() then
		if bot:GetTeam() == TEAM_RADIANT then
			WardSpots = RadiantPreGameWards
		elseif bot:GetTeam() == TEAM_DIRE then
			WardSpots = DirePreGameWards
		end
		
		return WardSpots
	end
	
	if bot:GetTeam() == TEAM_RADIANT then
		WardSpots = BaseRadiantWardSpots
		for v, WS in pairs(DireTopTierOneWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(DireTopTierTwoWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(DireTopTierThreeWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(DireMidTierOneWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(DireMidTierTwoWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(DireMidTierThreeWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(DireBottomTierOneWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(DireBottomTierTwoWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(DireBottomTierThreeWardSpots) do
			table.insert(WardSpots, WS)
		end
		
		if GetTower(bot:GetTeam(), TOWER_TOP_1) == nil then
			for v, WS in pairs(RadiantTopTierOneWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_TOP_2) == nil then
			for v, WS in pairs(RadiantTopTierTwoWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_TOP_3) == nil then
			for v, WS in pairs(RadiantTopTierThreeWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_MID_1) == nil then
			for v, WS in pairs(RadiantMidTierOneWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_MID_2) == nil then
			for v, WS in pairs(RadiantMidTierTwoWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_MID_3) == nil then
			for v, WS in pairs(RadiantMidTierThreeWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_BOT_1) == nil then
			for v, WS in pairs(RadiantBottomTierOneWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_BOT_2) == nil then
			for v, WS in pairs(RadiantBottomTierTwoWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_BOT_3) == nil then
			for v, WS in pairs(RadiantBottomTierThreeWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
			
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			for v, WS in pairs(BaseDireWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
	elseif bot:GetTeam() == TEAM_DIRE then
		WardSpots = BaseDireWardSpots
		for v, WS in pairs(RadiantTopTierOneWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(RadiantTopTierTwoWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(RadiantTopTierThreeWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(RadiantMidTierOneWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(RadiantMidTierTwoWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(RadiantMidTierThreeWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(RadiantBottomTierOneWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(RadiantBottomTierTwoWardSpots) do
			table.insert(WardSpots, WS)
		end
		for v, WS in pairs(RadiantBottomTierThreeWardSpots) do
			table.insert(WardSpots, WS)
		end
		
		if GetTower(bot:GetTeam(), TOWER_TOP_1) == nil then
			for v, WS in pairs(DireTopTierOneWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_TOP_2) == nil then
			for v, WS in pairs(DireTopTierTwoWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_TOP_3) == nil then
			for v, WS in pairs(DireTopTierThreeWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_MID_1) == nil then
			for v, WS in pairs(DireMidTierOneWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_MID_2) == nil then
			for v, WS in pairs(DireMidTierTwoWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_MID_3) == nil then
			for v, WS in pairs(DireMidTierThreeWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_BOT_1) == nil then
			for v, WS in pairs(DireBottomTierOneWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_BOT_2) == nil then
			for v, WS in pairs(DireBottomTierTwoWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
		if GetTower(bot:GetTeam(), TOWER_BOT_3) == nil then
			for v, WS in pairs(DireBottomTierThreeWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
			
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			for v, WS in pairs(BaseRadiantWardSpots) do
				table.insert(WardSpots, WS)
			end
		end
	end
	
	return WardSpots
end

function FilterWardSpots(WardSpots)
	local AvailableWardSpots = {}
	local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS)
	
	for v, WardSpot in pairs(WardSpots) do
		local WardNearLocation = false
		
		for v, Ward in pairs(WardList) do
			if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
				if Ward:GetUnitName() == "npc_dota_observer_wards" then
					if GetUnitToLocationDistance(Ward, WardSpot) <= ObserverWardRadius then
						WardNearLocation = true
					end
				end
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
				if Ward:GetUnitName() == "npc_dota_sentry_wards" then
					if GetUnitToLocationDistance(Ward, WardSpot) <= (SentryWardRadius * 2) then
						WardNearLocation = true
					end
				end
			end
		end
		
		if not WardNearLocation then
			table.insert(AvailableWardSpots, WardSpot)
		end
	end
	
	return AvailableWardSpots
end

function IsInPreGame()
	if DotaTime() < 0 then
		return true
	end
	
	return false
end

function NilOrDead(unit)
	if unit == nil
	or not unit:IsAlive() then
		return true
	else
		return false
	end
	
	return false
end