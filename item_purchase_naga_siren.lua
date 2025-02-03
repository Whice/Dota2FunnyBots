local bot = GetBot()

local function BuyItems()
    -- Получаем текущее количество золота у бота
    local gold = bot:GetGold()
    local itemCost = 0
    local itemName = "item_slippers"
    local itemCost = GetItemCost(itemName)
    if itemCost < gold then
        -- bot:ActionImmediate_Chat("Buy item: " .. itemName, true)
        local count = 0
        -- Покупаем предмет, пока у бота достаточно золота
        while count < 6 do
            bot:ActionImmediate_PurchaseItem(itemName)
            count = count + 1
        end
    end
end

function ItemPurchaseThink()
    BuyItems()
end
