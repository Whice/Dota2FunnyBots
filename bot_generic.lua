local LaningStateBehaviour = require(GetScriptDirectory() .. "\\Behaviuors.LaningStateBehaviour")
local gf = require(GetScriptDirectory() .. "\\Behaviuors.GeneralFunctions")


local selfBot
local botSlotNumber
local botNumberInTeam



function IsNecrolyte(bot)
    if bot ~= nil and bot:IsHero() then
        return bot:GetUnitName() == "npc_dota_hero_necrolyte"
    end
    return false
end


local isNamePrint = false

function Think()
    local dotaTime = DotaTime()
    if selfBot == nil then
        selfBot = GetBot()

        botSlotNumber = selfBot:GetPlayerID()
        if botSlotNumber < 5 then
            botNumberInTeam = botSlotNumber + 1
        else
            botNumberInTeam = botSlotNumber - 4
        end
        LaningStateBehaviour.SetLaneType(botNumberInTeam)
    end

    if not isNamePrint then
        --SendMsgAll("My slot: "..botSlotNumber)
        gf.SendMsgAll("My pos: " .. botNumberInTeam)
        local line = LaningStateBehaviour.GetConcreteLineByLaneType(selfBot)
        gf.SendMsgAll("My line: " .. line)
        isNamePrint = true
    end

    if (LaningStateBehaviour.stateLaning) then
        LaningStateBehaviour.Think(dotaTime)
    end
end
