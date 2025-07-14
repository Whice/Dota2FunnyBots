function UpdatePushLaneDesires()
    local top = 0
    local mid = 0
    local bot = 0

    if GameTime() >= 600 then
        local lanes = {LANE_TOP, LANE_MID, LANE_BOT}
        for _, lane in ipairs(lanes) do
            local tower = GetTower(GetTeam(), lane)
            if tower ~= nil and tower:IsAlive() then
                local desire = 1.0 - (tower:GetHealth() / tower:GetMaxHealth())
                if lane == LANE_TOP then top = desire end
                if lane == LANE_MID then mid = desire end
                if lane == LANE_BOT then bot = desire end
            end
        end
    end

    return top, mid, bot
end