-- Файл: ItemPurchaseManager.lua
-- Модуль для управления покупками предметов и расходников

local ItemPurchaseManager = {}

-- Импортируем PurchaseCore для покупки составных предметов
local PurchaseCore = require(GetScriptDirectory().."/ItemPurchase/item_purchase_core")

-- Хранилище данных для каждого бота
ItemPurchaseManager.botData = {}

-- Константы для состояний курьера
local COURIER_STATE_IDLE = 0
local COURIER_STATE_AT_BASE = 1
local COURIER_STATE_MOVING = 2
local COURIER_STATE_DELIVERING_ITEMS = 3
local COURIER_STATE_RETURNING_TO_BASE = 4
local COURIER_STATE_DEAD = 5

-- Структура данных для каждого бота:
-- {
--   consumables = {
--     ["item_tango"] = {desired = 2, purchased = 0}
--   },
--   items = {
--     {name = "item_wraith_band", priority = 1.0, purchased = false}
--   },
--   purchaseState = "idle", -- "idle", "waiting_for_courier", "processing"
--   lastProcessTime = 0,
--   processingDelay = 1.0,
--   courierBusy = false,
--   highestPriorityItem = nil
-- }

-- Получить или создать таблицу для бота
function ItemPurchaseManager.GetBotTable(bot)
    if not bot then return nil end
    
    local playerID = bot:GetPlayerID()
    if not ItemPurchaseManager.botData[playerID] then
        ItemPurchaseManager.botData[playerID] = {
            consumables = {},
            items = {},
            purchaseState = "idle",
            lastProcessTime = 0,
            processingDelay = 1.0,
            courierBusy = false,
            highestPriorityItem = nil,
            courierCheckTime = 0,
            courierCheckDelay = 2.0
        }
    end
    
    return ItemPurchaseManager.botData[playerID]
end

-- Получить ссылку на таблицу бота (для внешнего заполнения)
function ItemPurchaseManager.GetPurchaseTable(bot)
    return ItemPurchaseManager.GetBotTable(bot)
end

-- Обновить таблицу желаний
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

-- Получить курьера команды
local function GetTeamCourier(bot)
    local team = bot:GetTeam()
    local numCouriers = GetNumCouriers()
    
    for i = 0, numCouriers - 1 do
        local courier = GetCourier(i)
        if courier and courier:GetTeam() == team then
            return courier
        end
    end
    
    return nil
end

-- Проверить состояние курьера
function ItemPurchaseManager.CheckCourierState(bot)
    local data = ItemPurchaseManager.GetBotTable(bot)
    if not data then return false end
    
    local currentTime = DotaTime()
    if currentTime < data.courierCheckTime + data.courierCheckDelay then
        return data.courierBusy
    end
    
    data.courierCheckTime = currentTime
    
    local courier = GetTeamCourier(bot)
    if not courier then
        data.courierBusy = false
        return false
    end
    
    local courierState = courier:GetCourierState()
    
    -- Курьер считается занятым, если он не в базе и не простаивает
    if courierState == COURIER_STATE_IDLE or courierState == COURIER_STATE_AT_BASE then
        data.courierBusy = false
    else
        data.courierBusy = true
    end
    
    return data.courierBusy
end

-- Отправить курьера за предметами
function ItemPurchaseManager.SendCourierForItems(bot)
    local courier = GetTeamCourier(bot)
    if not courier then return false end
    
    local courierState = courier:GetCourierState()
    
    -- Если курьер в базе или простаивает, отправляем его за предметами
    if courierState == COURIER_STATE_IDLE or courierState == COURIER_STATE_AT_BASE then
        -- Команда курьеру взять предметы из кладовой и доставить герою
        bot:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
        
        local data = ItemPurchaseManager.GetBotTable(bot)
        if data then
            data.courierBusy = true
            data.courierCheckTime = DotaTime()
        end
        
        return true
    end
    
    return false
end

-- Найти предмет с наивысшим приоритетом среди расходников
local function FindHighestPriorityConsumable(data)
    local highestPriority = -1
    local selectedItem = nil
    local selectedName = nil
    
    for itemName, itemData in pairs(data.consumables) do
        local priority = itemData.priority or 1.0
        local purchased = itemData.purchased or 0
        local desired = itemData.desired or 1
        
        if purchased < desired and priority > highestPriority then
            highestPriority = priority
            selectedItem = itemData
            selectedName = itemName
        end
    end
    
    return selectedName, selectedItem, highestPriority
end

-- Найти предмет с наивысшим приоритетом среди обычных предметов
local function FindHighestPriorityItem(data)
    local highestPriority = -1
    local selectedItem = nil
    
    for i, itemData in ipairs(data.items) do
        local priority = itemData.priority or 1.0
        local purchased = itemData.purchased or false
        
        if not purchased and priority > highestPriority then
            highestPriority = priority
            selectedItem = itemData
        end
    end
    
    return selectedItem, highestPriority
end

-- Пытаться купить предмет с наивысшим приоритетом
function ItemPurchaseManager.TryBuyHighestPriority(bot)
    local data = ItemPurchaseManager.GetBotTable(bot)
    if not data then return false end
    
    -- Сначала проверяем расходники
    local consumableName, consumableData, consumablePriority = FindHighestPriorityConsumable(data)
    
    -- Потом обычные предметы
    local itemData, itemPriority = FindHighestPriorityItem(data)
    
    local selectedType = nil -- "consumable" или "item"
    local selectedName = nil
    local selectedData = nil
    
    -- Выбираем что покупать: расходник или обычный предмет
    if consumableData and consumablePriority > 0 then
        if itemData and itemPriority > 0 then
            -- Есть и расходники и обычные предметы, выбираем по приоритету
            if consumablePriority >= itemPriority then
                selectedType = "consumable"
                selectedName = consumableName
                selectedData = consumableData
            else
                selectedType = "item"
                selectedName = itemData.name
                selectedData = itemData
            end
        else
            -- Только расходники
            selectedType = "consumable"
            selectedName = consumableName
            selectedData = consumableData
        end
    elseif itemData and itemPriority > 0 then
        -- Только обычные предметы
        selectedType = "item"
        selectedName = itemData.name
        selectedData = itemData
    else
        -- Нет предметов для покупки
        return false
    end
    
    -- Сохраняем выбранный предмет для отслеживания
    data.highestPriorityItem = {
        type = selectedType,
        name = selectedName,
        data = selectedData
    }
    
    -- Пытаемся купить
    local success = false
    
    if selectedType == "consumable" then
        success = ItemPurchaseManager.BuyConsumable(bot, selectedName, selectedData)
    else
        success = PurchaseCore.PurchaseItem(bot, selectedName)
    end
    
    if success then
        -- Если покупка успешна, отмечаем это
        if selectedType == "consumable" then
            selectedData.purchased = (selectedData.purchased or 0) + 1
            -- Если достигли желаемого количества, удаляем из списка
            if selectedData.purchased >= (selectedData.desired or 1) then
                data.consumables[selectedName] = nil
            end
        else
            selectedData.purchased = true
        end
        
        -- После успешной покупки отправляем курьера
        ItemPurchaseManager.SendCourierForItems(bot)
        
        -- Переходим в состояние ожидания курьера
        data.purchaseState = "waiting_for_courier"
        
        return true
    else
        -- Если не удалось купить (не хватило денег), ничего не делаем
        -- и оставляем предмет в списке для следующих попыток
        data.highestPriorityItem = nil
        return false
    end
end

-- Подсчитать текущее количество предмета у бота (включая все слоты: 0-14)
function ItemPurchaseManager.GetItemCount(bot, itemName)
    if not bot or not itemName then return 0 end
    
    local count = 0
    
    -- Проверяем все слоты (0-14: инвентарь, рюкзак, сташ)
    for i = 0, 14 do
        local item = bot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            count = count + 1
        end
    end
    
    return count
end

-- Купить расходник (один раз за вызов)
function ItemPurchaseManager.BuyConsumable(bot, itemName, itemData)
    if not bot or not bot:IsAlive() then return false end
    
    -- Проверяем стоимость
    local itemCost = GetItemCost(itemName) or 0
    local currentGold = bot:GetGold()
    
    -- Если денег достаточно
    if currentGold >= itemCost then
        -- Пытаемся купить
        local result = bot:ActionImmediate_PurchaseItem(itemName)
        
        if result == PURCHASE_ITEM_SUCCESS then
            print(string.format("[Purchase] Successfully bought %s", itemName))
            return true
        else
            -- Если покупка не удалась, выводим сообщение об ошибке
            print(string.format("[Purchase Error] Failed to buy %s. Error code: %d", itemName, result))
            return false
        end
    else
        -- Недостаточно золота
        print(string.format("[Purchase Error] Not enough gold for %s. Need: %d, Have: %d", 
              itemName, itemCost, currentGold))
        return false
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
    
    -- Проверяем состояние курьера
    ItemPurchaseManager.CheckCourierState(bot)
    
    -- В зависимости от состояния процесса покупок
    if data.purchaseState == "idle" then
        -- Если курьер не занят, пытаемся купить
        if not data.courierBusy then
            ItemPurchaseManager.TryBuyHighestPriority(bot)
        end
    elseif data.purchaseState == "waiting_for_courier" then
        -- Ждем, пока курьер вернется на базу
        if not data.courierBusy then
            -- Курьер вернулся, можно продолжать
            data.purchaseState = "idle"
            data.highestPriorityItem = nil
        end
    end
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
            result[itemName] = {
                desired = value.desired or value,
                priority = value.priority or 1.0,
                purchased = 0
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

-- Вспомогательная функция для создания таблицы предметов
function ItemPurchaseManager.CreateItemsTable(items)
    -- items = {"item_wraith_band", "item_boots", "item_maelstrom"}
    -- или items = {{name = "item_wraith_band", priority = 1.0}, ...}
    local result = {}
    
    for _, item in ipairs(items) do
        if type(item) == "string" then
            table.insert(result, {
                name = item, 
                priority = 1.0,
                purchased = false
            })
        else
            item.purchased = item.purchased or false
            table.insert(result, item)
        end
    end
    
    return result
end

-- Функция для ручного удаления предмета из таблицы
function ItemPurchaseManager.RemoveItem(bot, itemName, isConsumable)
    local data = ItemPurchaseManager.GetBotTable(bot)
    if not data then return false end
    
    if isConsumable then
        if data.consumables[itemName] then
            data.consumables[itemName] = nil
            return true
        end
    else
        for i, itemData in ipairs(data.items) do
            if itemData.name == itemName then
                table.remove(data.items, i)
                return true
            end
        end
    end
    
    return false
end

-- Проверить статус покупки для предмета
function ItemPurchaseManager.GetPurchaseStatus(bot, itemName, isConsumable)
    local data = ItemPurchaseManager.GetBotTable(bot)
    if not data then return nil end
    
    if isConsumable then
        if data.consumables[itemName] then
            local itemData = data.consumables[itemName]
            return {
                desired = itemData.desired,
                purchased = itemData.purchased or 0,
                status = "in_progress"
            }
        else
            return {status = "not_in_list"}
        end
    else
        for _, itemData in ipairs(data.items) do
            if itemData.name == itemName then
                return {
                    priority = itemData.priority,
                    purchased = itemData.purchased or false,
                    status = itemData.purchased and "purchased" or "waiting"
                }
            end
        end
        return {status = "not_in_list"}
    end
end

-- Получить состояние процесса покупок
function ItemPurchaseManager.GetPurchaseState(bot)
    local data = ItemPurchaseManager.GetBotTable(bot)
    if not data then return nil end
    
    return {
        state = data.purchaseState,
        courierBusy = data.courierBusy,
        highestPriorityItem = data.highestPriorityItem
    }
end

return ItemPurchaseManager