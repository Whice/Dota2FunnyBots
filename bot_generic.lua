local bot = GetBot()

-- Функция для получения ближайшей живой союзной башни на линии
function GetAllyTowerInLane(lane)
    local towers = {
        [LANE_TOP] = {TOWER_TOP_1, TOWER_TOP_2, TOWER_TOP_3},
        [LANE_MID] = {TOWER_MID_1, TOWER_MID_2, TOWER_MID_3},
        [LANE_BOT] = {TOWER_BOT_1, TOWER_BOT_2, TOWER_BOT_3}
    }
    
    for _, towerId in ipairs(towers[lane]) do
        local tower = GetTower(GetTeam(), towerId)
        if tower and tower:IsAlive() then
            return tower
        end
    end
    return nil
end

-- Функция для определения позиции отступления
function GetSafeLocation(lane)
    local tower = GetAllyTowerInLane(lane)
    if tower then
        return tower:GetLocation()
    end
    return GetLocationAlongLane(lane, 0.3) -- Отступ к базе если башен нет
end

-- Функция для атаки вражеских крипов в безопасной зоне
function AttackEnemyCreepsNearSafeLocation(safeLoc, attackRange)
    -- Поиск вражеских крипов в радиусе атаки + небольшой запас
    local enemyCreeps = bot:GetNearbyLaneCreeps(attackRange + 200, true)
    
    if #enemyCreeps > 0 then
        -- Сортировка по расстоянию до безопасной точки
        table.sort(enemyCreeps, function(a, b)
            return GetUnitToLocationDistance(a, safeLoc) < GetUnitToLocationDistance(b, safeLoc)
        end)
        
        -- Атака ближайшего к башне вражеского крипа
        bot:Action_AttackUnit(enemyCreeps[1], false)
        return true
    end
    return false
end

-- Основная логика поведения
function Think()
    if not bot:IsAlive() then 
        return 
    end
    
    -- Распределение линий с сохранением назначения
    if not bot.assigned_lane then
        local teamPlayers = GetTeamPlayers(GetTeam())
        table.sort(teamPlayers)
        
        local lanes = {
            [1] = LANE_TOP,
            [2] = LANE_TOP,
            [3] = LANE_MID,
            [4] = LANE_BOT,
            [5] = LANE_BOT
        }
        
        for i, playerId in ipairs(teamPlayers) do
            if playerId == bot:GetPlayerID() then
                bot.assigned_lane = lanes[i] or LANE_MID
                break
            end
        end
    end
    
    local lane = bot.assigned_lane
    local safeLoc = GetSafeLocation(lane)
    local distToSafe = GetUnitToLocationDistance(bot, safeLoc)
    local attackRange = bot:GetAttackRange()
    
    -- Если бот в безопасной зоне, атаковать вражеских крипов
    if distToSafe < 600 then
        if AttackEnemyCreepsNearSafeLocation(safeLoc, attackRange) then
            return
        end
    end
    
    -- Поиск союзных крипов на линии
    local allyCreeps = bot:GetNearbyLaneCreeps(1600, false)
    local frontCreep = nil
    local maxLanePos = -1
    
    for _, creep in ipairs(allyCreeps) do
        if creep:GetTeam() == GetTeam() then
            -- Исправлено: используем GetAmountAlongLane вместо GetLocationAlongLane
            local laneAmount, _ = GetAmountAlongLane(lane, creep:GetLocation())
            if laneAmount > maxLanePos then
                maxLanePos = laneAmount
                frontCreep = creep
            end
        end
    end

    -- Логика позиционирования
    if frontCreep then
        -- Позиция за дальним крипом (200 единиц ближе к базе)
        local baseLoc = GetLocationAlongLane(lane, 0.0)  -- Корректный вызов
        local creepLoc = frontCreep:GetLocation()
        local dir = (creepLoc - baseLoc):Normalized()
        local targetLoc = creepLoc - dir * 200
        
        if GetUnitToLocationDistance(bot, targetLoc) > 50 then
            bot:Action_MoveToLocation(targetLoc)
        else
            -- Если уже на позиции, атаковать вражеских крипов
            local enemyCreeps = bot:GetNearbyLaneCreeps(attackRange + 100, true)
            if #enemyCreeps > 0 then
                bot:Action_AttackUnit(enemyCreeps[1], false)
            end
        end
    else
        -- Движение к безопасной точке с проверкой дистанции
        if distToSafe > 300 then
            bot:Action_MoveToLocation(safeLoc)
        else
            -- Если уже у башни, патрулировать небольшую зону
            local patrolPoint = GetLocationAlongLane(lane, 0.35)  -- Корректный вызов
            if GetUnitToLocationDistance(bot, patrolPoint) > 200 then
                bot:Action_MoveToLocation(patrolPoint)
            end
        end
    end
end