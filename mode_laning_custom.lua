function GetDesire()
    if GameTime() < 300 then
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

    local target = bot:GetAttackTarget()
    if target ~= nil and target:IsCreep() then
        Action_AttackUnit(target, false)
    else
        local creeps = bot:GetNearbyLaneCreeps(1000, false)
        if #creeps > 0 then
            Action_AttackUnit(creeps[1], false)
        end
    end
end