-- Модуль для поведения героя на линии (лайнинг)
local HeroLiningBehaviour = {}

-- Импортируем глобальное состояние
local BotGlobalState = require(GetScriptDirectory().."/AdditionalFunctions/BotGlobalState")
local Constants = require(GetScriptDirectory().."/AdditionalFunctions/Constants")
local TeleportHelper = require(GetScriptDirectory().."/AdditionalFunctions/TeleportHelper")
local MovingHelper = require(GetScriptDirectory() .. "/AdditionalFunctions/MovingHelper")
local HeroLiningDesireBehaviour = require(GetScriptDirectory().."/Behaviuors/HeroLiningDesireBehaviour")

-- Вспомогательные функции -----------------------------------------------------------------

-- Обновляет точку фарма на линии
local function UpdateFarmLocation(hBot, target_lane)
    local botData = BotGlobalState.GetBotData(hBot)
    if botData.farm_location == nil then
        botData.farm_location = GetLaneFrontLocation(hBot:GetTeam(), target_lane, 0)
    end
    return botData.farm_location
end

-- Находит крипа с наименьшим здоровьем для добивания
local function FindLowestHealthCreepForLastHit(hBot, radius)
    local creeps = hBot:GetNearbyCreeps(radius, true)
    
    if #creeps == 0 then
        return nil
    end
    
    local lowestHealthCreep = nil
    local lowestHealth = 10000
    
    for _, creep in ipairs(creeps) do
        if creep and creep:IsAlive() then
            local health = creep:GetHealth()
            if health < lowestHealth then
                lowestHealth = health
                lowestHealthCreep = creep
            end
        end
    end
    
    return lowestHealthCreep
end

-- Получает позицию линии фронта для бота
local function GetLaneFrontForBot(hBot, target_lane)
    if target_lane == LANE_NONE then
        return nil
    end
    return GetLaneFrontLocation(hBot:GetTeam(), target_lane, 0)
end

-- Функции обработки конкретных желаний ----------------------------------------------------

-- Обработка желания MOVING_TO_LINE - движение к линии
local function HandleMovingToLineDesire(hBot, target_lane)
    local laneFront = GetLaneFrontForBot(hBot, target_lane)
    if laneFront then
        MovingHelper.MoveToPosition(hBot, laneFront)
    end
end

-- Обработка желания LASTHIT_CRREP - добивание крипов
local function HandleLastHitCreepDesire(hBot, target_lane)
    local lowestHealthCreep = FindLowestHealthCreepForLastHit(hBot, 1000)
    
    if lowestHealthCreep then
        -- Атакуем крипа для добивания
        hBot:Action_AttackUnit(lowestHealthCreep, false)
    else
        -- Если крипов нет, двигаемся к линии
        local laneFront = GetLaneFrontForBot(hBot, target_lane)
        if laneFront then
            hBot:Action_MoveToLocation(laneFront)
        end
    end
end

-- Обработка желания ENEMY_HERO_HARAS - харас вражеского героя
local function HandleEnemyHeroHarasDesire(hBot, target_lane)
    -- TODO: Реализовать логику хараса вражеского героя
    -- Временно двигаемся к линии
    local laneFront = GetLaneFrontForBot(hBot, target_lane)
    if laneFront then
        hBot:Action_MoveToLocation(laneFront)
    end
end

-- Обработка желания RETREATING_ON_LINE - отступление
local function HandleRetreatingDesire(hBot, target_lane)
    -- TODO: Реализовать логику отступления
    -- Временно двигаемся к своей базе
    local team = hBot:GetTeam()
    local ancient = GetAncient(team)
    if ancient then
        hBot:Action_MoveToLocation(ancient:GetLocation())
    end
end

-- Обработка желания RESTORING_HP - восстановление здоровья
local function HandleRestoringHpDesire(hBot, target_lane)
    -- TODO: Реализовать логику восстановления HP
    -- Временно двигаемся к линии
    local laneFront = GetLaneFrontForBot(hBot, target_lane)
    if laneFront then
        hBot:Action_MoveToLocation(laneFront)
    end
end

-- Обработка желания RESTORING_MANA - восстановление маны
local function HandleRestoringManaDesire(hBot, target_lane)
    -- TODO: Реализовать логику восстановления маны
    -- Временно двигаемся к линии
    local laneFront = GetLaneFrontForBot(hBot, target_lane)
    if laneFront then
        hBot:Action_MoveToLocation(laneFront)
    end
end

-- Маппинг функций обработчиков для каждого типа желания
local DESIRE_HANDLERS = {
    [Constants.laningBotDesire.MOVING_TO_LINE] = HandleMovingToLineDesire,
    [Constants.laningBotDesire.LASTHIT_CRREP] = HandleLastHitCreepDesire,
    [Constants.laningBotDesire.ENEMY_HERO_HARAS] = HandleEnemyHeroHarasDesire,
    [Constants.laningBotDesire.RETREATING_ON_LINE] = HandleRetreatingDesire,
    [Constants.laningBotDesire.RESTORING_HP] = HandleRestoringHpDesire,
    [Constants.laningBotDesire.RESTORING_MANA] = HandleRestoringManaDesire,
}

-- Основная функция лайнинга --------------------------------------------------------------

function HeroLiningBehaviour.Think(hBot, lane_assigned, last_teleport_check, last_teleport_action_time)
    local botData = BotGlobalState.GetBotData(hBot)
    local target_lane = botData.target_lane
    
    -- Обновляем желание
    HeroLiningDesireBehaviour.UpdateLaningDesire(hBot)
    
    -- Обновляем точку фарма
    UpdateFarmLocation(hBot, target_lane)
        
    -- Выполняем действие в зависимости от текущего желания
    local handler = DESIRE_HANDLERS[botData.localBotDesire]
    if handler then
        handler(hBot, target_lane)
    else
        -- Если обработчик не найден, используем дефолтное поведение
        HandleMovingToLineDesire(hBot, target_lane)
    end
    
    return last_teleport_check, last_teleport_action_time
end

return HeroLiningBehaviour