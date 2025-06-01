if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() or GetBot():GetAbilityInSlot(5):GetName() == "dazzle_nothl_projection_end" then
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
	Vector(-304.583435, -1010.216370, 128.000000), -- Mid River
	Vector(1770.320068, -3297.484619, 256.000000), -- Bottom Roshan Pit
	Vector(-2590.959717, 808.961487, 0.000000), -- Top Roshan Pit
	Vector(-6879.606934, 7948.673340, 256.000000), -- Top Tormentor
	Vector(-6223.481445, 5977.364258, 128.000000), -- Top Tower
	Vector(6618.658203, -3122.270264, 128.000000), -- Bot Tower
	Vector(6987.828613, -7517.367188, 256.000000), -- Bot Tormentor
}

local BaseDireWardSpots = {
	Vector(-514.736816, 293.893494, 128.000000), -- Mid River
	Vector(2472.568359, -1176.064941, 256.000000), -- Bottom Roshan Pit
	Vector(-1575.356445, 2015.812500, 256.000000), -- Top Roshan Pit
	Vector(-6879.606934, 7948.673340, 256.000000), -- Top Tormentor
	Vector(-6633.713867, 2726.299316, 128.000000), -- Top Tower
	Vector(5940.784668, -6109.887695, 128.000000), -- Bot Tower
	Vector(6987.828613, -7517.367188, 256.000000), -- Bot Tormentor
}

local RadiantPreGameWards = {
	Vector(-2240.848877, 220.828491, 128.000000),
	Vector(313.206116, -1478.791016, 128.000000),
}

local DirePreGameWards = {
	Vector(-1036.055176, 1453.375122, 128.000000),
	Vector(1256.345459, -432.611206, 128.000000),
}

--// RADIANT TOP LANE \\--
local RadiantTopTierOneWardSpots = {
	Vector(-7932.318848, 1798.319336, 535.996094),
	Vector(-4765.358887, 1978.797485, 128.000000),
}
local RadiantTopTierTwoWardSpots = {
	Vector(-7553.846680, -1063.322388, 256.000000),
	Vector(-4348.506836, -1046.330933, 535.996094),
}
local RadiantTopTierThreeWardSpots = {
	Vector(-5458.211426, -3371.772217, 256.000000),
}

--// RADIANT MID LANE \\--
local RadiantMidTierOneWardSpots = {
	Vector(-2502.645508, -2183.256348, 128.000000),
	Vector(795.113586, -3576.661621, 256.000000),
}
local RadiantMidTierTwoWardSpots = {
	Vector(-4348.506836, -1046.330933, 535.996094),
	Vector(-1276.767090, -4345.625000, 403.246094),
}
local RadiantMidTierThreeWardSpots = {
	Vector(-5458.211426, -3371.772217, 256.000000),
	Vector(-3871.644043, -4988.541016, 256.000000),
}

--// RADIANT BOT LANE \\--
local RadiantBottomTierOneWardSpots = {
	Vector(1863.126099, -6671.102539, 128.000000),
	Vector(2048.552246, -4891.520020, 256.000000),
	Vector(3949.502197, -7155.229492, 128.000000),
}
local RadiantBottomTierTwoWardSpots = {
	Vector(-1276.767090, -4345.625000, 403.246094),
	Vector(-1892.914062, -6438.083008, 128.000000),
}
local RadiantBottomTierThreeWardSpots = {
	Vector(-3871.644043, -4988.541016, 256.000000),
}

--// DIRE TOP LANE \\--
local DireTopTierOneWardSpots = {
	Vector(-2300.783936, 6745.654297, 128.000000),
	Vector(-4330.303223, 7147.556152, 128.000000),
	Vector(-2334.944336, 4638.333008, 256.000000),
}
local DireTopTierTwoWardSpots = {
	Vector(1559.554199, 6069.459961, 128.000000),
	Vector(206.604904, 4382.747559, 134.000000),
}
local DireTopTierThreeWardSpots = {
	Vector(3301.364990, 4615.956055, 256.000000),
}

--// DIRE MID LANE \\--
local DireMidTierOneWardSpots = {
	Vector(-1042.932129, 2963.607910, 256.000000),
	Vector(1343.007935, 1348.858032, 128.000000),
}
local DireMidTierTwoWardSpots = {
	Vector(1026.262451, 3588.000977, 399.996094),
	Vector(4607.770996, 770.798767, 527.996094),
}
local DireMidTierThreeWardSpots = {
	Vector(3301.364990, 4615.956055, 256.000000),
	Vector(5131.353516, 2881.154053, 256.000000),
}

--// DIRE BOT LANE \\--
local DireBottomTierOneWardSpots = {
	Vector(7688.733398, -1536.282471, 527.996094),
	Vector(4541.222656, -1810.860840, 128.000000),
}
local DireBottomTierTwoWardSpots = {
	Vector(4607.770996, 770.798767, 527.996094),
	Vector(7761.000977, 474.206818, 256.000000),
}
local DireBottomTierThreeWardSpots = {
	Vector(5131.353516, 2881.154053, 256.000000),
}

function GetDesire()
	if bot:GetDifficulty() == DIFFICULTY_PASSIVE then
		return 0
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
		and not IsBuildingNearby(WardLoc)
		and not ShouldAvoidWarding then
			ClosestWardLocation = WardLoc
			ClosestDistance = GetUnitToLocationDistance(bot, WardLoc)
		end
	end
	
	if ClosestWardLocation ~= nil then
		if not IsWardNearby(WardsToSearchFor, WardType, ClosestWardLocation) and not IsBuildingNearby(ClosestWardLocation) then
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
		WardRange = 1050
	end
	
	for v, Ward in pairs(WardList) do
		if GetUnitToLocationDistance(Ward, Location) <= WardRange then
			return true
		end
	end
	
	return false
end

function IsBuildingNearby(Location)
	local Range = 700
	
	for v, Building in pairs(GetUnitList(UNIT_LIST_ENEMY_BUILDINGS)) do
		if not string.find(Building:GetUnitName(), "outpost")
		and GetUnitToLocationDistance(Building, Location) <= Range then
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