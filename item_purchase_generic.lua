function ItemPurchaseThink()
    local bot = GetBot()
    if not bot:IsAlive() then return end

    if not bot.nextItemIndex then
        bot.nextItemIndex = 1
    end

    local items = {
        "item_boots",
        "item_wind_lace",
        "item_power_treads",
        "item_ring_of_health",
        "item_vanguard",
        "item_void_stone",
        "item_sphere"
    }

    local index = bot.nextItemIndex
    if index > #items then return end

    local item = items[index]
    if bot:GetGold() >= GetItemCost(item) then
        bot:ActionImmediate_PurchaseItem(item)
        bot.nextItemIndex = index + 1
    end
end
