local mode = {}
local target_lane = LANE_NONE

function mode.OnStart()
    local bot = GetBot()
    target_lane = bot:GetAssignedLane()
    if target_lane == LANE_NONE then
        target_lane = LANE_MID -- Назначить линию, если нет назначения
    end
    print("Starting laning mode on lane: "..target_lane)
end

function mode.Think()
    local bot = GetBot()
    local front = GetLaneFrontLocation(GetTeam(), target_lane, 0)
    
    if GetUnitToLocationDistance(bot, front) > 1200 then
        bot:Action_MoveToLocation(front)
    else
        local creeps = bot:GetNearbyLaneCreeps(800, true) -- Вражеские крипы
        if #creeps > 0 then
            -- Поиск крипа с малым здоровьем для ластхита
            local target = nil
            for _, creep in ipairs(creeps) do
                if creep:GetHealth() < bot:GetAttackDamage() then
                    target = creep
                    break
                end
            end
            
            if target then
                bot:Action_AttackUnit(target, false)
            else
                bot:Action_AttackMove(front)
            end
        else
            bot:Action_MoveToLocation(front)
        end
    end
end

return mode