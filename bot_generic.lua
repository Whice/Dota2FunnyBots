function Think()
    local bot = GetBot()
    if not bot:IsAlive() then return end

    -- Возврат на базу при низком здоровье
    if bot:GetHealth() / bot:GetMaxHealth() < 0.20 then
        local team = bot:GetTeam()
        if team == TEAM_RADIANT then
            bot:Action_MoveToLocation(Vector(-7200, -6700)) -- фонтан Radiant
        else
            bot:Action_MoveToLocation(Vector(7200, 6700)) -- фонтан Dire
        end
        return
    end

    local time = DotaTime()

    if time < 300 then
        -- Лайнинг до 5-й минуты
        local creeps = bot:GetNearbyLaneCreeps(1200, true)
        if #creeps > 0 then
            bot:Action_AttackUnit(creeps[1], false)
        else
            bot:Action_MoveToLocation(GetLaneFrontLocation(bot:GetTeam(), bot:GetAssignedLane(), 0))
        end
    elseif time < 600 then
        -- Фарм леса с 5-й до 10-й минуты
        local neutrals = bot:GetNearbyNeutralCreeps(1200)
        if #neutrals > 0 then
            bot:Action_AttackUnit(neutrals[1], false)
        else
            local camps = GetNeutralSpawners()
            local bestCamp = nil
            for _, camp in pairs(camps) do
                local pos = camp[2]
                if bestCamp == nil or GetUnitToLocationDistance(bot, pos) < GetUnitToLocationDistance(bot, bestCamp) then
                    bestCamp = pos
                end
            end
            if bestCamp then
                bot:Action_MoveToLocation(bestCamp)
            end
        end
    else
        -- Пуш после 10-й минуты
        local pushPoint = bot:GetTeam() == TEAM_RADIANT and Vector(5000, 6000) or Vector(-5000, -5000)
        bot:Action_AttackMove(pushPoint)
    end
end
