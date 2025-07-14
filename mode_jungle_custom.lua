local mode = {}

function mode.OnStart()
    local bot = GetBot()
    local camps = GetNeutralSpawners()
    local nearest_camp = nil
    local min_dist = 10000
    
    for _, camp in pairs(camps) do
        local dist = GetUnitToLocationDistance(bot, camp[2])
        if dist < min_dist then
            min_dist = dist
            nearest_camp = camp[2]
        end
    end
    
    if nearest_camp then
        bot:Action_MoveToLocation(nearest_camp)
        local neutrals = bot:GetNearbyNeutralCreeps(600)
        if #neutrals > 0 then
            bot:Action_AttackUnit(neutrals[1], false)
        end
    end
end

function mode.GetDesire()
    local time = DotaTime()
    return (time >= 300 and time < 600) and 0.85 or 0.1
end

return mode