-- Подключаем дополнительные функции
local SimpleActions = dofile(GetScriptDirectory().."/AdditionalFunctions/SimpleActions.lua")

local modeLaningSniper = {}

function modeLaningSniper.GetDesire()
    local npcBot = GetBot()
    
    -- Снайпер предпочитает лайнинг в начале игры
    local gameTime = DotaTime()
    
    if gameTime < 600 then  -- Первые 10 минут
        return BOT_MODE_DESIRE_HIGH
    elseif gameTime < 1200 then  -- 10-20 минут
        return BOT_MODE_DESIRE_MODERATE
    else
        return BOT_MODE_DESIRE_LOW
    end
end

function modeLaningSniper.OnStart()
    local npcBot = GetBot()
    -- Можно добавить логику при старте режима
end

function modeLaningSniper.OnEnd()
    -- Очистка при завершении режима
end

function modeLaningSniper.Think()
    local npcBot = GetBot()
    
    if not npcBot:IsAlive() then
        return
    end
    
    -- Основная логика лайнинга для снайпера
    local enemyHeroes = npcBot:GetNearbyHeroes(800, true, BOT_MODE_NONE)
    
    if #enemyHeroes > 0 then
        -- Есть враги поблизости - отступаем или атакуем с дистанции
        HandleEnemyPresence(npcBot, enemyHeroes)
    else
        -- Безопасный фарм
        SafeFarming(npcBot)
    end
end

function HandleEnemyPresence(npcBot, enemyHeroes)
    local nearestEnemy = enemyHeroes[1]
    local distance = GetUnitToUnitDistance(npcBot, nearestEnemy)
    
    -- Снайпер предпочитает держать дистанцию
    if distance < 600 then
        -- Слишком близко - отступаем
        local retreatPoint = npcBot:GetLocation()
        retreatPoint.x = retreatPoint.x - (nearestEnemy:GetLocation().x - retreatPoint.x)
        retreatPoint.y = retreatPoint.y - (nearestEnemy:GetLocation().y - retreatPoint.y)
        npcBot:Action_MoveToLocation(retreatPoint)
    elseif distance <= npcBot:GetAttackRange() then
        -- В пределах атаки - атакуем
        npcBot:Action_AttackUnit(nearestEnemy, false)
    else
        -- Держим дистанцию
        npcBot:Action_MoveToLocation(nearestEnemy:GetLocation())
    end
end

function SafeFarming(npcBot)
    -- Используем наши функции для фарма
    local lastHitTarget = SimpleActions.GetLastHitTarget(npcBot, 1000)
    local denyTarget = SimpleActions.GetDenyTarget(npcBot, 1000)
    
    if lastHitTarget then
        npcBot:Action_AttackUnit(lastHitTarget.unit, false)
    elseif denyTarget then
        npcBot:Action_AttackUnit(denyTarget.unit, false)
    else
        -- Двигаемся к точке фарма
        local lane = npcBot:GetAssignedLane()
        if lane == LANE_NONE then
            lane = LANE_MID
        end
        
        local laneFront = GetLaneFrontLocation(GetTeam(), lane, 0)
        if laneFront then
            npcBot:Action_MoveToLocation(laneFront)
        end
    end
end

return modeLaningSniper