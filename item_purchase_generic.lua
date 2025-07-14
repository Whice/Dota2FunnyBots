local item_sequence = {
    "item_boots",
    "item_wind_lace",
    "item_power_treads",
    "item_ring_of_health",
    "item_vanguard",
    "item_void_stone",
    "item_sphere"
}

function ItemPurchaseThink()
    local bot = GetBot()
    
    for _, item_name in ipairs(item_sequence) do
        if bot:FindItemSlot(item_name) == -1 then
            if bot:GetGold() >= GetItemCost(item_name) then
                bot:ActionImmediate_PurchaseItem(item_name)
                return
            end
        end
    end
    
    -- Покупка расходников, если основные куплены
    if bot:GetGold() > 600 then
        bot:ActionImmediate_PurchaseItem("item_tpscroll")
    end
end