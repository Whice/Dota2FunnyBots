local mode = {}

function mode.OnStart()
    local bot = GetBot()
    local hardest_lane = GetMostPushedLane()  -- Логика определения сложной линии
    
    local push_loc = GetLaneFrontLocation(GetTeam(), hardest_lane, -500)
    bot:Action_MoveToLocation(push_loc)
    
    local towers = bot:GetNearbyTowers(700, true)
    if #towers > 0 then
        bot:Action_AttackUnit(towers[1], false)
    else
        local creeps = bot:GetNearbyCreeps(600, true)
        if #creeps > 0 then
            bot:Action_AttackUnit(creeps[1], false)
        end
    end
end

function GetMostPushedLane()
    -- Логика определения самой сложной линии
    local top_push = GetPushLaneDesire(LANE_TOP)
    local mid_push = GetPushLaneDesire(LANE_MID)
    local bot_push = GetPushLaneDesire(LANE_BOT)
    
    if top_push > mid_push and top_push > bot_push then
        return LANE_TOP
    elseif mid_push > bot_push then
        return LANE_MID
    else
        return LANE_BOT
    end
end

function mode.GetDesire()
    return (DotaTime() >= 600) and 0.95 or 0.1
end

return mode