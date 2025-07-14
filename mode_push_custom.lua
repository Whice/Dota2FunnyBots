local mode = {}
local target_lane = LANE_NONE
local last_lane_check = -90

function mode.OnStart()
    print("Starting push mode")
    target_lane = LANE_NONE
end

function mode.Think()
    local bot = GetBot()
    local time = DotaTime()
    
    -- Обновляем выбор линии каждые 30 секунд
    if target_lane == LANE_NONE or time - last_lane_check > 30 then
        target_lane = GetMostDangerousLane()
        last_lane_check = time
    end
    
    local push_loc = GetLaneFrontLocation(GetTeam(), target_lane, -500)
    
    -- Движение к линии
    if GetUnitToLocationDistance(bot, push_loc) > 600 then
        bot:Action_MoveToLocation(push_loc)
        return
    end
    
    -- Атака построек
    local towers = bot:GetNearbyTowers(700, true)
    if #towers > 0 then
        bot:Action_AttackUnit(towers[1], false)
        return
    end
    
    -- Атака крипов
    local creeps = bot:GetNearbyLaneCreeps(600, true)
    if #creeps > 0 then
        bot:Action_AttackUnit(creeps[1], false)
    else
        bot:Action_AttackMove(push_loc)
    end
end

function GetMostDangerousLane()
    local lane_pressure = {
        [LANE_TOP] = GetDefendLaneDesire(LANE_TOP),
        [LANE_MID] = GetDefendLaneDesire(LANE_MID),
        [LANE_BOT] = GetDefendLaneDesire(LANE_BOT)
    }
    
    local max_pressure = 0
    local dangerous_lane = LANE_MID
    
    for lane, pressure in pairs(lane_pressure) do
        if pressure > max_pressure then
            max_pressure = pressure
            dangerous_lane = lane
        end
    end
    
    return dangerous_lane
end

return mode