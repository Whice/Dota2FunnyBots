local PChat = {}

local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local ChattedStartMessage = false
local ChattedLosingKillDiffMessage = false
local LastMissingPing = 0

local PatchVersion = "7.37"
local LastUpdatedVersion = "August 10th, 2024"

PChat["KillstreakPhrases"] = {"ez", ")", "?", "???", "xd", "XD"}
PChat["LosingKillDifferencePhrases"] = {"end", "END", "go throne", "gg team", "AFK"}
PChat["AncientCriticalPhrases"] = {"gg", "GG", "ggwp", "GGWP"}

function PChat.ChatModule()
	local bot = GetBot()

	if not ChattedStartMessage then
		if DotaTime() >= -60 then
			if GetGameMode() == GAMEMODE_AP then
				bot:ActionImmediate_Chat(("PhalanxBot loaded! This version is from "..LastUpdatedVersion.." for Patch "..PatchVersion), true)
				bot:ActionImmediate_Chat("Have any feedback? Join the Discord! - https://discord.gg/MpA88P645B", true)
			else
				bot:ActionImmediate_Chat("PHALANXBOT HAS DETECTED A MODE THAT ISN'T ALL PICK!", true)
				bot:ActionImmediate_Chat("BOTS MAY NOT FUNCTION PROPERLY!", true)
			end
			
			ChattedStartMessage = true
		end
	end
	
	LosingKillDifferenceChat()
	EnemyTeamMissingChat()
end

function LosingKillDifferenceChat()
	local bot = GetBot()
	local AllyTeamKills = PAF.GetAllyTeamKills()
	local EnemyTeamKills = PAF.GetEnemyTeamKills()
	
	if not ChattedLosingKillDiffMessage
	and (EnemyTeamKills - AllyTeamKills) >= 20 then
		ChattedLosingKillDiffMessage = true
		
		local LosingKillDifferencePhrase = PChat["LosingKillDifferencePhrases"][RandomInt(1, #PChat["LosingKillDifferencePhrases"])]
		bot:ActionImmediate_Chat(LosingKillDifferencePhrase, true)
	end
end

function EnemyTeamMissingChat()
	local bot = GetBot()
	
	local MissingLocations = {}
	
	local EnemyIDs = GetTeamPlayers(GetOpposingTeam())
	for v, EID in pairs(EnemyIDs) do
		local LSI = GetHeroLastSeenInfo(EID)
		if IsHeroAlive(EID) and LSI ~= nil then
			local nLSI = LSI[1]
			if nLSI ~= nil then
				if nLSI.time_since_seen >= 7 then
					table.insert(MissingLocations, nLSI.location)
				end
			end
		end
	end
	
	if #MissingLocations >= 3 then
		if (DotaTime() - LastMissingPing) >= 120 then
			LastMissingPing = DotaTime()
			bot:ActionImmediate_Chat((#MissingLocations.." heroes are missing!"), false)
			
			local avgX = 0
			local avgY = 0
			local CountVar = #MissingLocations
			
			for i = 1, CountVar do
				avgX = (avgX + MissingLocations[i].x)
				avgY = (avgY + MissingLocations[i].y)
			end
			
			local avgX = (avgX / CountVar)
			local avgY = (avgY / CountVar)
			
			bot:ActionImmediate_Ping(avgX, avgY, false)
		end
	end
end

return PChat