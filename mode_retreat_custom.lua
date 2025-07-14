local mode = {}

function mode.OnStart()
    local bot = GetBot()
    local fountain = GetShopLocation(GetTeam(), SHOP_HOME)
    
    if GetUnitToLocationDistance(bot, fountain) > 200 then
        bot:Action_MoveToLocation(fountain)
    else
        bot:Action_ClearActions(true)
    end
end

function mode.GetDesire()
    local bot = GetBot()
    local health_pct = bot:GetHealth() / bot:GetMaxHealth()
    return (health_pct < 0.2) and 1.0 or 0.0
end

return mode