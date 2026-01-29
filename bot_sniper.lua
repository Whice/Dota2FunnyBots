-- game/dota/scripts/vscripts/bots/bot_sniper.lua
local HeroLiningBehaviour = require(GetScriptDirectory().."/Behaviuors/HeroLiningBehaviour")
local BotGlobalState = require(GetScriptDirectory().."/AdditionalFunctions/BotGlobalState")
local constants = require(GetScriptDirectory().."/AdditionalFunctions/Constants")
local SimpleActions = require(GetScriptDirectory().."/AdditionalFunctions/SimpleActions")
local BackpackManager = require(GetScriptDirectory().."/AdditionalFunctions/BackpackManager")

local lane_assigned = false
local last_teleport_check = 0
local last_teleport_action_time = 0

-- Определяем линию для бота по его слоту
function AssignLane(npcBot)
    local team = npcBot:GetTeam()
    local botData = BotGlobalState.GetBotData(npcBot)
    local slots = { -- Распределение слотов по линиям
        [1] = LANE_TOP,
        [2] = LANE_MID,
        [3] = LANE_BOT,
        [4] = LANE_TOP,
        [5] = LANE_BOT
    }
    
    -- Проверяем, не занята ли линия другими ботами
    local allies = GetTeamPlayers(team)
    for i,slot in pairs(slots) do
        if GetBot():GetPlayerID() == allies[i] then
            botData.target_lane = slot
            return
        end
    end
end

function Think()
    local npcBot = GetBot()
    
    -- Проверяем, жив ли герой
    if not npcBot:IsAlive() then
        return
    end

     -- Сортируем рюкзак (будет вызываться раз в секунду)
    BackpackManager.Update(npcBot)

    local botData = BotGlobalState.GetBotData(npcBot)

    -- Назначаем линию, если еще не назначена
    if not lane_assigned then
        AssignLane(npcBot)
        lane_assigned = true
        
        -- Сохраняем желание фармить в глобальном состоянии
        botData.globalBotDesire = constants.globalBotDesire.LANING
        botData.localBotDesire = constants.laningBotDesire.MOVING_TO_LINE
    end
    
    -- Используем логику лайнинга (включая телепортацию)
    local new_last_check, new_last_action = 
        HeroLiningBehaviour.Think(npcBot, lane_assigned, last_teleport_check, last_teleport_action_time)
    
    -- Обновляем тайминги телепортации
    if new_last_check then
        last_teleport_check = new_last_check
    end
    if new_last_action then
        last_teleport_action_time = new_last_action
    end
end
