-- Behaviuors/HeroLiningDesireBehaviour.lua

-- Модуль для оценки желаний героя на линии (лайнинг)
local HeroLiningDesireBehaviour = {}

-- Импортируем глобальное состояние и константы
local BotGlobalState = require(GetScriptDirectory().."/AdditionalFunctions/BotGlobalState")
local Constants = require(GetScriptDirectory().."/AdditionalFunctions/Constants")

-- Константы для оценки
HeroLiningDesireBehaviour.LANE_FRONT_DISTANCE_THRESHOLD = 700  -- Расстояние, при котором считаем, что мы далеко от линии фронта
HeroLiningDesireBehaviour.CREEPS_NEARBY_RADIUS = 1000          -- Радиус для поиска крипов рядом

-- Оценка желания добивать крипов (LASTHIT_CRREP)
-- Возвращает значение от 0 до 1
function HeroLiningDesireBehaviour.EvaluateLastHitCreepDesire(bot)
    if not bot then
        return 0
    end
    
    -- Проверяем наличие вражеских крипов рядом
    local enemyCreeps = bot:GetNearbyCreeps(HeroLiningDesireBehaviour.CREEPS_NEARBY_RADIUS, true)
    
    if #enemyCreeps > 0 then
        -- Есть крипы для добивания
        return 0.9  -- Высокое желание
    else
        -- Нет крипов рядом
        return 0
    end
end

-- Оценка желания идти на линию (MOVING_TO_LINE)
-- Возвращает значение от 0 до 1
function HeroLiningDesireBehaviour.EvaluateMovingToLineDesire(bot)
    if not bot then
        return 0
    end
    
    local botData = BotGlobalState.GetBotData(bot)
    local target_lane = botData.target_lane
    
    if target_lane == LANE_NONE then
        return 0.8  -- Линия не назначена, нужно назначить и идти
    end
    
    -- Получаем позицию линии фронта
    local laneFront = GetLaneFrontLocation(bot:GetTeam(), target_lane, 0)
    if not laneFront then
        return 0.8  -- Не можем получить позицию линии
    end
    
    -- Вычисляем расстояние до линии фронта
    local distanceToLaneFront = GetUnitToLocationDistance(bot, laneFront)
    
    if distanceToLaneFront > HeroLiningDesireBehaviour.LANE_FRONT_DISTANCE_THRESHOLD then
        -- Мы далеко от линии фронта
        return 0.9  -- Высокое желание идти на линию
    else
        -- Мы близко к линии фронта
        return 0.1  -- Низкое желание (уже на месте)
    end
end

-- Оценка желания харасить вражеского героя (ENEMY_HERO_HARAS)
-- Пока всегда возвращает 0
function HeroLiningDesireBehaviour.EvaluateEnemyHeroHarasDesire(bot)
    return 0
end

-- Оценка желания отступать (RETREATING_ON_LINE)
-- Пока всегда возвращает 0
function HeroLiningDesireBehaviour.EvaluateRetreatingDesire(bot)
    return 0
end

-- Оценка желания восстановить HP (RESTORING_HP)
-- Пока всегда возвращает 0
function HeroLiningDesireBehaviour.EvaluateRestoringHpDesire(bot)
    return 0
end

-- Оценка желания восстановить ману (RESTORING_MANA)
-- Пока всегда возвращает 0
function HeroLiningDesireBehaviour.EvaluateRestoringManaDesire(bot)
    return 0
end

-- Основная функция: собирает все оценки, выбирает максимальное желание и устанавливает его в BotGlobalState
function HeroLiningDesireBehaviour.UpdateLaningDesire(bot)
    if not bot then
        return
    end
    
    local botData = BotGlobalState.GetBotData(bot)
    
    -- Собираем оценки для всех типов желаний
    local desires = {
        [Constants.laningBotDesire.MOVING_TO_LINE] = HeroLiningDesireBehaviour.EvaluateMovingToLineDesire(bot),
        [Constants.laningBotDesire.LASTHIT_CRREP] = HeroLiningDesireBehaviour.EvaluateLastHitCreepDesire(bot),
        [Constants.laningBotDesire.ENEMY_HERO_HARAS] = HeroLiningDesireBehaviour.EvaluateEnemyHeroHarasDesire(bot),
        [Constants.laningBotDesire.RETREATING_ON_LINE] = HeroLiningDesireBehaviour.EvaluateRetreatingDesire(bot),
        [Constants.laningBotDesire.RESTORING_HP] = HeroLiningDesireBehaviour.EvaluateRestoringHpDesire(bot),
        [Constants.laningBotDesire.RESTORING_MANA] = HeroLiningDesireBehaviour.EvaluateRestoringManaDesire(bot)
    }
    
    -- Находим максимальное значение
    local maxDesireValue = 0
    local maxDesireType = Constants.laningBotDesire.MOVING_TO_LINE  -- Значение по умолчанию
    
    for desireType, desireValue in pairs(desires) do
        if desireValue > maxDesireValue then
            maxDesireValue = desireValue
            maxDesireType = desireType
        end
    end
    
    -- Устанавливаем желания в глобальное состояние
    botData.globalBotDesire = Constants.globalBotDesire.LANING
    botData.localBotDesire = maxDesireType
end

return HeroLiningDesireBehaviour