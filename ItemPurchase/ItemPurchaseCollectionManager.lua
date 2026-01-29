-- ItemPurchase/ItemPurchaseCollectionManager.lua
-- Модуль для управления коллекциями предметов с инкрементальным накоплением

local ItemPurchaseCollectionManager = {}

local ItemPurchaseManager = require(GetScriptDirectory().."/ItemPurchase/ItemPurchaseManager")

ItemPurchaseCollectionManager.botCollections = {}
ItemPurchaseCollectionManager.CHECK_INTERVAL = 1.0
ItemPurchaseCollectionManager.lastCheckTime = {}

-- Регистрирует коллекции предметов для бота
-- @param bot - ссылка на бота
-- @param collections - таблица коллекций
function ItemPurchaseCollectionManager.RegisterBot(bot, collections)
    if not bot or not collections then
        return false
    end
    
    local playerID = bot:GetPlayerID()
    
    ItemPurchaseCollectionManager.botCollections[playerID] = {
        collections = collections,
        currentCollectionIndex = 1,
        state = "active",
        lastProcessedTime = -999
    }
    
    return true
end

-- Получает данные бота
-- @param bot - ссылка на бота
-- @return таблица с данными бота или nil
function ItemPurchaseCollectionManager.GetBotData(bot)
    if not bot then return nil end
    return ItemPurchaseCollectionManager.botCollections[bot:GetPlayerID()]
end

-- Проверяет, завершена ли текущая коллекция
-- @param bot - ссылка на бота
-- @param collection - таблица коллекции
-- @return true, если коллекция завершена
function ItemPurchaseCollectionManager.IsCollectionComplete(bot, collection)
    if not bot or not collection then return false end
    
    for _, itemData in ipairs(collection) do
        local itemName = itemData.name
        local desiredCount = itemData.desired or 1
        
        local currentCount = ItemPurchaseCollectionManager.GetItemCount(bot, itemName)
        
        if currentCount < desiredCount then
            return false
        end
    end
    
    return true
end

-- Получает общее количество предмета у бота
-- @param bot - ссылка на бота
-- @param itemName - название предмета
-- @return количество предметов (готовые + компоненты)
function ItemPurchaseCollectionManager.GetItemCount(bot, itemName)
    if not bot or not itemName then return 0 end
    
    local totalCount = 0
    
    for slot = 0, 8 do
        local item = bot:GetItemInSlot(slot)
        if item and item:GetName() == itemName then
            totalCount = totalCount + 1
        end
    end
    
    for slot = 9, 14 do
        local item = bot:GetItemInSlot(slot)
        if item and item:GetName() == itemName then
            totalCount = totalCount + 1
        end
    end
    
    return totalCount
end

-- Обновляет список предметов для покупки в ItemPurchaseManager
-- @param bot - ссылка на бота
-- @param collection - текущая коллекция
function ItemPurchaseCollectionManager.UpdatePurchaseList(bot, collection)
    if not bot or not collection then return end
    
    local consumables = {}
    local itemsTable = {}
    
    for _, itemData in ipairs(collection) do
        local itemName = itemData.name
        local desiredCount = itemData.desired or 1
        
        local currentCount = ItemPurchaseCollectionManager.GetItemCount(bot, itemName)
        
        if currentCount < desiredCount then
            table.insert(itemsTable, {
                name = itemName,
                desired = desiredCount,
                purchased = currentCount,
                priority = 100 - #itemsTable
            })
        end
    end
    
    ItemPurchaseManager.SetConsumables(bot, consumables)
    ItemPurchaseManager.SetItems(bot, itemsTable)
end

-- Основная функция обновления
-- @param bot - ссылка на бота
function ItemPurchaseCollectionManager.Update(bot)
    if not bot or not bot:IsAlive() then return end
    
    local playerID = bot:GetPlayerID()
    local currentTime = DotaTime()
    
    if ItemPurchaseCollectionManager.lastCheckTime[playerID] and 
       currentTime < ItemPurchaseCollectionManager.lastCheckTime[playerID] + ItemPurchaseCollectionManager.CHECK_INTERVAL then
        return
    end
    
    ItemPurchaseCollectionManager.lastCheckTime[playerID] = currentTime
    
    local botData = ItemPurchaseCollectionManager.GetBotData(bot)
    if not botData then
        return
    end
    
    if botData.state == "completed" then
        return
    end
    
    local currentCollection = botData.collections[botData.currentCollectionIndex]
    
    if ItemPurchaseCollectionManager.IsCollectionComplete(bot, currentCollection) then
        botData.currentCollectionIndex = botData.currentCollectionIndex + 1
        
        if botData.currentCollectionIndex > #botData.collections then
            botData.state = "completed"
            return
        end
        
        currentCollection = botData.collections[botData.currentCollectionIndex]
    end
    
    ItemPurchaseCollectionManager.UpdatePurchaseList(bot, currentCollection)
    ItemPurchaseManager.ProcessPurchases(bot)
end

-- Получает статус для отладки
-- @param bot - ссылка на бота
-- @return строку с информацией о статусе
function ItemPurchaseCollectionManager.GetStatus(bot)
    local botData = ItemPurchaseCollectionManager.GetBotData(bot)
    if not botData then return "Бот не зарегистрирован" end
    
    local status = string.format("Статус коллекций:\n")
    status = status .. string.format("Текущая коллекция: %d/%d\n", 
              botData.currentCollectionIndex, #botData.collections)
    status = status .. string.format("Состояние: %s\n", botData.state)
    
    if botData.currentCollectionIndex <= #botData.collections then
        local currentCollection = botData.collections[botData.currentCollectionIndex]
        status = status .. "Текущие цели:\n"
        
        for _, itemData in ipairs(currentCollection) do
            local currentCount = ItemPurchaseCollectionManager.GetItemCount(bot, itemData.name)
            status = status .. string.format("  %s: %d/%d\n", 
                      itemData.name, currentCount, itemData.desired or 1)
        end
    end
    
    return status
end

-- Очищает данные для бота
-- @param bot - ссылка на бота
function ItemPurchaseCollectionManager.ClearBotData(bot)
    if not bot then return end
    ItemPurchaseCollectionManager.botCollections[bot:GetPlayerID()] = nil
end

-- Очищает все данные
function ItemPurchaseCollectionManager.ClearAllData()
    ItemPurchaseCollectionManager.botCollections = {}
    ItemPurchaseCollectionManager.lastCheckTime = {}
end

return ItemPurchaseCollectionManager