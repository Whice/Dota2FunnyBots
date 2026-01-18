-- item_purchase_sniper.lua
-- Автономный скрипт покупок для Sniper

-- Импортируем модуль покупок
local ItemPurchaseManager = require(GetScriptDirectory().."/ItemPurchase/ItemPurchaseManager")
local CourierManager = require(GetScriptDirectory().."/ItemPurchase/CourierManager")

-- Флаг инициализации для бота
local botInitialized = false


-- Инициализация системы покупок
function InitializePurchases(bot)
    if not bot then return end
    
    -- Создаем таблицу расходников (Iron Branch) - нужно 3 ветки
    local consumablesTable = ItemPurchaseManager.CreateConsumablesTable({
        ["item_branches"] = {
            desired = 3,      -- Нужно 3 ветки
            priority = 100,   -- Максимальный приоритет (первая покупка)
            purchased = 0     -- Изначально не куплено
        }
    })
    
    -- Создаем таблицу основных предметов
    local itemsTable = ItemPurchaseManager.CreateItemsTable({
        {
            name = "item_wraith_band",  -- Wraith Band
            desired = 2,                -- Нужно 2 экземпляра
            purchased = 0,              -- Пока куплено 0
            priority = 90               -- Высокий приоритет
        },
        {
            name = "item_lifesteal",    -- Morbid Mask
            desired = 1,                -- Нужно 1 экземпляр
            purchased = 0,
            priority = 79
        },
        {
            name = "item_boots",        -- Boots of Speed
            desired = 1,
            purchased = 0,
            priority = 78
        },
        {
            name = "item_maelstrom",    -- Maelstrom
            desired = 1,
            purchased = 0,
            priority = 70
        },
        {
            name = "item_manta",        -- Manta Style
            desired = 1,
            purchased = 0,
            priority = 70
        },
        {
            name = "item_recipe_travel_boots",  -- Travel Boots recipe
            desired = 1,
            purchased = 0,
            priority = 70
        }
    })
    
    -- Устанавливаем таблицы в менеджер покупок
    ItemPurchaseManager.SetConsumables(bot, consumablesTable)
    ItemPurchaseManager.SetItems(bot, itemsTable)
end

-- Основная функция обработки покупок
function ProcessPurchases(bot)
    if not bot then return end
    
    -- Получаем таблицу покупок бота
    local purchaseTable = ItemPurchaseManager.GetPurchaseTable(bot)
    
    -- Если курьер занят, ждем
    if CourierManager.IsCourierBusy(bot) then
        return
    end
    
    -- 1. Пытаемся купить расходники (Iron Branch)
    local consumablesPurchased = ItemPurchaseManager.ProcessConsumables(bot)
    
    -- 2. Если расходники куплены, покупаем основные предметы
    if not consumablesPurchased then
        ItemPurchaseManager.ProcessPriorityItem(bot)
    end
    
    -- 3. Если что-то купили, отправляем курьера
    -- Исправлено: используем CourierManager вместо ItemPurchaseManager
    if consumablesPurchased then
        CourierManager.SendCourierToBot(bot)
    end
end

-- Функция для получения статуса покупок (опционально, для отладки)
function GetPurchaseStatus()
    local npcBot = GetBot()
    if not npcBot then return "Бот не найден" end
    
    local purchaseTable = ItemPurchaseManager.GetPurchaseTable(npcBot)
    if not purchaseTable then return "Таблица покупок не инициализирована" end
    
    local status = "Статус покупок Sniper:\n"
    
    -- Информация о расходниках (Iron Branch)
    if purchaseTable.consumables and purchaseTable.consumables["item_branches"] then
        local branchData = purchaseTable.consumables["item_branches"]
        status = status .. string.format("Iron Branch: %d/%d\n", 
                  branchData.purchased or 0, branchData.desired or 3)
    end
    
    -- Информация о предметах
    if purchaseTable.items and #purchaseTable.items > 0 then
        for _, item in ipairs(purchaseTable.items) do
            if item.name == "item_wraith_band" then
                status = status .. string.format("Wraith Band: %d/%d\n", 
                          item.purchased or 0, item.desired or 2)
            elseif item.name == "item_lifesteal" then
                status = status .. string.format("Morbid Mask: %d/%d\n", 
                          item.purchased or 0, item.desired or 1)
            elseif item.name == "item_boots" then
                status = status .. string.format("Boots: %d/%d\n", 
                          item.purchased or 0, item.desired or 1)
            elseif item.name == "item_maelstrom" then
                status = status .. string.format("Maelstrom: %d/%d\n", 
                          item.purchased or 0, item.desired or 1)
            end
        end
    end
    
    return status
end

local lastCheck = -999
local CHECK_RATE = 2

-- Функция Think для покупок (будет вызываться из основного скрипта)
function ItemPurchaseThink()
    local npcBot = GetBot()
    
    if DotaTime() < lastCheck + CHECK_RATE then
        return
    end
    lastCheck = DotaTime()

    if not npcBot or not npcBot:IsAlive() then
        return
    end
    
    -- Инициализируем систему покупок один раз
    if not botInitialized then
        InitializePurchases(npcBot)
        botInitialized = true
    end
    
    -- Обрабатываем покупки
    ProcessPurchases(npcBot)

    -- Периодически вызываем курьера
    CourierManager.SendCourierToBot(npcBot)
end