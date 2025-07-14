function GetDesire()
    if GameTime() >= 600 then
        return BOT_MODE_DESIRE_HIGH
    end
    return BOT_MODE_DESIRE_NONE
end

function Think()
    local bot = GetBot()
    if bot:GetHealth() / bot:GetMaxHealth() < 0.2 then
        ActionImmediate_MoveToLocation(GetShopLocation(bot:GetTeam(), SHOP_HOME))
        return
    end

    -- Определение сложной линии (минимум башен)
    local lanes = {LANE_TOP, LANE_MID, LANE_BOT}
    local minTowerCount = 999
    local targetLane = LANE_TOP

    for _, lane in ipairs(lanes) do
        local tower = GetTower(bot:GetTeam(), lane)
        if tower ~= nil and tower:IsAlive() then
            local count = 0
            for i = 1, 3 do
                local nearbyTowers = bot:GetNearbyTowers(1000, true)
                count = count + #nearbyTowers
            end
            if count < minTowerCount then
                minTowerCount = count
                targetLane = lane
            end
        end
    end

    local laneFront = GetLaneFrontLocation(bot:GetTeam(), targetLane, 0)
    Action_MoveToLocation(laneFront)
end