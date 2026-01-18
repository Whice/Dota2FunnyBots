-- item_purchase_core.lua
-- Низкоуровневый модуль для работы с предметами, инвентарем и курьером.
-- Не содержит логики приоритетов, только базовые операции.
local SimpleActions = require(GetScriptDirectory().."/AdditionalFunctions/SimpleActions")
local Constants = require(GetScriptDirectory().."/AdditionalFunctions/Constants")
local ItemRecipes = require(GetScriptDirectory().."/ItemPurchase/item_recipes")

local PurchaseCore = {}

-- Константы для состояний курьера
PurchaseCore.COURIER_STATE = {
    IDLE = 0,
    AT_BASE = 1,
    MOVING = 2,
    DELIVERING_ITEMS = 3,
    RETURNING_TO_BASE = 4,
    DEAD = 5
}

-- Константы для действий курьера
PurchaseCore.COURIER_ACTION = {
    BURST = 0,
    ENEMY_SECRET_SHOP = 1,
    RETURN = 2,
    SECRET_SHOP = 3,
    SIDE_SHOP = 4,
    SIDE_SHOP2 = 5,
    TAKE_STASH_ITEMS = 6,
    TAKE_AND_TRANSFER_ITEMS = 7,
    TRANSFER_ITEMS = 8
}

--Между покупкой любого предмета обязательно должна быть задержка для обработок
PurchaseCore.lastPurchaseTime = -999
--Задержка в 1 секунду
PurchaseCore.PURCHASE_RATE=1

-- Получает курьера команды
-- @param hBot - Handle бота
-- @return Handle курьера или nil
function PurchaseCore.GetTeamCourier(hBot)
    local team = hBot:GetTeam()
    local numCouriers = GetNumCouriers()
    
    for i = 0, numCouriers - 1 do
        local courier = GetCourier(i)
        if courier and courier:GetTeam() == team then
            return courier
        end
    end
    
    return nil
end

-- Проверяет, занят ли курьер
-- @param hBot - Handle бота
-- @return true, если курьер занят
function PurchaseCore.IsCourierBusy(hBot)
    if IsCourierAvailable() then
        local courierState = GetCourierState()

        -- Курьер считается свободным только в определенных состояниях
        if courierState == PurchaseCore.COURIER_STATE.IDLE or
            courierState == PurchaseCore.COURIER_STATE.AT_BASE then
            return false
        end

        return true
    end
    
    return false
end

-- Отправляет курьера за доставкой предметов
-- @param hBot - Handle бота
-- @return true, если команда отправлена
function PurchaseCore.SendCourierForDelivery(hBot)
    local courier = PurchaseCore.GetTeamCourier(hBot)
    if not courier then return false end
    
    local courierState = GetCourierState()
    
    -- Отправляем курьера только если он в базе или простаивает
    if courierState == PurchaseCore.COURIER_STATE.IDLE or 
       courierState == PurchaseCore.COURIER_STATE.AT_BASE then
        
        hBot:ActionImmediate_Courier(courier, PurchaseCore.COURIER_ACTION.TAKE_AND_TRANSFER_ITEMS)
        return true
    end
    
    return false
end

-- Проверяет, есть ли предмет у героя (включая сташ и рюкзак)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @return true, если предмет найден
function PurchaseCore.HasItem(hBot, itemName)
    if not hBot or not itemName then return false end
    
    -- Проверяем все слоты (0-14: инвентарь, рюкзак, сташ)
    for i = 0, 14 do
        local item = hBot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            return true
        end
    end
    
    return false
end

-- Получает общее количество предмета (с учетом зарядов)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @return Количество предметов
function PurchaseCore.GetItemTotalCount(hBot, itemName)
    if not hBot or not itemName then return 0 end
    
    local totalCount = 0
    
    -- Проверяем все слоты
    for i = 0, 14 do
        local item = hBot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            local charges = item:GetCurrentCharges()
            if charges > 0 then
                totalCount = totalCount + charges
            else
                totalCount = totalCount + 1
            end
        end
    end
    
    return totalCount
end

-- Получает количество предметов по слотам (без учета зарядов)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @return Количество слотов с предметом
function PurchaseCore.GetItemSlotCount(hBot, itemName)
    if not hBot or not itemName then return 0 end
    
    local count = 0
    
    for i = 0, 14 do
        local item = hBot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            count = count + 1
        end
    end
    
    return count
end

-- Покупает несколько предметов сразу (для расходников)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @param count - Количество для покупки
-- @return Количество фактически купленных предметов
function PurchaseCore.BuyItemStack(hBot, itemName, count)
    if not hBot or not itemName or count <= 0 then return 0 end
    
    local itemCost = GetItemCost(itemName) or 0
    if itemCost <= 0 then return 0 end
    
    local currentGold = hBot:GetGold()
    local canBuy = math.min(count, math.floor(currentGold / itemCost))
    local boughtCount = 0
    
    for i = 1, canBuy do
        local result = hBot:ActionImmediate_PurchaseItem(itemName)
        if result == PURCHASE_ITEM_SUCCESS then
            boughtCount = boughtCount + 1
            currentGold = currentGold - itemCost
        else
            break
        end
    end
    
    return boughtCount
end

-- Проверяет, есть ли все компоненты для составного предмета
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @return true если все компоненты есть
function PurchaseCore.HasAllComponents(hBot, itemName)
    local recipe = ItemRecipes[itemName]
    
    -- Если предмет не имеет рецепта или рецепт пустой
    if not recipe or #recipe == 0 then
        return true
    end
    
    -- Проверяем все компоненты рецепта
    for _, componentName in ipairs(recipe) do
        if not PurchaseCore.HasItem(hBot, componentName) then
            return false
        end
    end
    
    return true
end

-- Рекурсивная функция для покупки составных предметов
-- @param hBot - Handle бота
-- @param itemName - Имя предмета для покупки
-- @param processedItems - Таблица уже обработанных предметов (для избежания циклов)
-- @return true если все компоненты куплены или уже есть, false в противном случае
function PurchaseCore.PurchaseItemRecursive(hBot, itemName, processedItems)
    processedItems = processedItems or {}

    if PurchaseCore.lastPurchaseTime + PurchaseCore.PURCHASE_RATE > DotaTime() then
        return false
    end

    -- Защита от бесконечной рекурсии
    if processedItems[itemName] then
        return true  -- Уже обрабатывали этот предмет в текущей цепочке
    end
    processedItems[itemName] = true
    
    SimpleActions.SayAction(hBot, "Покупаю " .. itemName)
        
    local recipe = ItemRecipes[itemName]
    
    -- Если предмет простой (без рецепта) или рецепт пустой
    if not recipe or #recipe == 0 then
        SimpleActions.SayAction(hBot, "Это простой предмет: " .. itemName)
        -- Для простых предметов просто пытаемся купить
        local itemCost = GetItemCost(itemName) or 0
        if itemCost > 0 then
            local currentGold = hBot:GetGold()
            if currentGold >= itemCost then
                local result = hBot:ActionImmediate_PurchaseItem(itemName)
                
                if result ~= PURCHASE_ITEM_SUCCESS then
                    SimpleActions.SayAction(hBot,
                        "У меня хватает денег на " .. itemName .. ", результат: " .. Constants.purchaseStatus[result])
                end

                if result == PURCHASE_ITEM_SUCCESS then
                    PurchaseCore.lastPurchaseTime = DotaTime()
                end
    
                return result == PURCHASE_ITEM_SUCCESS
            else
                SimpleActions.SayAction(hBot, "Не хватает денег на " .. itemName .. ": " .. currentGold .. " < " .. itemCost)
                return false  -- Не хватает денег
            end
        else
            SimpleActions.SayAction(hBot, "Предмет не найден или не имеет стоимости: " .. itemName)
            return false  -- Предмет не найден или не имеет стоимости
        end
    end
    
    -- Если предмет составной, проверяем/покупаем все компоненты
    SimpleActions.SayAction(hBot, "Это составной предмет: " .. itemName .. ", рецепт: " .. #recipe .. " компонентов")
    
    local allComponentsPurchased = true
    
    for _, componentName in ipairs(recipe) do
        -- Рекурсивно покупаем компонент
        SimpleActions.SayAction(hBot, "Проверяю компонент: " .. componentName)
        local hasItem = PurchaseCore.HasItem(hBot, componentName)
        if hasItem then
            SimpleActions.SayAction(hBot, "Компонент: " .. componentName .. " уже есть.")
        else
            local componentPurchased = PurchaseCore.PurchaseItemRecursive(hBot, componentName, processedItems)
            
            if not componentPurchased then
                SimpleActions.SayAction(hBot, "Не удалось купить компонент: " .. componentName)
                allComponentsPurchased = false
                break
            else
                SimpleActions.SayAction(hBot, "Компонент куплен/есть: " .. componentName)
            end
        end
    end
    
    -- Для составных предметов НЕ пытаемся купить сам предмет
    -- Вместо этого проверяем, все ли компоненты есть
    if allComponentsPurchased then
        SimpleActions.SayAction(hBot, "Все компоненты для " .. itemName .. " куплены, можно собрать")
        return true
    else
        SimpleActions.SayAction(hBot, "Не все компоненты для " .. itemName .. " куплены")
        return false
    end
end

-- Основная функция для покупки составных предметов (публичный интерфейс)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @return true если покупка начата успешно (или предмет уже есть/компоненты куплены)
function PurchaseCore.PurchaseComplexItem(hBot, itemName)
    if not hBot or not itemName then 
        return false 
    end
    
    SimpleActions.SayAction(hBot, "Покупаю " .. itemName)
    
    -- Запускаем рекурсивную покупку
    local success = PurchaseCore.PurchaseItemRecursive(hBot, itemName)
    
    if success then
        SimpleActions.SayAction(hBot, "Успешно купил/имею компоненты для " .. itemName)
    else
        SimpleActions.SayAction(hBot, "Не удалось купить " .. itemName)
    end
    
    return success
end

-- Функция для покупки нескольких экземпляров предмета
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @param count - Количество предметов для покупки
-- @return true если куплен хотя бы один предмет
function PurchaseCore.PurchaseComplexItemWithCount(hBot, itemName, count)
    if not hBot or not itemName or count <= 0 then 
        return false 
    end
    
    -- Проверяем, сколько уже есть
    local currentCount = PurchaseCore.GetItemTotalCount(hBot, itemName)
    if currentCount >= count then
        SimpleActions.SayAction(hBot, 
            string.format("Уже есть %d %s, не нужно покупать", currentCount, itemName))
        return true
    end
    
    -- Сколько нужно купить дополнительно
    local needed = count - currentCount
    
    SimpleActions.SayAction(hBot, 
        string.format("Пытаюсь купить %d %s (уже есть %d)", needed, itemName, currentCount))
    
    -- Покупаем по одному, пока не достигнем нужного количества
    local boughtCount = 0
    for i = 1, needed do
        local success = PurchaseCore.PurchaseComplexItem(hBot, itemName)
        if success then
            boughtCount = boughtCount + 1
            -- После покупки проверяем, сколько стало
            local newCount = PurchaseCore.GetItemTotalCount(hBot, itemName)
            SimpleActions.SayAction(hBot, 
                string.format("Куплен %d-й %s. Теперь есть %d", i, itemName, newCount))
        else
            SimpleActions.SayAction(hBot, 
                string.format("Не удалось купить %d-й %s", i, itemName))
            break
        end
    end
    
    return boughtCount > 0
end

-- Проверяет наличие и готовность телепорта
-- @param hBot - Handle бота
-- @return true, если телепорт есть и готов
function PurchaseCore.HasTeleportReady(hBot)
    if not hBot then return false end
    
    -- Проверяем специальный слот для телепорта (15)
    local teleportItem = hBot:GetItemInSlot(15)
    if not teleportItem then return false end
    
    return teleportItem:IsFullyCastable()
end

-- Пытается купить телепорты
-- @param hBot - Handle бота
-- @return Количество купленных телепортов
function PurchaseCore.TryBuyTeleports(hBot)
    if not hBot then return 0 end
    
    local itemName = "item_tpscroll"
    local itemCost = GetItemCost(itemName) or 0
    if itemCost <= 0 then return 0 end
    
    -- Получаем текущее количество телепортов
    local currentCount = PurchaseCore.GetItemTotalCount(hBot, itemName)
    local maxCount = 2
    local needed = maxCount - currentCount
    
    if needed <= 0 then return 0 end
    
    local currentGold = hBot:GetGold()
    local canBuy = math.min(needed, math.floor(currentGold / itemCost))
    local boughtCount = 0
    
    for i = 1, canBuy do
        local result = hBot:ActionImmediate_PurchaseItem(itemName)
        if result == PURCHASE_ITEM_SUCCESS then
            boughtCount = boughtCount + 1
        else
            break
        end
    end
    
    return boughtCount
end

-- Получает информацию о предметах в инвентаре
-- @param hBot - Handle бота
-- @return Таблица с информацией о предметах
function PurchaseCore.GetInventoryInfo(hBot)
    if not hBot then return {} end
    
    local inventory = {}
    
    for i = 0, 14 do
        local item = hBot:GetItemInSlot(i)
        if item then
            table.insert(inventory, {
                slot = i,
                name = item:GetName(),
                charges = item:GetCurrentCharges(),
                cost = GetItemCost(item:GetName()) or 0
            })
        end
    end
    
    return inventory
end

-- Проверяет, находится ли бот в фонтане
-- @param hBot - Handle бота
-- @return true, если бот в фонтане
function PurchaseCore.IsAtFountain(hBot)
    if not hBot then return false end
    
    local team = hBot:GetTeam()
    local ancient = GetAncient(team)
    if not ancient then return false end
    
    local distance = GetUnitToUnitDistance(hBot, ancient)
    return distance < 1500
end

-- Проверяет, находится ли бот рядом с боковой лавкой
-- @param hBot - Handle бота
-- @return true, если бот рядом с боковой лавкой
function PurchaseCore.IsNearSideShop(hBot)
    if not hBot then return false end
    
    local distance = hBot:DistanceFromSideShop()
    return distance < 500
end

-- Проверяет, находится ли бот рядом с секретной лавкой
-- @param hBot - Handle бота
-- @return true, если бот рядом с секретной лавкой
function PurchaseCore.IsNearSecretShop(hBot)
    if not hBot then return false end
    
    local distance = hBot:DistanceFromSecretShop()
    return distance < 500
end

return PurchaseCore