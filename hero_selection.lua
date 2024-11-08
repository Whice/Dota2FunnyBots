local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local PHC = require(GetScriptDirectory() .. "/Library/PhalanxHeroCounters")

local bn = { "Aquila", "Commodus", "Buteo", "Aurelius", "Priscus", "Modius", "Cassius", "Galeo", "Nerva", "Rufius",
	"Paetus", "Claudius", "Corvus", "Cornelius", "Verus", "Strabo", "Maximus", "Lucinius", "Flavius", "Severus",
	"Calidus", "Agrippa", "Tiberus", "Cicurinius" }
local prefixes = { "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "W" }

local prefix
local suffix

if GetTeam() == TEAM_RADIANT then
	suffix = "I"
elseif GetTeam() == TEAM_DIRE then
	suffix = "V"
end

local randomname = RandomInt(1, #bn)
prefix = prefixes[RandomInt(1, #prefixes)]
local botname1 = (prefix .. ". " .. bn[randomname] .. " " .. suffix)
table.remove(bn, randomname)

randomname = RandomInt(1, #bn)
prefix = prefixes[RandomInt(1, #prefixes)]
local botname2 = (prefix .. ". " .. bn[randomname] .. " " .. suffix)
table.remove(bn, randomname)

randomname = RandomInt(1, #bn)
prefix = prefixes[RandomInt(1, #prefixes)]
local botname3 = (prefix .. ". " .. bn[randomname] .. " " .. suffix)
table.remove(bn, randomname)

randomname = RandomInt(1, #bn)
prefix = prefixes[RandomInt(1, #prefixes)]
local botname4 = (prefix .. ". " .. bn[randomname] .. " " .. suffix)
table.remove(bn, randomname)

randomname = RandomInt(1, #bn)
prefix = prefixes[RandomInt(1, #prefixes)]
local botname5 = (prefix .. ". " .. bn[randomname] .. " " .. suffix)
table.remove(bn, randomname)

function GetBotNames()
	return { botname1, botname2, botname3, botname4, botname5 }
end

--[[ EDIT BY: Manslaughter ]] --

local SafeLanePool = PRoles["SafeLane"]
local MidLanePool = PRoles["MidLane"]
local OffLanePool = PRoles["OffLane"]
local SoftSupportPool = PRoles["SoftSupport"]
local HardSupportPool = PRoles["HardSupport"]

local pools = { SafeLanePool, MidLanePool, OffLanePool, SoftSupportPool, HardSupportPool }

local PickableHeroes = {}
local HeroesToAvoid = {}

local lastpicktime = -70
local delaytime = 0.5

function Think()
	if GetGameMode() == GAMEMODE_AP then
		local tableIDs = GetTeamPlayers(GetTeam())
		local randomIDIndex = RandomInt(1, #tableIDs)
		local dotaTime = DotaTime()

		local isTimeForPick = (dotaTime - lastpicktime) > delaytime
		if isTimeForPick then
			local randomID = tableIDs[randomIDIndex]
			local isPlayerCanChoose = IsPlayerInHeroSelectionControl(randomID)
			local IsPlayerBot = IsPlayerBot(randomID)
			local selectedHeroName = GetSelectedHeroName(randomID)
			local isCorrectHeroName = selectedHeroName == "" or selectedHeroName == nil
			if isPlayerCanChoose and IsPlayerBot and isCorrectHeroName then
				UncounteredHeroes = {}
				PickableHeroes = {}

				local HeroPicks = GetPicks()
				local EnemyHeroPicks = GetEnemyPicks(randomID)

				if #EnemyHeroPicks >= 1 then
					for v, pick in pairs(EnemyHeroPicks) do
						local CounteredHeroes = PHC[pick]

						if CounteredHeroes ~= nil then
							for i, hero in pairs(pools[randomIDIndex]) do
								local IsHeroCountered = false

								for x, ch in pairs(CounteredHeroes) do
									if hero == ch then
										IsHeroCountered = true
										break
									end
								end

								if not IsHeroCountered then
									table.insert(UncounteredHeroes, hero)
								end
							end
						end
					end
				else
					UncounteredHeroes = pools[randomIDIndex]
				end

				if #UncounteredHeroes <= 0 then
					UncounteredHeroes = pools[randomIDIndex]
				end

				if #HeroPicks <= 0 then
					PickableHeroes = pools[randomIDIndex]
				else
					for v, uch in pairs(UncounteredHeroes) do
						local IsHeroPicked = false

						for x, pick in pairs(HeroPicks) do
							if pick == uch then
								IsHeroPicked = true
								break
							end
						end

						if not IsHeroPicked then
							table.insert(PickableHeroes, uch)
						end
					end
				end

				SelectHero(randomID, PickableHeroes[RandomInt(1, #PickableHeroes)])
				lastpicktime = dotaTime
			end
		end
	elseif GetGameMode() == GAMEMODE_CM then

	end
end

function UpdateLaneAssignments()
	if (GetTeam() == TEAM_RADIANT)
	then
		return {
			[1] = LANE_BOT, -- Position 1 (Safe Lane)
			[2] = LANE_MID, -- Position 2 (Mid Lane)
			[3] = LANE_TOP, -- Position 3 (Off Lane)
			[4] = LANE_TOP, -- Position 4 (Soft Support)
			[5] = LANE_BOT, -- Position 5 (Hard Support)
		}
	elseif (GetTeam() == TEAM_DIRE)
	then
		return {
			[1] = LANE_TOP, -- Position 1 (Safe Lane)
			[2] = LANE_MID, -- Position 2 (Mid Lane)
			[3] = LANE_BOT, -- Position 3 (Off Lane)
			[4] = LANE_BOT, -- Position 4 (Soft Support)
			[5] = LANE_TOP, -- Position 5 (Hard Support)
		}
	end
end

function IsStrFilled(string)
	return string ~= "" and string ~= nil
end

function GetPicks()
	local selectedHeroes = {}

	for i = 0, 20, 1 do
		if IsTeamPlayer(i) == true then
			local hName = GetSelectedHeroName(i)
			if IsStrFilled(hName ) then
				table.insert(selectedHeroes, hName)
			end
		end
	end

	return selectedHeroes
end

function GetEnemyPicks(id)
	local selectedHeroes = {}

	for v, i in pairs(GetTeamPlayers(GetOpposingTeam())) do
		local hName = GetSelectedHeroName(i)
		if IsStrFilled(hName ) then
			table.insert(selectedHeroes, hName)
		end
	end
end