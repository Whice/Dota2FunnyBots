if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or GetBot():IsIllusion() then
	return
end

local bot = GetBot()

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local BottomBounty = RUNE_BOUNTY_2
local TopRiver = RUNE_POWERUP_1
local TopBounty = RUNE_BOUNTY_1
local BottomRiver = RUNE_POWERUP_2

local RiverRunes = {TopRiver, BottomRiver}
local AllRunes = {BottomBounty, TopRiver, TopBounty, BottomRiver}

local RuneToCheck = nil

local Radiant15Pos = Vector( 1283.432861, -4635.932617, 256.000000 )
local Radiant2Pos = Vector( -1914.282593, 67.686188, 128.000000 )
local Radiant34Pos = Vector( -3421.025635, 516.299316, 256.000000 )
local Dire1Pos = Vector( -1832.766724, 3072.584961, 256.000000 )
local Dire5Pos = Vector( -1056.839233, 3136.392578, 256.000000 )
local Dire2Pos = Vector( 1150.164185, -317.183716, 128.000000 )
local Dire34Pos = Vector( 2722.729980, -1398.364258, 256.000000 )

function GetDesire()
	if RuneToCheck ~= nil and not IsAllyWithBottleNearby(RuneToCheck) then
		if GetUnitToLocationDistance(bot, GetRuneSpawnLocation(RuneToCheck)) <= 50 then
			return BOT_MODE_DESIRE_VERYLOW
		end
	end

	if ShouldMoveToPregameLoc() or ShouldMoveToStartBounty() then
		return BOT_MODE_DESIRE_MODERATE
	end
	
	if AreWaterRunesActive() then
		local ClosestRune = nil
		local ClosestDistance = 3200
		for v, Rune in pairs(RiverRunes) do
			if GetUnitToLocationDistance(bot, GetRuneSpawnLocation(Rune)) <= ClosestDistance then
				if ShouldCheckRune(Rune) then
					ClosestRune = Rune
					ClosestDistance = GetUnitToLocationDistance(bot, GetRuneSpawnLocation(Rune))
				end
			end
		end
		
		if ClosestRune ~= nil and not HumanDangerPingedRune(GetRuneSpawnLocation(ClosestRune)) then
			RuneToCheck = ClosestRune
			return BOT_MODE_DESIRE_HIGH
		end
	end
	
	if IsLaningSupport() then
		if (bot:GetTeam() == TEAM_RADIANT and PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport")
		or (bot:GetTeam() == TEAM_DIRE and PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport") then
			if ShouldCheckRune(TopBounty) and not HumanDangerPingedRune(TopBounty) then
				RuneToCheck = TopBounty
				return BOT_MODE_DESIRE_HIGH
			end
		end
		
		if (bot:GetTeam() == TEAM_RADIANT and PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport")
		or (bot:GetTeam() == TEAM_DIRE and PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport") then
			if ShouldCheckRune(BottomBounty) and not HumanDangerPingedRune(BottomBounty) then
				RuneToCheck = BottomBounty
				return BOT_MODE_DESIRE_HIGH
			end
		end
	end
	
	local ClosestRune = nil
	local ClosestDistance = 3200
	for v, Rune in pairs(AllRunes) do
		if GetUnitToLocationDistance(bot, GetRuneSpawnLocation(Rune)) <= ClosestDistance then
			if ShouldCheckRune(Rune) then
				ClosestRune = Rune
				ClosestDistance = GetUnitToLocationDistance(bot, GetRuneSpawnLocation(Rune))
			end
		end
	end
	
	if ClosestRune ~= nil and not IsAllyWithBottleNearby(ClosestRune) and not HumanDangerPingedRune(RuneLoc) then
		local DistanceToRune = GetUnitToLocationDistance(bot, GetRuneSpawnLocation(ClosestRune))
		local DesireDistance = (3200 - DistanceToRune)
		local RuneDesire = (RemapValClamped(DesireDistance, 0, 3200, 0.0, 1.0) * 2)
		
		RuneToCheck = ClosestRune
		return Clamp(RuneDesire, 0.0, 0.9)
	end
	return BOT_MODE_DESIRE_NONE
end

function Think()
	if ShouldMoveToPregameLoc() then
		local PregameLoc = GetPregameLoc()
		
		if GetUnitToLocationDistance(bot, PregameLoc) > 300 then
			bot:Action_MoveToLocation(PregameLoc)
		else
			bot:Action_MoveToLocation(PregameLoc+RandomVector(300))
		end
	end
	
	if ShouldMoveToStartBounty() then
		if bot:GetTeam() == TEAM_RADIANT then
			if bot:GetAssignedLane() == LANE_TOP
			or bot:GetAssignedLane() == LANE_MID then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(TopRiver))
				return
			elseif bot:GetAssignedLane() == LANE_BOT then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(BottomBounty))
				return
			end
		elseif bot:GetTeam() == TEAM_DIRE then
			if bot:GetAssignedLane() == LANE_BOT
			or bot:GetAssignedLane() == LANE_MID then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(BottomRiver))
				return
			elseif bot:GetAssignedLane() == LANE_TOP then
				bot:Action_MoveToLocation(GetRuneSpawnLocation(TopBounty))
				return
			end
		end
		
		return
	end
	
	if RuneToCheck ~= nil then
		if GetUnitToLocationDistance(bot, GetRuneSpawnLocation(RuneToCheck)) <= 50 then
			bot:Action_PickUpRune(RuneToCheck)
			return
		else
			bot:Action_MoveToLocation(GetRuneSpawnLocation(RuneToCheck))
			return
		end
	end
end

function OnEnd()
	RuneToCheck = nil
end

function ShouldCheckRune(Rune)
	if GetRuneStatus(Rune) == RUNE_STATUS_AVAILABLE or GetRuneStatus(Rune) == RUNE_STATUS_UNKNOWN then
		return true
	end
	
	return false
end

function ShouldMoveToStartBounty()
	if DotaTime() >= -10 and DotaTime() <= 0 then
		return true
	end
	
	return false
end

function AreWaterRunesActive()
	if DotaTime() < (6 * 60) then
		return true
	end
	
	return false
end

function IsLaningSupport()
	if P.IsInLaningPhase()
	and (PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport") then
		return true
	end
	
	return false
end

function IsAllyWithBottleNearby(Rune)
	local NearbyAllies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(NearbyAllies)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:FindItemSlot("item_bottle") ~= -1
		and Ally ~= bot
		and GetUnitToLocationDistance(Ally, GetRuneSpawnLocation(Rune)) <= 1200 then
			return true
		end
	end
	
	return false
end

function HumanDangerPingedRune(RuneLoc)
	for v, Human in pairs(PAF.GetAllyHumanHeroes()) do
		local LastPing = Human:GetMostRecentPing()
		if (GameTime() - LastPing.time) < 30
		and LastPing.normal_ping == false
		and P.GetDistance(RuneLoc, LastPing.location) <= 400 then
			return true
		end
	end
	
	return false
end

function ShouldMoveToPregameLoc()
	if DotaTime() < -10 then
		return true
	end
	
	return false
end

function GetPregameLoc()
	if bot:GetTeam() == TEAM_RADIANT then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
			return Radiant15Pos
		end
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
			return Radiant2Pos
		end
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
			return Radiant34Pos
		end
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			return Radiant34Pos
		end
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			return Radiant15Pos
		end
	end
	
	if bot:GetTeam() == TEAM_DIRE then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
			return Dire1Pos
		end
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
			return Dire2Pos
		end
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
			return Dire34Pos
		end
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			return Dire34Pos
		end
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			return Dire5Pos
		end
	end
	
	return nil
end