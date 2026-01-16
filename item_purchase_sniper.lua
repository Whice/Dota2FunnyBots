-- item_purchase_sniper.lua
-- Автономный скрипт покупок для Sniper

-- Импортируем модуль покупок
local ItemPurchaseManager = require(GetScriptDirectory().."/ItemPurchase/ItemPurchaseManager")

-- Флаг инициализации для бота
local botInitialized = false


-- Инициализация системы покупок
function InitializePurchases(bot)
    if not bot then return end
    
    -- Создаем таблицу расходников (Iron Branch)
    local consumablesTable = ItemPurchaseManager.CreateConsumablesTable({
        ["item_branches"] = {
            desired = 1,      -- Нужна 1 ветка
            priority = 100,   -- Максимальный приоритет (первая покупка)
            purchased = 0     -- Изначально не куплено
        }
    })
    
    -- Создаем таблицу основных предметов (Wraith Band)
    local itemsTable = ItemPurchaseManager.CreateItemsTable({
        {
            name = "item_wraith_band",  -- Целевой предмет
            priority = 90,               -- Высокий приоритет (вторая покупка)
            purchased = false            -- Изначально не куплен
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
    if ItemPurchaseManager.IsCourierBusy(bot) then
        return
    end
    
    -- 1. Пытаемся купить расходники (Iron Branch)
    local consumablesPurchased = ItemPurchaseManager.ProcessConsumables(bot)
    
    -- 2. Если расходники куплены, покупаем Wraith Band
    if not consumablesPurchased then
        ItemPurchaseManager.ProcessPriorityItem(bot)
    end
    
    -- 3. Если что-то купили, отправляем курьера
    if consumablesPurchased then
        ItemPurchaseManager.SendCourierForItems(bot)
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
                  branchData.purchased or 0, branchData.desired or 1)
    end
    
    -- Информация о Wraith Band
    if purchaseTable.items and #purchaseTable.items > 0 then
        local wbItem = purchaseTable.items[1]
        if wbItem then
            status = status .. string.format("Wraith Band: %s\n", 
                      wbItem.purchased and "куплен" or "в процессе")
        end
    end
    
    return status
end


-- Функция Think для покупок (будет вызываться из основного скрипта)
function ItemPurchaseThink()
    local npcBot = GetBot()
    
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
end