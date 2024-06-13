local PChat = {}

local ChattedStartMessage = false

local PatchVersion = "7.36b"
local LastUpdatedVersion = "June 6th, 2024"

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
end

return PChat