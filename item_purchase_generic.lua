function ItemPurchaseThink()
    local bot = GetBot()
    local itemsToBuy = {
        "item_boots",
        "item_wind_lace",
        "item_power_treads",
        "item_ring_of_health",
        "item_vanguard",
        "item_void_stone",
        "item_linkens_sphere"
    }

    for _, itemName in ipairs(itemsToBuy) do
        if bot:GetGold() >= GetItemCost(itemName) and not bot:HasItemInSlot(0, itemName) then
            ActionImmediate_PurchaseItem(itemName)
            return
        end
    end
end