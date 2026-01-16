-- item_purchase_core.lua
-- Низкоуровневый модуль для работы с предметами, инвентарем и курьером.
-- Не содержит логики приоритетов, только базовые операции.
local SimpleActions = require(GetScriptDirectory().."/AdditionalFunctions/SimpleActions")
local Constants= require(GetScriptDirectory().."/AdditionalFunctions/Constants")

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

-------------------------------------------------------------------------------
-- Получает курьера команды
-- @param hBot - Handle бота
-- @return Handle курьера или nil
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Проверяет, занят ли курьер
-- @param hBot - Handle бота
-- @return true, если курьер занят
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Отправляет курьера за доставкой предметов
-- @param hBot - Handle бота
-- @return true, если команда отправлена
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Проверяет, есть ли предмет у героя (включая сташ и рюкзак)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @return true, если предмет найден
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Получает общее количество предмета (с учетом зарядов)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @return Количество предметов
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Получает количество предметов по слотам (без учета зарядов)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @return Количество слотов с предметом
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Покупает несколько предметов сразу (для расходников)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @param count - Количество для покупки
-- @return Количество фактически купленных предметов
-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
-- Покупает составной предмет (с использованием системной логики)
-- @param hBot - Handle бота
-- @param itemName - Имя предмета
-- @return true, если покупка начата успешно
-------------------------------------------------------------------------------
function PurchaseCore.PurchaseComplexItem(hBot, itemName)
    if not hBot or not itemName then return false end
    
    local itemCost = GetItemCost(itemName) or 0
    if itemCost <= 0 then return false end
    
    -- Проверяем, достаточно ли золота
    if hBot:GetGold() < itemCost then
        return false
    end
    
    -- Пытаемся купить через системную функцию
    local result = hBot:ActionImmediate_PurchaseItem(itemName)

    if  result ~= PURCHASE_ITEM_SUCCESS then
        SimpleActions.SayAction(hBot, "У меня хватает денег на "..itemName..", результат: "..Constants.purchaseStatus[result])
    end

    return result == PURCHASE_ITEM_SUCCESS
end

-------------------------------------------------------------------------------
-- Проверяет наличие и готовность телепорта
-- @param hBot - Handle бота
-- @return true, если телепорт есть и готов
-------------------------------------------------------------------------------
function PurchaseCore.HasTeleportReady(hBot)
    if not hBot then return false end
    
    -- Проверяем специальный слот для телепорта (15)
    local teleportItem = hBot:GetItemInSlot(15)
    if not teleportItem then return false end
    
    return teleportItem:IsFullyCastable()
end

-------------------------------------------------------------------------------
-- Пытается купить телепорты
-- @param hBot - Handle бота
-- @return Количество купленных телепортов
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Получает информацию о предметах в инвентаре
-- @param hBot - Handle бота
-- @return Таблица с информацией о предметах
-------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------
-- Проверяет, находится ли бот в фонтане
-- @param hBot - Handle бота
-- @return true, если бот в фонтане
-------------------------------------------------------------------------------
function PurchaseCore.IsAtFountain(hBot)
    if not hBot then return false end
    
    local team = hBot:GetTeam()
    local ancient = GetAncient(team)
    if not ancient then return false end
    
    local distance = GetUnitToUnitDistance(hBot, ancient)
    return distance < 1500
end

-------------------------------------------------------------------------------
-- Проверяет, находится ли бот рядом с боковой лавкой
-- @param hBot - Handle бота
-- @return true, если бот рядом с боковой лавкой
-------------------------------------------------------------------------------
function PurchaseCore.IsNearSideShop(hBot)
    if not hBot then return false end
    
    local distance = hBot:DistanceFromSideShop()
    return distance < 500
end

-------------------------------------------------------------------------------
-- Проверяет, находится ли бот рядом с секретной лавкой
-- @param hBot - Handle бота
-- @return true, если бот рядом с секретной лавкой
-------------------------------------------------------------------------------
function PurchaseCore.IsNearSecretShop(hBot)
    if not hBot then return false end
    
    local distance = hBot:DistanceFromSecretShop()
    return distance < 500
end

return PurchaseCore