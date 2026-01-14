-- AdditionalFunctions/TowersHelper.lua
local TowersHelper = {}

-- Константы для номеров башен по линиям
TowersHelper.TOWER_INDICES = {
    [LANE_TOP] = {0, 1, 2},      -- Башни на топ линии
    [LANE_MID] = {3, 4, 5},      -- Башни на мид линии
    [LANE_BOT] = {6, 7, 8},      -- Башни на бот линии
    [LANE_NONE] = {8, 9}         -- Башни у трона (базовые)
}

-- Получить башню на линии для своей команды
-- @param bot - ссылка на бота (для определения команды)
-- @param lane - номер линии (LANE_TOP, LANE_MID, LANE_BOT)
-- @param towerIndexOnLane - индекс башни на линии (0-2, где 0 - внешняя, 2 - ближайшая к базе)
-- @return ссылка на башню или nil, если башни нет
function TowersHelper.GetAllyTowerForLane(bot, lane, towerIndexOnLane)
    if not bot or not lane then
        return nil
    end
    
    local team = bot:GetTeam()
    local towerIndices = TowersHelper.TOWER_INDICES[lane]
    
    if not towerIndices or towerIndexOnLane < 0 or towerIndexOnLane >= #towerIndices then
        return nil
    end
    
    local towerNumber = towerIndices[towerIndexOnLane + 1] -- +1 потому что Lua индексирует с 1
    local tower = GetTower(team, towerNumber)
    
    -- Проверяем, что башня существует и жива
    if tower and tower:IsAlive() then
        return tower
    end
    
    return nil
end

-- Получить башню на линии для команды противника
-- @param bot - ссылка на бота (для определения команды противника)
-- @param lane - номер линии (LANE_TOP, LANE_MID, LANE_BOT)
-- @param towerIndexOnLane - индекс башни на линии (0-2, где 0 - внешняя, 2 - ближайшая к базе)
-- @return ссылка на башню или nil, если башни нет
function TowersHelper.GetEnemyTowerForLane(bot, lane, towerIndexOnLane)
    if not bot or not lane then
        return nil
    end
    
    local enemyTeam = GetOpposingTeam(bot:GetTeam())
    local towerIndices = TowersHelper.TOWER_INDICES[lane]
    
    if not towerIndices or towerIndexOnLane < 0 or towerIndexOnLane >= #towerIndices then
        return nil
    end
    
    local towerNumber = towerIndices[towerIndexOnLane + 1] -- +1 потому что Lua индексирует с 1
    local tower = GetTower(enemyTeam, towerNumber)
    
    -- Проверяем, что башня существует и жива
    if tower and tower:IsAlive() then
        return tower
    end
    
    return nil
end

-- Получить первую доступную (живую) башню на линии для своей команды
-- Проверяет в порядке от внешней к внутренней: 0 -> 1 -> 2
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @return ссылка на первую живую башню или nil, если все разрушены
function TowersHelper.GetFirstAvailableAllyTowerForLane(bot, lane)
    if not bot or not lane then
        return nil
    end
    
    local towerIndices = TowersHelper.TOWER_INDICES[lane]
    if not towerIndices then
        return nil
    end
    
    -- Проверяем башни от внешней к внутренней (индексы 0, 1, 2)
    for i = 1, #towerIndices do
        local towerIndex = i - 1  -- Преобразуем в 0-based индекс
        local tower = TowersHelper.GetAllyTowerForLane(bot, lane, towerIndex)
        if tower then
            return tower
        end
    end
    
    return nil
end

-- Получить первую доступную (живую) башню на линии для своей команды (от внутренней к внешней)
-- Проверяет в порядке от внутренней к внешней: 2 -> 1 -> 0
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @return ссылка на первую живую башню или nil, если все разрушены
function TowersHelper.GetFirstAvailableAllyTowerForLaneFromInner(bot, lane)
    if not bot or not lane then
        return nil
    end
    
    local towerIndices = TowersHelper.TOWER_INDICES[lane]
    if not towerIndices then
        return nil
    end
    
    -- Проверяем башни от внутренней к внешней (индексы 2, 1, 0)
    for i = #towerIndices, 1, -1 do
        local towerIndex = i - 1  -- Преобразуем в 0-based индекс
        local tower = TowersHelper.GetAllyTowerForLane(bot, lane, towerIndex)
        if tower then
            return tower
        end
    end
    
    return nil
end

-- Получить первую доступную (живую) башню на линии для команды противника
-- Проверяет в порядке от внешней к внутренней: 0 -> 1 -> 2
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @return ссылка на первую живую башню противника или nil, если все разрушены
function TowersHelper.GetFirstAvailableEnemyTowerForLane(bot, lane)
    if not bot or not lane then
        return nil
    end
    
    local towerIndices = TowersHelper.TOWER_INDICES[lane]
    if not towerIndices then
        return nil
    end
    
    -- Проверяем башни от внешней к внутренней (индексы 0, 1, 2)
    for i = 1, #towerIndices do
        local towerIndex = i - 1  -- Преобразуем в 0-based индекс
        local tower = TowersHelper.GetEnemyTowerForLane(bot, lane, towerIndex)
        if tower then
            return tower
        end
    end
    
    return nil
end

-- Получить ближайшую живую союзную башню на указанной линии
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @return ссылка на ближайшую живую башню или nil
function TowersHelper.GetNearestAllyTowerOnLane(bot, lane)
    if not bot or not lane then
        return nil
    end
    
    local team = bot:GetTeam()
    local towerIndices = TowersHelper.TOWER_INDICES[lane]
    
    if not towerIndices then
        return nil
    end
    
    local nearestTower = nil
    local nearestDistance = 99999
    
    for i = 1, #towerIndices do
        local towerNumber = towerIndices[i]
        local tower = GetTower(team, towerNumber)
        
        if tower and tower:IsAlive() then
            local distance = GetUnitToUnitDistance(bot, tower)
            if distance < nearestDistance then
                nearestDistance = distance
                nearestTower = tower
            end
        end
    end
    
    return nearestTower
end

-- Получить башню, которая находится ближе всего к столкновению крипов на линии
-- Использует алгоритм: проверяет индексы 0, 1, 2 в порядке возрастания
-- Если жива 0, то это она, если нет, то проверяет 1, если жива 1, то это она, иначе проверяет 2
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @return ссылка на башню или nil, если все башни на линии разрушены
function TowersHelper.GetTowerNearCreepClash(bot, lane)
    if not bot or not lane then
        return nil
    end
    
    -- Проверяем по порядку: 0 (внешняя), 1 (средняя), 2 (внутренняя)
    for i = 0, 2 do
        local tower = TowersHelper.GetAllyTowerForLane(bot, lane, i)
        if tower then
            return tower
        end
    end
    
    return nil
end

-- Получить информацию о всех башнях на линии
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @return таблица с информацией о башнях
function TowersHelper.GetTowerInfoForLane(bot, lane)
    if not bot or not lane then
        return {}
    end
    
    local team = bot:GetTeam()
    local enemyTeam = GetOpposingTeam(team)
    local towerIndices = TowersHelper.TOWER_INDICES[lane]
    
    if not towerIndices then
        return {}
    end
    
    local towerInfo = {}
    
    for i = 1, #towerIndices do
        local towerNumber = towerIndices[i]
        
        -- Союзная башня
        local allyTower = GetTower(team, towerNumber)
        local enemyTower = GetTower(enemyTeam, towerNumber)
        
        towerInfo[i] = {
            towerNumber = towerNumber,
            positionOnLane = i-1, -- 0, 1, 2
            allyTower = allyTower,
            allyTowerAlive = allyTower and allyTower:IsAlive() or false,
            enemyTower = enemyTower,
            enemyTowerAlive = enemyTower and enemyTower:IsAlive() or false,
            description = self:GetTowerDescription(i-1, lane)  -- Добавим описание
        }
    end
    
    return towerInfo
end

-- Получить текстовое описание башни
-- @param positionOnLane - позиция на линии (0-2)
-- @param lane - номер линии
-- @return строковое описание башни
function TowersHelper.GetTowerDescription(positionOnLane, lane)
    local laneName = "неизвестная"
    if lane == LANE_TOP then laneName = "топ" end
    if lane == LANE_MID then laneName = "мид" end
    if lane == LANE_BOT then laneName = "бот" end
    
    local positionName = "внешняя"
    if positionOnLane == 1 then positionName = "средняя" end
    if positionOnLane == 2 then positionName = "внутренняя" end
    
    return positionName .. " башня на " .. laneName .. " линии"
end

-- Проверить, есть ли живые союзные башни на линии
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @return true если есть хотя бы одна живая башня
function TowersHelper.HasAllyTowersOnLane(bot, lane)
    local towerInfo = TowersHelper.GetTowerInfoForLane(bot, lane)
    
    for _, info in ipairs(towerInfo) do
        if info.allyTowerAlive then
            return true
        end
    end
    
    return false
end

-- Проверить, есть ли живые вражеские башни на линии
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @return true если есть хотя бы одна живая вражеская башня
function TowersHelper.HasEnemyTowersOnLane(bot, lane)
    local towerInfo = TowersHelper.GetTowerInfoForLane(bot, lane)
    
    for _, info in ipairs(towerInfo) do
        if info.enemyTowerAlive then
            return true
        end
    end
    
    return false
end

-- Получить внешнюю башню (первую на линии)
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @param forEnemy - true для вражеской башни, false для союзной
-- @return ссылка на башню или nil
function TowersHelper.GetOuterTower(bot, lane, forEnemy)
    if forEnemy then
        return TowersHelper.GetEnemyTowerForLane(bot, lane, 0)
    else
        return TowersHelper.GetAllyTowerForLane(bot, lane, 0)
    end
end

-- Получить среднюю башню (вторую на линии)
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @param forEnemy - true для вражеской башни, false для союзной
-- @return ссылка на башню или nil
function TowersHelper.GetMiddleTower(bot, lane, forEnemy)
    if forEnemy then
        return TowersHelper.GetEnemyTowerForLane(bot, lane, 1)
    else
        return TowersHelper.GetAllyTowerForLane(bot, lane, 1)
    end
end

-- Получить внутреннюю башню (третью на линии)
-- @param bot - ссылка на бота
-- @param lane - номер линии
-- @param forEnemy - true для вражеской башни, false для союзной
-- @return ссылка на башню или nil
function TowersHelper.GetInnerTower(bot, lane, forEnemy)
    if forEnemy then
        return TowersHelper.GetEnemyTowerForLane(bot, lane, 2)
    else
        return TowersHelper.GetAllyTowerForLane(bot, lane, 2)
    end
end

return TowersHelper