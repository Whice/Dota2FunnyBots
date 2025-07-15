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

-- Функция для выбора цели для атаки с учетом last hit и deny
function GetTargetToAttack(enemyCreeps, alliedCreeps, bot, priorityFunction)
    local botDamage = bot:GetAttackDamage()
    
    -- Проверка вражеских крипов для last hit
    local lastHitEnemies = {}
    for _, creep in ipairs(enemyCreeps) do
        if creep:IsAlive() then
            local actualDamage = creep:GetActualIncomingDamage(botDamage, DAMAGE_TYPE_PHYSICAL)
            if creep:GetHealth() <= actualDamage then
                table.insert(lastHitEnemies, {creep = creep, health = creep:GetHealth()})
            end
        end
    end
    if #lastHitEnemies > 0 then
        table.sort(lastHitEnemies, function(a, b) return a.health < b.health end)
        return lastHitEnemies[1].creep
    end

    -- Проверка союзных крипов для deny
    local denyAllies = {}
    for _, creep in ipairs(alliedCreeps) do
        if creep:IsAlive() and creep:GetHealth() < 0.5 * creep:GetMaxHealth() then
            local actualDamage = creep:GetActualIncomingDamage(botDamage, DAMAGE_TYPE_PHYSICAL)
            if creep:GetHealth() <= actualDamage then
                table.insert(denyAllies, {creep = creep, health = creep:GetHealth()})
            end
        end
    end
    if #denyAllies > 0 then
        table.sort(denyAllies, function(a, b) return a.health < b.health end)
        return denyAllies[1].creep
    end

    -- Если нет возможностей для last hit или deny, атаковать вражеского крипа с наивысшим приоритетом
    if #enemyCreeps > 0 then
        table.sort(enemyCreeps, function(a, b) return priorityFunction(a) > priorityFunction(b) end)
        return enemyCreeps[1]
    end

    return nil
end

-- Функция для атаки крипов в безопасной зоне с учетом last hit и deny
function AttackEnemyCreepsNearSafeLocation(safeLoc, attackRange)
    local enemyCreeps = bot:GetNearbyLaneCreeps(attackRange + 200, true)
    local alliedCreeps = bot:GetNearbyLaneCreeps(attackRange + 200, false)
    
    local priorityFunction = function(creep)
        return -GetUnitToLocationDistance(creep, safeLoc)
    end
    
    local target = GetTargetToAttack(enemyCreeps, alliedCreeps, bot, priorityFunction)
    
    if target then
        bot:Action_AttackUnit(target, false)
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
    
    -- Если бот в безопасной зоне, атаковать крипов с учетом last hit и deny
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
            -- Получаем, как далеко вдоль линии находится крип (0.0 - 1.0)
            local creepLanePos = GetAmountAlongLane(lane, creep:GetLocation()).amount
            if creepLanePos > maxLanePos then
                maxLanePos = creepLanePos
                frontCreep = creep
            end
        end
    end

    -- Логика позиционирования
    if frontCreep then
        -- Позиция за дальним крипом (200 единиц ближе к базе)
        local baseLoc = GetLocationAlongLane(lane, 0.0)
        local creepLoc = frontCreep:GetLocation()
        local dir = (creepLoc - baseLoc):Normalized()
        local targetLoc = creepLoc - dir * 200
        
        if GetUnitToLocationDistance(bot, targetLoc) > 50 then
            bot:Action_MoveToLocation(targetLoc)
        else
            -- Если уже на позиции, атаковать крипов с учетом last hit и deny
            local enemyCreeps = bot:GetNearbyLaneCreeps(attackRange + 100, true)
            local alliedCreeps = bot:GetNearbyLaneCreeps(attackRange + 100, false)
            
            local priorityFunction = function(creep)
                return -GetUnitToUnitDistance(creep, bot)
            end
            
            local target = GetTargetToAttack(enemyCreeps, alliedCreeps, bot, priorityFunction)
            
            if target then
                bot:Action_AttackUnit(target, false)
            end
        end
    else
        -- Движение к безопасной точке с проверкой дистанции
        if distToSafe > 300 then
            bot:Action_MoveToLocation(safeLoc)
        else
            -- Если уже у башни, патрулировать небольшую зону
            local patrolPoint = GetLocationAlongLane(lane, 0.35)
            if GetUnitToLocationDistance(bot, patrolPoint) > 200 then
                bot:Action_MoveToLocation(patrolPoint)
            end
        end
    end
end