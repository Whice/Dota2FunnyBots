local mode = {}

function mode.OnStart()
    local bot = GetBot()
    bot:Action_ClearActions(true)
    print("Starting retreat mode")
end

function mode.Think()
    local bot = GetBot()
    local fountain = GetShopLocation(GetTeam(), SHOP_HOME)
    
    if GetUnitToLocationDistance(bot, fountain) > 200 then
        bot:Action_MoveToLocation(fountain)
    else
        -- Остаемся на базе до восстановления
        bot:Action_ClearActions(true)
    end
    
    -- Автоматическая покупка предметов на базе
    ItemPurchaseThink()
end

return mode