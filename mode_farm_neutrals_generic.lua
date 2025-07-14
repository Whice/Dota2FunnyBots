function GetDesire()
    if GameTime() >= 300 and GameTime() < 600 then
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

    local neutrals = bot:GetNearbyNeutralCreeps(1000)
    if #neutrals > 0 then
        Action_AttackUnit(neutrals[1], false)
    else
        local camps = GetNeutralSpawners()
        if #camps > 0 then
            local closestCamp = camps[1]
            Action_MoveToLocation(closestCamp[2])
        end
    end
end