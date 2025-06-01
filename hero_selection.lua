local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local PHC = require(GetScriptDirectory() .. "/Library/PhalanxHeroCounters")

local RadiantNames = {"Helios", "Eos", "Phos", "Chrysos", "Doxa", "Arete", "Nike", "Elpis", "Iris", "Astraea", "Sophia", "Harmonia", "Euphrosyne", "Philia", "Charis", "Eudaimonia", "Thallo", "Auxo", "Hegemone", "Phanes", "Aster", "Theia", "Eunoia", "Agape", "Selene", "Hyperion", "Leto", "Artemis", "Apollon", "Mousa", "Hera", "Eileithyia", "Zelos", "Eirene", "Tyche", "Peitho", "Eupheme", "Aeon", "Gaia", "Rhea", "Dione", "Mnemosyne", "Hebe", "Kalliope", "Thalia", "Melpomene", "Terpsichore", "Euterpe", "Polymnia", "Urania"}
local DireNames = {"Nyx", "Skotos", "Erebus", "Thanatos", "Moros", "Ker", "Eris", "Apate", "Dolos", "Lyssa", "Nemesis", "Ate", "Phobos", "Deimos", "Hades", "Tartarus", "Lethe", "Styx", "Cerberus", "Empousa", "Gorgo", "Chimera", "Typhon", "Echidna", "Makhai", "Polemos", "Enyo", "Deino", "Oneiroi", "Algos", "Achlys", "Mania", "Penthos", "Oizys", "Dysnomia", "Hybris", "Moira", "Klotho", "Lachesis", "Atropos", "Alastor", "Mormo", "Epiales", "Sybaris", "Phlegyas", "Ceto", "Ladon", "Orthrus", "Pytho"}

local bn

if GetTeam() == TEAM_RADIANT then
	bn = RadiantNames
elseif GetTeam() == TEAM_DIRE then
	bn = DireNames
end

local randomname = RandomInt(1, #bn)
local botname1 = bn[randomname]
table.remove(bn, randomname)

randomname = RandomInt(1, #bn)
local botname2 = bn[randomname]
table.remove(bn, randomname)

randomname = RandomInt(1, #bn)
local botname3 = bn[randomname]
table.remove(bn, randomname)

randomname = RandomInt(1, #bn)
local botname4 = bn[randomname]
table.remove(bn, randomname)

randomname = RandomInt(1, #bn)
local botname5 = bn[randomname]
table.remove(bn, randomname)

function GetBotNames()
	return {botname1, botname2, botname3, botname4, botname5}
end

--[[ EDIT BY: Manslaughter ]]--

local SafeLanePool = PRoles["SafeLane"]
local MidLanePool = PRoles["MidLane"]
local OffLanePool = PRoles["OffLane"]
local SoftSupportPool = PRoles["SoftSupport"]
local HardSupportPool = PRoles["HardSupport"]

local pools = {SafeLanePool, MidLanePool, OffLanePool, SoftSupportPool, HardSupportPool}

local PickableHeroes = {}
local HeroesToAvoid = {}

local lastpicktime = -70
local delaytime = RandomInt(7, 14)
--local delaytime = RandomInt(0, 1)

function Think()
	local playerIDs = GetTeamPlayers(GetTeam())

	if GetGameMode() == GAMEMODE_AP then
		local TableIDs = GetTeamPlayers(GetTeam())
		local RandomID = RandomInt(1, #TableIDs)
		
		if IsPlayerInHeroSelectionControl(TableIDs[RandomID]) and IsPlayerBot(TableIDs[RandomID]) and (GetSelectedHeroName(TableIDs[RandomID]) == "" or GetSelectedHeroName(TableIDs[RandomID]) == nil) and (DotaTime() - lastpicktime) >= delaytime then
			UncounteredHeroes = {}
			PickableHeroes = {}
			
			local HeroPicks = GetPicks()
			local EnemyHeroPicks = GetEnemyPicks(TableIDs[RandomID])
			
			if #EnemyHeroPicks >= 1 then
				for v, pick in pairs(EnemyHeroPicks) do
					local CounteredHeroes = PHC[pick]
					
					if CounteredHeroes ~= nil then
						for i, hero in pairs(pools[RandomID]) do
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
				UncounteredHeroes = pools[RandomID]
			end
			
			if #UncounteredHeroes <= 0 then
				UncounteredHeroes = pools[RandomID]
			end
			
			if #HeroPicks <= 0 then
				PickableHeroes = pools[RandomID]
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
			
			local SelectedHero = PickableHeroes[RandomInt(1, #PickableHeroes)]
			
			SelectHero(TableIDs[RandomID], SelectedHero)
			
			local SelectedPool = pools[RandomID]
			if SelectedPool == PRoles["SafeLane"] then
				PRoles["Positions"][SelectedHero] = "SafeLane"
			elseif SelectedPool == PRoles["MidLane"] then
				PRoles["Positions"][SelectedHero] = "MidLane"
			elseif SelectedPool == PRoles["OffLane"] then
				PRoles["Positions"][SelectedHero] = "OffLane"
				elseif SelectedPool == PRoles["SoftSupport"] then
				PRoles["Positions"][SelectedHero] = "SoftSupport"
				elseif SelectedPool == PRoles["HardSupport"] then
				PRoles["Positions"][SelectedHero] = "HardSupport"
			end
			
			lastpicktime = DotaTime()
			delaytime = RandomInt(5, 14)
			--delaytime = RandomInt(0, 1)
		end
	elseif GetGameMode() == GAMEMODE_CM then
		
	end
end

function UpdateLaneAssignments() 
	if ( GetTeam() == TEAM_RADIANT )
	then
		return {
		[1] = LANE_BOT, -- Position 1 (Safe Lane)
		[2] = LANE_MID, -- Position 2 (Mid Lane)
		[3] = LANE_TOP, -- Position 3 (Off Lane)
		[4] = LANE_TOP, -- Position 4 (Soft Support)
		[5] = LANE_BOT, -- Position 5 (Hard Support)
}
	elseif ( GetTeam() == TEAM_DIRE )
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

function GetPicks()
    local selectedHeroes = {}
	
	for i=0,20,1 do
		if IsTeamPlayer(i)==true then
			local hName = GetSelectedHeroName(i)
			if hName ~= "" and hName ~= nil then
				table.insert(selectedHeroes,hName)
			end
		end
    end
	
    return selectedHeroes
end

function GetEnemyPicks(id)
    local selectedHeroes = {}
	
	for v, i in pairs(GetTeamPlayers(GetOpposingTeam())) do
		local hName = GetSelectedHeroName(i)
		if hName ~= "" and hName ~= nil then
			table.insert(selectedHeroes,hName)
		end
    end
	
    return selectedHeroes
end