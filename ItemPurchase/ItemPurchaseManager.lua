-- Файл: ItemPurchaseManager.lua
-- Модуль для управления покупками предметов и расходников

local ItemPurchaseManager = {}

-- Импортируем PurchaseCore для покупки составных предметов
local PurchaseCore = require(GetScriptDirectory().."/ItemPurchase/item_purchase_core")

-- Хранилище данных для каждого бота
ItemPurchaseManager.botData = {}

-- Структура данных для каждого бота:
-- {
--   consumables = {
--     ["item_tango"] = {desired = 2, current = 1},
--     ["item_clarity"] = {desired = 2, current = 0}
--   },
--   items = {
--     {name = "item_wraith_band", priority = 1.0},
--     {name = "item_boots", priority = 0.8},
--     {name = "item_maelstrom", priority = 0.6}
--   },
--   lastProcessTime = 0,
--   processingDelay = 1.0  -- Задержка между обработками покупок
-- }

-- Получить или создать таблицу для бота
function ItemPurchaseManager.GetBotTable(bot)
    if not bot then return nil end
    
    local playerID = bot:GetPlayerID()
    if not ItemPurchaseManager.botData[playerID] then
        ItemPurchaseManager.botData[playerID] = {
            consumables = {},
            items = {},
            lastProcessTime = 0,
            processingDelay = 1.0
        }
    end
    
    return ItemPurchaseManager.botData[playerID]
end

-- Получить ссылку на таблицу бота (для внешнего заполнения)
function ItemPurchaseManager.GetPurchaseTable(bot)
    return ItemPurchaseManager.GetBotTable(bot)
end

-- Обновить таблицу желаний (устаревший метод, лучше напрямую работать с таблицей)
function ItemPurchaseManager.UpdateDesires(bot, consumables, items)
    local data = ItemPurchaseManager.GetBotTable(bot)
    if not data then return end
    
    if consumables then
        data.consumables = consumables
    end
    
    if items then
        data.items = items
    end
end

-- Подсчитать текущее количество расходника у бота (включая инвентарь и рюкзак)
function ItemPurchaseManager.GetCurrentConsumableCount(bot, itemName)
    if not bot or not itemName then return 0 end
    
    local count = 0
    
    -- Проверяем основные слоты инвентаря (0-5) и рюкзака (6-8)
    for i = 0, 8 do
        local item = bot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            -- Для предметов с зарядами учитываем количество зарядов
            if item:GetCurrentCharges() > 0 then
                count = count + item:GetCurrentCharges()
            else
                count = count + 1
            end
        end
    end
    
    return count
end

-- Купить расходник
function ItemPurchaseManager.BuyConsumable(bot, itemName, desiredCount)
    if not bot or not bot:IsAlive() then return false end
    
    -- Проверяем текущее количество
    local currentCount = ItemPurchaseManager.GetCurrentConsumableCount(bot, itemName)
    
    -- Если уже есть нужное количество
    if currentCount >= desiredCount then
        return true
    end
    
    -- Проверяем стоимость
    local itemCost = GetItemCost(itemName) or 0
    local currentGold = bot:GetGold()
    
    -- Если денег достаточно
    if currentGold >= itemCost then
        -- Пытаемся купить
        local result = bot:ActionImmediate_PurchaseItem(itemName)
        
        if result == PURCHASE_ITEM_SUCCESS then
            -- Ждем доставки предмета курьером
            PurchaseCore.ForceDelivery(bot)
            return true
        end
    end
    
    return false
end

-- Обработать расходники
function ItemPurchaseManager.ProcessConsumables(bot)
    local data = ItemPurchaseManager.GetBotTable(bot)
    if not data then return end
    
    -- Сортируем расходники по стоимости (от дешевых к дорогим)
    local consumableList = {}
    for itemName, desiredData in pairs(data.consumables) do
        local cost = GetItemCost(itemName) or 0
        table.insert(consumableList, {
            name = itemName,
            desired = desiredData.desired or desiredData, -- поддержка старого формата
            cost = cost
        })
    end
    
    table.sort(consumableList, function(a, b)
        return a.cost < b.cost
    end)
    
    -- Покупаем расходники по порядку
    for _, consumable in ipairs(consumableList) do
        local desiredCount = consumable.desired
        if type(desiredCount) == "table" then
            desiredCount = desiredCount.desired or 1
        end
        
        if not ItemPurchaseManager.BuyConsumable(bot, consumable.name, desiredCount) then
            -- Если не удалось купить, прерываем цепочку покупок
            break
        end
    end
end

-- Обработать составные предметы
function ItemPurchaseManager.ProcessItems(bot)
    local data = ItemPurchaseManager.GetBotTable(bot)
    if not data or #data.items == 0 then return end
    
    -- Сортируем предметы по приоритету (от высокого к низкому)
    table.sort(data.items, function(a, b)
        return (a.priority or 1) > (b.priority or 1)
    end)
    
    -- Пытаемся купить самый приоритетный предмет
    for _, itemData in ipairs(data.items) do
        local itemName = itemData.name
        
        -- Проверяем, есть ли предмет уже у героя
        if not PurchaseCore.HasItem(bot, itemName) then
            -- Пытаемся купить
            local success = PurchaseCore.PurchaseItem(bot, itemName)
            
            if success then
                -- Если удалось начать покупку, выходим из цикла
                break
            end
            -- Если не удалось купить этот предмет, пробуем следующий
        else
            -- Предмет уже есть, пробуем следующий
        end
    end
end

-- Основная функция обработки покупок для бота
function ItemPurchaseManager.ProcessPurchases(bot)
    if not bot or not bot:IsAlive() then return end
    
    local data = ItemPurchaseManager.GetBotTable(bot)
    if not data then return end
    
    -- Проверяем задержку между обработками
    local currentTime = DotaTime()
    if currentTime < data.lastProcessTime + data.processingDelay then
        return
    end
    
    data.lastProcessTime = currentTime
    
    -- 1. Обработка расходников
    ItemPurchaseManager.ProcessConsumables(bot)
    
    -- 2. Обработка составных предметов
    ItemPurchaseManager.ProcessItems(bot)
end

-- Очистить данные для бота (например, при перезагрузке)
function ItemPurchaseManager.ClearBotData(bot)
    if not bot then return end
    
    local playerID = bot:GetPlayerID()
    ItemPurchaseManager.botData[playerID] = nil
end

-- Очистить все данные
function ItemPurchaseManager.ClearAllData()
    ItemPurchaseManager.botData = {}
end

-- Вспомогательная функция для создания таблицы расходников
function ItemPurchaseManager.CreateConsumablesTable(consumables)
    -- consumables = {["item_tango"] = 2, ["item_clarity"] = 3}
    -- или consumables = {["item_tango"] = {desired = 2, priority = 1.0}, ...}
    local result = {}
    
    for itemName, value in pairs(consumables) do
        if type(value) == "table" then
            result[itemName] = value
        else
            result[itemName] = {desired = value, priority = 1.0}
        end
    end
    
    return result
end

-- Вспомогательная функция для создания таблицы предметов
function ItemPurchaseManager.CreateItemsTable(items)
    -- items = {"item_wraith_band", "item_boots", "item_maelstrom"}
    -- или items = {{name = "item_wraith_band", priority = 1.0}, ...}
    local result = {}
    
    for _, item in ipairs(items) do
        if type(item) == "string" then
            table.insert(result, {name = item, priority = 1.0})
        else
            table.insert(result, item)
        end
    end
    
    return result
end

return ItemPurchaseManager