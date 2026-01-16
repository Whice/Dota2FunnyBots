-- ItemPurchase/item_purchase_core.lua
-- Основной модуль для покупки предметов с поддержкой курьера

local PurchaseCore = {}

-- Загружаем рецепты
local itemRecipes = require(GetScriptDirectory().."/ItemPurchase/item_recipes")

-- Локальные вспомогательные функции -------------------------------------------------

-- Получает курьера команды бота
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

-- Проверяет наличие предмета у героя (инвентарь + рюкзак)
local function HasItemOnHero(bot, itemName)
    for i = 0, 8 do
        local item = bot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            return true, i
        end
    end
    return false, -1
end

-- Проверяет наличие предмета в кладовой
local function HasItemInStash(bot, itemName)
    for i = 9, 14 do
        local item = bot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            return true, i
        end
    end
    return false, -1
end

-- Проверяет наличие предмета в курьере
local function HasItemInCourier(bot, itemName)
    local courier = GetTeamCourier(bot)
    if not courier then return false, -1 end
    
    for i = 0, 5 do
        local item = courier:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            return true, i
        end
    end
    return false, -1
end

-- Проверяет наличие предмета в любом месте (герой, кладовая, курьер)
local function HasItemAnywhere(bot, itemName)
    -- Проверяем у героя
    local hasOnHero, heroSlot = HasItemOnHero(bot, itemName)
    if hasOnHero then return true, "hero", heroSlot end
    
    -- Проверяем в кладовой
    local hasInStash, stashSlot = HasItemInStash(bot, itemName)
    if hasInStash then return true, "stash", stashSlot end
    
    -- Проверяем в курьере
    local hasInCourier, courierSlot = HasItemInCourier(bot, itemName)
    if hasInCourier then return true, "courier", courierSlot end
    
    return false, nil, -1
end

-- Проверяет, есть ли свободные слоты в основном инвентаре (0-5) и рюкзаке (6-8)
local function HasFreeSlots(bot)
    for i = 0, 8 do
        if not bot:GetItemInSlot(i) then
            return true, i
        end
    end
    return false, -1
end

-- Заставляет курьера доставить предметы на героя
local function DeliverItemsWithCourier(bot)
    local courier = GetTeamCourier(bot)
    if not courier then return false end
    
    -- Проверяем состояние курьера
    local courierState = courier:GetCourierState()
    
    -- Если курьер свободен и находится на базе
    if courierState == COURIER_STATE_IDLE or courierState == COURIER_STATE_AT_BASE then
        -- Проверяем, есть ли у героя свободные слоты
        local hasFreeSlot, _ = HasFreeSlots(bot)
        if hasFreeSlot then
            -- Команда курьеру взять предметы из кладовой и доставить герою
            bot:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
            return true
        end
    end
    
    return false
end

-- Рекурсивная функция для покупки составных предметов
local function PurchaseItemRecursive(bot, itemName, purchasedComponents)
    purchasedComponents = purchasedComponents or {}
    
    -- Проверяем, не пытаемся ли мы купить уже купленный компонент в этой цепочке
    if purchasedComponents[itemName] then
        return true
    end
    
    -- Проверяем, есть ли предмет уже где-либо
    local hasItem, location, _ = HasItemAnywhere(bot, itemName)
    if hasItem then
        return true
    end
    
    -- Получаем рецепт предмета
    local recipe = itemRecipes[itemName]
    
    -- Если предмет простой (без рецепта) или рецепт пустой
    if not recipe or #recipe == 0 then
        -- Проверяем стоимость и наличие денег
        local itemCost = GetItemCost(itemName) or 0
        local currentGold = bot:GetGold()
        
        if itemCost > 0 and currentGold >= itemCost then
            -- Покупаем предмет
            local result = bot:ActionImmediate_PurchaseItem(itemName)
            
            if result == PURCHASE_ITEM_SUCCESS then
                purchasedComponents[itemName] = true
                DeliverItemsWithCourier(bot)
                return true
            end
        end
        return false
    end
    
    -- Если предмет составной, покупаем все компоненты
    local allComponentsPurchased = true
    
    for _, componentName in ipairs(recipe) do
        -- Рекурсивно покупаем компонент
        local componentPurchased = PurchaseItemRecursive(bot, componentName, purchasedComponents)
        
        if not componentPurchased then
            allComponentsPurchased = false
            break
        end
    end
    
    return allComponentsPurchased
end

-- Основные публичные функции -------------------------------------------------------

function PurchaseCore.PurchaseItem(bot, itemName)
    if not bot or not bot:IsAlive() then
        return false
    end
    
    local success = PurchaseItemRecursive(bot, itemName)
    
    if success then
        DeliverItemsWithCourier(bot)
    end
    
    return success
end

function PurchaseCore.HasItem(bot, itemName)
    if not bot then return false end
    local hasItem, _, _ = HasItemAnywhere(bot, itemName)
    return hasItem
end

function PurchaseCore.ForceDelivery(bot)
    if not bot then return false end
    return DeliverItemsWithCourier(bot)
end

function PurchaseCore.HasFreeInventorySlots(bot)
    if not bot then return false end
    local hasFree, _ = HasFreeSlots(bot)
    return hasFree
end

-- Утилиты для работы с инвентарем
function PurchaseCore.GetItemSlot(bot, itemName)
    for i = 0, 14 do
        local item = bot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            return i
        end
    end
    return -1
end

function PurchaseCore.CountFreeSlots(bot)
    local count = 0
    for i = 0, 8 do
        if not bot:GetItemInSlot(i) then
            count = count + 1
        end
    end
    return count
end

return PurchaseCore