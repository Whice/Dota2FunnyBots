-- ItemPurchaseManager.lua
-- Модуль для управления приоритетами и порядком покупок предметов.
-- Использует методы из item_purchase_core для низкоуровневых операций.

-- Пример запроса на покупку, не удалять!
-- local itemsTable = ItemPurchaseManager.CreateItemsTable({
--     {
--         name = "item_wraith_band",
--         desired = 2,     -- Нужно 2 экземпляра
--         purchased = 0,   -- Пока куплено 0
--         priority = 90
--     },
--     {
--         name = "item_maelstrom",
--         desired = 1,     -- Нужно 1 экземпляр
--         purchased = 0,   -- Пока куплено 0
--         priority = 80
--     }
-- })

local ItemPurchaseManager = {}

-- Импортируем низкоуровневый модуль для работы с предметами
local PurchaseCore = require(GetScriptDirectory().."/ItemPurchase/item_purchase_core")
local SimpleActions = require(GetScriptDirectory().."/AdditionalFunctions/SimpleActions")

-- Хранилище данных о покупках для каждого бота
ItemPurchaseManager.botData = {}

-- Константы для состояний
ItemPurchaseManager.PURCHASE_STATUS = {
    NOT_STARTED = "not_started",
    IN_PROGRESS = "in_progress",
    COMPLETED = "completed",
    FAILED = "failed"
}

-- Получает или создает таблицу данных для бота
-- @param hBot - Handle бота
-- @return Таблица данных бота
function ItemPurchaseManager.GetBotTable(hBot)
    if not hBot then return nil end
    
    local playerID = hBot:GetPlayerID()
    if not ItemPurchaseManager.botData[playerID] then
        ItemPurchaseManager.botData[playerID] = {
            consumables = {},    -- Таблица расходников
            items = {},          -- Список предметов
            lastProcessTime = 0, -- Время последней обработки
            processingDelay = 1.0, -- Задержка между обработками
            state = "idle"       -- Состояние менеджера
        }
    end
    
    return ItemPurchaseManager.botData[playerID]
end

-- Получает таблицу покупок для бота (публичный интерфейс)
-- @param hBot - Handle бота
-- @return Таблица данных бота
function ItemPurchaseManager.GetPurchaseTable(hBot)
    return ItemPurchaseManager.GetBotTable(hBot)
end

-- Обновляет список желаемых расходников
-- @param hBot - Handle бота
-- @param consumablesTable - Таблица расходников
function ItemPurchaseManager.SetConsumables(hBot, consumablesTable)
    local data = ItemPurchaseManager.GetBotTable(hBot)
    if not data then return end
    
    data.consumables = consumablesTable
end

-- Обновляет список желаемых предметов
-- @param hBot - Handle бота
-- @param itemsTable - Таблица предметов
function ItemPurchaseManager.SetItems(hBot, itemsTable)
    local data = ItemPurchaseManager.GetBotTable(hBot)
    if not data then return end
    
    data.items = itemsTable
end

-- Сортирует расходники по приоритету (от высокого к низкому)
-- @param consumablesTable - Таблица расходников
-- @return Отсортированный список расходников
function ItemPurchaseManager.SortConsumablesByPriority(consumablesTable)
    local consumableList = {}
    
    for itemName, itemData in pairs(consumablesTable) do
        table.insert(consumableList, {
            name = itemName,
            data = itemData
        })
    end
    
    table.sort(consumableList, function(a, b)
        local priorityA = a.data.priority or 1.0
        local priorityB = b.data.priority or 1.0
        return priorityA > priorityB
    end)
    
    return consumableList
end

-- Сортирует предметы по приоритету (от высокого к низкому)
-- @param itemsTable - Таблица предметов
-- @return Отсортированный список предметов
function ItemPurchaseManager.SortItemsByPriority(itemsTable)
    local sortedItems = {}
    
    for _, itemData in ipairs(itemsTable) do
        table.insert(sortedItems, itemData)
    end
    
    table.sort(sortedItems, function(a, b)
        local priorityA = a.priority or 1.0
        local priorityB = b.priority or 1.0
        
        -- Если приоритеты равны, сортируем по количеству, которое нужно докупить
        if priorityA == priorityB then
            local aNeeded = (a.desired or 1) - (a.purchased or 0)
            local bNeeded = (b.desired or 1) - (b.purchased or 0)
            return aNeeded > bNeeded
        end
        
        return priorityA > priorityB
    end)
    
    return sortedItems
end

-- Обрабатывает покупку расходников
-- @param hBot - Handle бота
-- @return true, если была совершена хотя бы одна покупка
function ItemPurchaseManager.ProcessConsumables(hBot)
    local data = ItemPurchaseManager.GetBotTable(hBot)
    if not data then return false end
    
    local consumableList = ItemPurchaseManager.SortConsumablesByPriority(data.consumables)
    local anyPurchased = false
    
    for _, consumable in ipairs(consumableList) do
        local itemName = consumable.name
        local itemData = consumable.data
        local desiredCount = itemData.desired or 1
        
        -- Получаем текущее количество предмета
        local currentCount = PurchaseCore.GetItemTotalCount(hBot, itemName)
        
        -- Проверяем, нужно ли покупать больше
        if currentCount < desiredCount then
            local needToBuy = desiredCount - currentCount
            
            -- Покупаем через PurchaseCore
            local boughtCount = PurchaseCore.BuyItemStack(hBot, itemName, needToBuy)
            
            if boughtCount > 0 then
                anyPurchased = true
                itemData.purchased = (itemData.purchased or 0) + boughtCount
            end
        end
    end
    
    return anyPurchased
end

-- Обрабатывает покупку самого приоритетного предмета
-- @param hBot - Handle бота
-- @return true, если была совершена покупка
function ItemPurchaseManager.ProcessPriorityItem(hBot)
    local data = ItemPurchaseManager.GetBotTable(hBot)
    if not data or #data.items == 0 then return false end
    
    local sortedItems = ItemPurchaseManager.SortItemsByPriority(data.items)
    
    for _, itemData in ipairs(sortedItems) do
        local itemName = itemData.name
        local desiredCount = itemData.desired or 1
        
        -- Получаем текущее количество предмета у героя
        local currentCount = PurchaseCore.GetItemTotalCount(hBot, itemName)
        
        -- Вычисляем, сколько еще нужно купить
        local neededCount = desiredCount - currentCount
        
        if neededCount > 0 then
            -- Нужно купить недостающее количество
            SimpleActions.SayAction(hBot, 
                string.format("Нужно купить %d %s (есть %d, нужно %d)", 
                    neededCount, itemName, currentCount, desiredCount))
            
            -- Покупаем недостающее количество по одному
            local boughtAny = false
            for i = 1, neededCount do
                local success = PurchaseCore.PurchaseComplexItem(hBot, itemName)
                
                if success then
                    -- Обновляем количество купленных предметов
                    local newCount = PurchaseCore.GetItemTotalCount(hBot, itemName)
                    itemData.purchased = newCount
                    
                    SimpleActions.SayAction(hBot, 
                        string.format("Куплен %d-й %s. Теперь есть %d", i, itemName, newCount))
                    boughtAny = true
                    
                    -- Если купили хотя бы один, возвращаем успех
                    if i == 1 then
                        return true
                    end
                else
                    SimpleActions.SayAction(hBot, 
                        string.format("Не удалось купить %d-й %s", i, itemName))
                    break
                end
            end
            
            return boughtAny
        else
            -- Уже есть нужное количество
            itemData.purchased = currentCount
        end
    end
    
    return false
end

-- Основная функция обработки покупок
-- @param hBot - Handle бота
function ItemPurchaseManager.ProcessPurchases(hBot)
    if not hBot or not hBot:IsAlive() then return end
    
    local data = ItemPurchaseManager.GetBotTable(hBot)
    if not data then return end
    
    -- Проверяем задержку между обработками
    local currentTime = DotaTime()
    if currentTime < data.lastProcessTime + data.processingDelay then
        return
    end
    
    data.lastProcessTime = currentTime
    
    -- 1. Обрабатываем расходники
    local consumablesPurchased = ItemPurchaseManager.ProcessConsumables(hBot)
    
    -- 2. Если не купили расходников, пробуем купить приоритетный предмет
    if not consumablesPurchased then
        ItemPurchaseManager.ProcessPriorityItem(hBot)
    end
end

-- Создает таблицу расходников из простого формата
-- @param simpleTable - Простая таблица формата {["item_name"] = desiredCount}
-- @return Структурированная таблица расходников
function ItemPurchaseManager.CreateConsumablesTable(simpleTable)
    local result = {}
    
    for itemName, value in pairs(simpleTable) do
        if type(value) == "table" then
            result[itemName] = {
                desired = value.desired or value,
                priority = value.priority or 1.0,
                purchased = value.purchased or 0
            }
        else
            result[itemName] = {
                desired = value,
                priority = 1.0,
                purchased = 0
            }
        end
    end
    
    return result
end

-- Создает таблицу предметов из простого формата
-- @param simpleList - Список предметов в формате {name, desired, purchased, priority}
-- @return Структурированная таблица предметов
function ItemPurchaseManager.CreateItemsTable(simpleList)
    local result = {}
    
    for _, item in ipairs(simpleList) do
        if type(item) == "string" then
            -- Если передана строка, создаем предмет с количеством 1
            table.insert(result, {
                name = item,
                desired = 1,
                purchased = 0,
                priority = 1.0
            })
        else
            -- Только новый формат с числовыми значениями
            table.insert(result, {
                name = item.name,
                desired = item.desired or 1,
                purchased = item.purchased or 0,
                priority = item.priority or 1.0
            })
        end
    end
    
    return result
end

-- Получает статус покупок для бота
-- @param hBot - Handle бота
-- @return Таблица статуса
function ItemPurchaseManager.GetPurchaseStatus(hBot)
    local data = ItemPurchaseManager.GetBotTable(hBot)
    if not data then return nil end
    
    return {
        lastProcessTime = data.lastProcessTime,
        consumablesCount = 0, -- Можно добавить подсчет
        itemsCount = #data.items,
        state = data.state
    }
end

-- Очищает данные для бота
-- @param hBot - Handle бота
function ItemPurchaseManager.ClearBotData(hBot)
    if not hBot then return end
    
    local playerID = hBot:GetPlayerID()
    ItemPurchaseManager.botData[playerID] = nil
end

-- Очищает все данные
function ItemPurchaseManager.ClearAllData()
    ItemPurchaseManager.botData = {}
end

return ItemPurchaseManager