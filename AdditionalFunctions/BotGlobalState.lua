local BotGlobalState = {
    _botsData = {}
}

function BotGlobalState.GetBotData(hBot)
    if not BotGlobalState._botsData[hBot] then
        BotGlobalState._botsData[hBot] = {
            globalBotDesire = -1,
            localBotDesire = -1,
            farm_location = nil,
            target_lane = LANE_NONE,
        }
    end
    return BotGlobalState._botsData[hBot]
end

return BotGlobalState