function Think()
    local bot = GetBot()
    local team = bot:GetTeam()

    -- Приоритетный возврат на базу при низком здоровье
    if bot:GetHealth() / bot:GetMaxHealth() < 0.2 and not bot:IsUsingAbility() then
        ActionImmediate_MoveToLocation(GetShopLocation(team, SHOP_HOME))
        return
    end

    -- Дефолтное поведение
    if bot:IsAlive() then
        local mode = bot:GetActiveMode()
        if mode == BOT_MODE_LANING then
            require("mode_laning_generic").Think()
        elseif mode == BOT_MODE_FARM then
            require("mode_farm_neutrals_generic").Think()
        elseif mode == BOT_MODE_PUSH_TOWER_TOP or
               mode == BOT_MODE_PUSH_TOWER_MID or
               mode == BOT_MODE_PUSH_TOWER_BOT then
            require("mode_push_tower_generic").Think()
        end
    end
end