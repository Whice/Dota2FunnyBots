local bot = GetBot()

-- Функция для получения ближайшей башни на линии
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

-- Основная логика поведения
function Think()
    if not bot:IsAlive() then return end
    
    -- Распределение линий
    local lane = bot.assigned_lane
    if not lane then
        local teamPlayers = GetTeamPlayers(GetTeam())
        table.sort(teamPlayers)
        
        for i, playerId in ipairs(teamPlayers) do
            if playerId == bot:GetPlayerID() then
                if i <= 2 then
                    lane = LANE_TOP
                elseif i == 3 then
                    lane = LANE_MID
                else
                    lane = LANE_BOT
                end
                bot.assigned_lane = lane
                break
            end
        end
    end
    
    -- Поиск союзных крипов на линии
    local allyCreeps = bot:GetNearbyLaneCreeps(1600, false)
    local frontCreep = nil
    local maxLanePos = -1
    
    for _, creep in ipairs(allyCreeps) do
        if creep:GetTeam() == GetTeam() then
            local creepLanePos = GetLocationAlongLane(lane, creep:GetLocation())
            if creepLanePos > maxLanePos then
                maxLanePos = creepLanePos
                frontCreep = creep
            end
        end
    end

    -- Логика позиционирования
    if frontCreep then
        -- Позиция за дальним крипом
        local baseLoc = GetLocationAlongLane(lane, 0.0)
        local creepLoc = frontCreep:GetLocation()
        local dir = (creepLoc - baseLoc):Normalized()
        local targetLoc = creepLoc - dir * 200
        
        if GetUnitToLocationDistance(bot, targetLoc) > 50 then
            bot:Action_MoveToLocation(targetLoc)
        end
    else
        -- Отступ к башне
        local safeLoc = GetSafeLocation(lane)
        if GetUnitToLocationDistance(bot, safeLoc) > 300 then
            bot:Action_MoveToLocation(safeLoc)
        end
    end
end