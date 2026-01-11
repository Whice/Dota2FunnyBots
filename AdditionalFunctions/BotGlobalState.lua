local BotGlobalState = {
    _botsData = {}
}

function BotGlobalState.GetBotData(hBot)
    if not BotGlobalState._botsData[hBot] then
        BotGlobalState._botsData[hBot] = {
            desire = "",
            -- Можно добавить другие поля по умолчанию
            lastDesireChange = 0,
            customData = {}
        }
    end
    return BotGlobalState._botsData[hBot]
end

return BotGlobalState