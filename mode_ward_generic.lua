if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return
end

local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")

local WardLocations = {}
local WardedLocations = {}

local ClosestWardLocation = nil
local ClosestDistance = 3200

local CastRange = 500

local MinDistClamp = 0
local MaxDistClamp = 3200

local WardLocationCooldown = 780

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

function GetDesire()
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
	
	local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS)
	local ObserverWardList = GetObserverWards(WardList)
	local SentryWardList = GetSentryWards(WardList)
	
	ClosestWardLocation = nil
	ClosestDistance = 1600
	
	local WardsToSearchFor = WardList
	local WardType = nil
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		WardsToSearchFor = ObserverWardList
		WardType = "Observer"
	elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		WardsToSearchFor = SentryWardList
		WardType = "Sentry"
	end
	
	if DotaTime() < 0 then
		if bot:GetTeam() == TEAM_RADIANT then
			WardLocations = RadiantPreGameWards
		elseif bot:GetTeam() == TEAM_DIRE then
			WardLocations = DirePreGameWards
		end
		
		ClosestDistance = 99999999
	else
		if bot:GetTeam() == TEAM_RADIANT then
			WardLocations = UpdateWardSpots(BaseRadiantWardSpots)
		elseif bot:GetTeam() == TEAM_DIRE then
			WardLocations = UpdateWardSpots(BaseDireWardSpots)
		end
	end
	
	for v, WardLoc in pairs(WardLocations) do
		local ShouldAvoidWarding = false
		
		if WardedLocations[WardLoc] and (DotaTime() - WardedLocations[WardLoc]) < WardLocationCooldown then
			ShouldAvoidWarding = true
		end
		
		if GetUnitToLocationDistance(bot, WardLoc) <= ClosestDistance
		and not IsWardNearby(WardsToSearchFor, WardType, WardLoc)
		and not ShouldAvoidWarding then
			ClosestWardLocation = WardLoc
			ClosestDistance = GetUnitToLocationDistance(bot, WardLoc)
		end
	end
	
	if ClosestWardLocation ~= nil then
		if not IsWardNearby(WardsToSearchFor, WardType, ClosestWardLocation) then
			local Distance = GetUnitToLocationDistance(bot, ClosestWardLocation)
			local DesireVariable = RemapValClamped(Distance, MinDistClamp, MaxDistClamp, 0.0, 1.0)
			local WardDesire = (1.0 - DesireVariable)
			
			if DotaTime() < 0 then
				return BOT_MODE_DESIRE_VERYHIGH
			else
				return Clamp((WardDesire * 2), 0.0, 0.9)
			end
		end
	end
	
	return 0
end

function Think()
	if ClosestWardLocation ~= nil then
		local WardItem = nil
		for i = 0,8 do
			local item = bot:GetItemInSlot(i)
			if item ~= nil and (item:GetName() == "item_ward_observer" or item:GetName() == "item_ward_sentry") then
				WardItem = item
			end
		end
		
		if GetUnitToLocationDistance(bot, ClosestWardLocation) > CastRange then
			bot:Action_MoveToLocation(ClosestWardLocation)
		else
			if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
				bot:Action_UseAbilityOnLocation(WardItem, ClosestWardLocation)
				WardedLocations[ClosestWardLocation] = DotaTime()
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
				bot:Action_UseAbilityOnLocation(WardItem, ClosestWardLocation+RandomVector(50))
			end
		end
	end
end


function GetObserverWards(WardList)
	local ObserverWardList = {}
	
	for v, Ward in pairs(WardList) do
		if Ward:GetUnitName() == "npc_dota_observer_wards" then
			table.insert(ObserverWardList, Ward)
		end
	end
	
	return ObserverWardList
end

function GetSentryWards(WardList)
	local SentryWardList = {}
	
	for v, Ward in pairs(WardList) do
		if Ward:GetUnitName() == "npc_dota_sentry_wards" then
			table.insert(SentryWardList, Ward)
		end
	end
	
	return SentryWardList
end

function IsWardNearby(WardList, WardType, Location)
	local WardRange = 0
	if WardType == "Observer" then
		WardRange = 1600
	elseif WardType == "Sentry" then
		WardRange = 1000
	end
	
	for v, Ward in pairs(WardList) do
		if GetUnitToLocationDistance(Ward, Location) <= WardRange then
			return true
		end
	end
	
	return false
end

function CombineTables(TableOne, TableTwo)
	local CombinedTable = {}

	for v, TableItem in pairs(TableOne) do
		table.insert(CombinedTable, TableItem)
	end
	for v, TableItem in pairs(TableTwo) do
		table.insert(CombinedTable, TableItem)
	end
	
	return CombinedTable
end

function UpdateWardSpots(WardList)
	local WardSpots = WardList
	
	if bot:GetTeam() == TEAM_RADIANT then
		WardSpots = CombineTables(WardSpots, DireTopTierOneWardSpots)
		WardSpots = CombineTables(WardSpots, DireTopTierTwoWardSpots)
		WardSpots = CombineTables(WardSpots, DireTopTierThreeWardSpots)
		WardSpots = CombineTables(WardSpots, DireMidTierOneWardSpots)
		WardSpots = CombineTables(WardSpots, DireMidTierTwoWardSpots)
		WardSpots = CombineTables(WardSpots, DireMidTierThreeWardSpots)
		WardSpots = CombineTables(WardSpots, DireBottomTierOneWardSpots)
		WardSpots = CombineTables(WardSpots, DireBottomTierTwoWardSpots)
		WardSpots = CombineTables(WardSpots, DireBottomTierThreeWardSpots)
		
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_1)) then
			WardSpots = CombineTables(WardSpots, RadiantTopTierOneWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_2)) then
			WardSpots = CombineTables(WardSpots, RadiantTopTierTwoWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_3)) then
			WardSpots = CombineTables(WardSpots, RadiantTopTierThreeWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_1)) then
			WardSpots = CombineTables(WardSpots, RadiantMidTierOneWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_2)) then
			WardSpots = CombineTables(WardSpots, RadiantMidTierTwoWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_3)) then
			WardSpots = CombineTables(WardSpots, RadiantMidTierThreeWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_1)) then
			WardSpots = CombineTables(WardSpots, RadiantBottomTierOneWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_2)) then
			WardSpots = CombineTables(WardSpots, RadiantBottomTierTwoWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_3)) then
			WardSpots = CombineTables(WardSpots, RadiantBottomTierThreeWardSpots)
		end
	elseif bot:GetTeam() == TEAM_DIRE then
		WardSpots = CombineTables(WardSpots, RadiantTopTierOneWardSpots)
		WardSpots = CombineTables(WardSpots, RadiantTopTierTwoWardSpots)
		WardSpots = CombineTables(WardSpots, RadiantTopTierThreeWardSpots)
		WardSpots = CombineTables(WardSpots, RadiantMidTierOneWardSpots)
		WardSpots = CombineTables(WardSpots, RadiantMidTierTwoWardSpots)
		WardSpots = CombineTables(WardSpots, RadiantMidTierThreeWardSpots)
		WardSpots = CombineTables(WardSpots, RadiantBottomTierOneWardSpots)
		WardSpots = CombineTables(WardSpots, RadiantBottomTierTwoWardSpots)
		WardSpots = CombineTables(WardSpots, RadiantBottomTierThreeWardSpots)
		
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_1)) then
			WardSpots = CombineTables(WardSpots, DireTopTierOneWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_2)) then
			WardSpots = CombineTables(WardSpots, DireTopTierTwoWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_3)) then
			WardSpots = CombineTables(WardSpots, DireTopTierThreeWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_1)) then
			WardSpots = CombineTables(WardSpots, DireMidTierOneWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_2)) then
			WardSpots = CombineTables(WardSpots, DireMidTierTwoWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_3)) then
			WardSpots = CombineTables(WardSpots, DireMidTierThreeWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_1)) then
			WardSpots = CombineTables(WardSpots, DireBottomTierOneWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_2)) then
			WardSpots = CombineTables(WardSpots, DireBottomTierTwoWardSpots)
		end
		if not NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_3)) then
			WardSpots = CombineTables(WardSpots, DireBottomTierThreeWardSpots)
		end
	end
	
	return WardSpots
end

function NotNilOrDead(unit)
	if unit == nil or unit:IsNull() then
		return false
	end
	if unit:IsAlive() then
		return true
	end
	return false
end