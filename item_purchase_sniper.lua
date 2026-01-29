-- item_purchase_sniper.lua
-- Переписанный скрипт покупок для Sniper с использованием коллекций

local ItemPurchaseCollectionManager = require(GetScriptDirectory().."/ItemPurchase/ItemPurchaseCollectionManager")

local botInitialized = false

local SNIPER_COLLECTIONS = {
    {
        {name = "item_branches", desired = 3}
    },
    
    {
        {name = "item_branches", desired = 3},
        {name = "item_wraith_band", desired = 2}
    },
    
    {
        {name = "item_branches", desired = 3},
        {name = "item_wraith_band", desired = 2},
        {name = "item_lifesteal", desired = 1}
    },
    
    {
        {name = "item_branches", desired = 3},
        {name = "item_wraith_band", desired = 2},
        {name = "item_lifesteal", desired = 1},
        {name = "item_boots", desired = 1}
    },
    
    {
        {name = "item_branches", desired = 2},
        {name = "item_wraith_band", desired = 2},
        {name = "item_lifesteal", desired = 1},
        {name = "item_maelstrom", desired = 1},
        {name = "item_boots", desired = 1}
    },
    
    {
        {name = "item_branches", desired = 1},
        {name = "item_wraith_band", desired = 2},
        {name = "item_lifesteal", desired = 1},
        {name = "item_maelstrom", desired = 1},
        {name = "item_manta", desired = 1},
        {name = "item_boots", desired = 1}
    },
    
    {
        {name = "item_branches", desired = 1},
        {name = "item_wraith_band", desired = 2},
        {name = "item_lifesteal", desired = 1},
        {name = "item_maelstrom", desired = 1},
        {name = "item_manta", desired = 1},
        {name = "item_travel_boots", desired = 1}
    }
}

-- Инициализация покупок для бота
-- @param bot - ссылка на бота
function InitializePurchases(bot)
    if not bot then return end
    
    local success = ItemPurchaseCollectionManager.RegisterBot(bot, SNIPER_COLLECTIONS)
end

-- Получает статус покупок (для отладки)
-- @return строку с информацией о статусе
function GetPurchaseStatus()
    local npcBot = GetBot()
    if not npcBot then return "Бот не найден" end
    
    return ItemPurchaseCollectionManager.GetStatus(npcBot)
end

local lastCheck = -999
local CHECK_RATE = 1

-- Функция Think для покупок
function ItemPurchaseThink()
    local npcBot = GetBot()
    
    if DotaTime() < lastCheck + CHECK_RATE then
        return
    end
    lastCheck = DotaTime()
    
    if not npcBot or not npcBot:IsAlive() then
        return
    end
    
    if not botInitialized then
        InitializePurchases(npcBot)
        botInitialized = true
    end
    
    ItemPurchaseCollectionManager.Update(npcBot)
end