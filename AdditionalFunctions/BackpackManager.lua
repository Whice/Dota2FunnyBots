-- AdditionalFunctions/BackpackManager.lua
-- Модуль для автоматической сортировки предметов в инвентаре и рюкзаке по весам

local BackpackManager = {}

-- Таблица весов предметов (чем выше вес, тем приоритетнее предмет)
-- Расходники и ветки имеют наименьший вес, составные предметы - больший вес
local ITEM_WEIGHTS = {
    -- Расходники (самый низкий вес)
    ["item_tango"] = 1,
    ["item_tango_single"] = 1,
    ["item_branches"] = 1,
    ["item_circlet"] = 1,
    ["item_clarity"] = 1,
    ["item_flask"] = 1,
    ["item_dust"] = 1,
    ["item_smoke_of_deceit"] = 1,
    ["item_ward_observer"] = 1,
    ["item_ward_sentry"] = 1,
    ["item_faerie_fire"] = 1,
    ["item_tpscroll"] = 1,
    
    -- Базовые компоненты
    ["item_slippers"] = 5,
    ["item_gauntlets"] = 5,
    ["item_mantle"] = 5,
    ["item_blades_of_attack"] = 5,
    ["item_chainmail"] = 5,
    ["item_quarterstaff"] = 5,
    ["item_helm_of_iron_will"] = 5,
    ["item_broadsword"] = 5,
    ["item_claymore"] = 5,
    ["item_javelin"] = 5,
    ["item_mithril_hammer"] = 5,
    ["item_ring_of_protection"] = 5,
    ["item_stout_shield"] = 5,
    ["item_quelling_blade"] = 5,
    ["item_orb_of_venom"] = 5,
    
    -- Предметы средней стоимости
    ["item_boots"] = 10,
    ["item_gloves"] = 10,
    ["item_lifesteal"] = 10,
    ["item_ring_of_regen"] = 10,
    ["item_sobi_mask"] = 10,
    ["item_void_stone"] = 10,
    ["item_blink"] = 10,
    ["item_blade_of_alacrity"] = 10,
    ["item_belt_of_strength"] = 10,
    ["item_robe"] = 10,
    ["item_ogre_axe"] = 10,
    ["item_staff_of_wizardry"] = 10,
    ["item_ring_of_health"] = 10,
    
    -- Составные предметы начального уровня (высокий вес)
    ["item_wraith_band"] = 50,
    ["item_power_treads"] = 50,
    ["item_phase_boots"] = 50,
    ["item_maelstrom"] = 50,
    ["item_yasha"] = 50,
    ["item_dragon_lance"] = 50,
    ["item_force_staff"] = 50,
    
    -- Предметы высокого уровня (максимальный вес)
    ["item_manta"] = 100,
    ["item_mjollnir"] = 100,
    ["item_butterfly"] = 100,
    ["item_satanic"] = 100,
    ["item_skadi"] = 100,
    ["item_abyssal_blade"] = 100,
    ["item_bloodthorn"] = 100,
    ["item_travel_boots"] = 100,
    ["item_travel_boots_2"] = 100,
    
    -- Активируемые предметы (средний вес)
    ["item_black_king_bar"] = 30,
    ["item_sheepstick"] = 30,
    ["item_orchid"] = 30,
    ["item_cyclone"] = 30,
    ["item_urn_of_shadows"] = 30,
    ["item_spirit_vessel"] = 30,
    ["item_medallion_of_courage"] = 30,
    ["item_solar_crest"] = 30,
    
    -- Ауры и групповые предметы
    ["item_vladmir"] = 25,
    ["item_mekansm"] = 25,
    ["item_guardian_greaves"] = 25,
    ["item_pipe"] = 25,
    ["item_crimson_guard"] = 25,
    ["item_shivas_guard"] = 25,
    ["item_assault"] = 25,
    
    -- По умолчанию для неизвестных предметов
    ["default"] = 0
}

-- Время последнего обновления для каждого бота
local lastUpdateTime = {}

-- Интервал обновления (секунды)
local UPDATE_INTERVAL = 1.0

-- Получить вес предмета по его имени
-- @param itemName - название предмета
-- @return вес предмета (число)
local function GetItemWeight(itemName)
    if not itemName then return 0 end
    return ITEM_WEIGHTS[itemName] or ITEM_WEIGHTS["default"]
end

-- Получить информацию о предметах в слотах 0-8 (основной инвентарь + рюкзак)
-- @param bot - ссылка на бота
-- @return таблица с информацией о предметах: {slot, item, weight, isBackpack}
local function GetInventoryItems(bot)
    local items = {}
    
    -- Основной инвентарь (слоты 0-5)
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item then
            local itemName = item:GetName()
            table.insert(items, {
                slot = slot,
                item = item,
                name = itemName,
                weight = GetItemWeight(itemName),
                isBackpack = false
            })
        else
            table.insert(items, {
                slot = slot,
                item = nil,
                name = nil,
                weight = 0,
                isBackpack = false
            })
        end
    end
    
    -- Рюкзак (слоты 6-8)
    for slot = 6, 8 do
        local item = bot:GetItemInSlot(slot)
        if item then
            local itemName = item:GetName()
            table.insert(items, {
                slot = slot,
                item = item,
                name = itemName,
                weight = GetItemWeight(itemName),
                isBackpack = true
            })
        else
            table.insert(items, {
                slot = slot,
                item = nil,
                name = nil,
                weight = 0,
                isBackpack = true
            })
        end
    end
    
    return items
end

-- Отсортировать предметы по весу (по убыванию)
-- @param items - таблица с предметами
-- @return отсортированная таблица
local function SortItemsByWeight(items)
    local sorted = {}
    for _, item in ipairs(items) do
        table.insert(sorted, item)
    end
    
    table.sort(sorted, function(a, b)
        -- Сначала сортируем по весу (больший вес - выше)
        if a.weight ~= b.weight then
            return a.weight > b.weight
        end
        -- Если вес одинаковый, то не backpack предметы имеют приоритет
        if a.isBackpack ~= b.isBackpack then
            return not a.isBackpack
        end
        -- Если все одинаково, сортируем по имени для стабильности
        return (a.name or "") < (b.name or "")
    end)
    
    return sorted
end

-- Определить целевые слоты для предметов после сортировки
-- @param sortedItems - отсортированные предметы
-- @return таблица с целевыми слотами для каждого предмета
local function GetTargetSlots(sortedItems)
    local targetSlots = {}
    
    -- Сначала заполняем основной инвентарь (слоты 0-5) самыми тяжелыми предметами
    local mainInventoryCount = 0
    for i, item in ipairs(sortedItems) do
        if mainInventoryCount < 6 then
            -- Помещаем в основной инвентарь
            targetSlots[item.slot] = mainInventoryCount
            mainInventoryCount = mainInventoryCount + 1
        else
            -- Помещаем в рюкзак (слоты 6, 7, 8)
            targetSlots[item.slot] = 5 + (i - 5)  -- 6, 7 или 8
        end
    end
    
    return targetSlots
end

-- Выполнить необходимые перемещения предметов
-- @param bot - ссылка на бота
-- @param currentItems - текущие предметы
-- @param targetSlots - целевые слоты для каждого предмета
local function PerformMoves(bot, currentItems, targetSlots)
    local moved = false
    
    -- Создаем копию текущих предметов для отслеживания перемещений
    local itemAtSlot = {}
    for _, itemInfo in ipairs(currentItems) do
        itemAtSlot[itemInfo.slot] = itemInfo
    end
    
    -- Алгоритм перемещения: находим предметы, которые не на своих местах, и перемещаем их
    for currentSlot = 0, 8 do
        local currentItem = itemAtSlot[currentSlot]
        local targetSlot = targetSlots[currentSlot]
        
        -- Если предмет уже на своем месте или слота нет в targetSlots, пропускаем
        if targetSlot and currentSlot ~= targetSlot then
            local targetItem = itemAtSlot[targetSlot]
            
            -- Если целевой слот пустой или в нем предмет с меньшим весом, делаем обмен
            if not targetItem or (currentItem and currentItem.weight > (targetItem.weight or 0)) then
                -- Выполняем обмен
                bot:ActionImmediate_SwapItems(currentSlot, targetSlot)
                moved = true
                
                -- Обновляем нашу локальную копию
                itemAtSlot[currentSlot], itemAtSlot[targetSlot] = itemAtSlot[targetSlot], itemAtSlot[currentSlot]
            end
        end
    end
    
    return moved
end

-- Основная функция обновления рюкзака
-- @param bot - ссылка на бота
-- @return true если были выполнены перемещения, false если нет
function BackpackManager.Update(bot)
    if not bot or not bot:IsAlive() then
        return false
    end
    
    -- Проверяем интервал обновления
    local botID = bot:GetPlayerID()
    local currentTime = DotaTime()
    
    if lastUpdateTime[botID] and currentTime < lastUpdateTime[botID] + UPDATE_INTERVAL then
        return false
    end
    
    lastUpdateTime[botID] = currentTime
    
    -- Получаем текущие предметы
    local items = GetInventoryItems(bot)
    
    -- Сортируем предметы по весу
    local sortedItems = SortItemsByWeight(items)
    
    -- Определяем целевые слоты
    local targetSlots = {}
    for i, item in ipairs(sortedItems) do
        targetSlots[item.slot] = i - 1  -- Преобразуем в 0-based индекс
    end
    
    -- Выполняем перемещения
    local moved = PerformMoves(bot, items, targetSlots)
    
    return moved
end

-- Функция для принудительного обновления (игнорирует интервал)
-- @param bot - ссылка на бота
-- @return true если были выполнены перемещения, false если нет
function BackpackManager.ForceUpdate(bot)
    if not bot or not bot:IsAlive() then
        return false
    end
    
    -- Сбрасываем таймер для этого бота
    local botID = bot:GetPlayerID()
    lastUpdateTime[botID] = nil
    
    -- Выполняем обновление
    return BackpackManager.Update(bot)
end

-- Получить информацию о весе предмета (для отладки)
-- @param itemName - название предмета
-- @return вес предмета
function BackpackManager.GetItemWeight(itemName)
    return GetItemWeight(itemName)
end

-- Добавить или обновить вес предмета
-- @param itemName - название предмета
-- @param weight - новый вес
function BackpackManager.SetItemWeight(itemName, weight)
    if itemName and weight then
        ITEM_WEIGHTS[itemName] = weight
    end
end

-- Получить статус сортировки (для отладки)
-- @param bot - ссылка на бота
-- @return строку с информацией о статусе
function BackpackManager.GetStatus(bot)
    if not bot then return "Бот не найден" end
    
    local items = GetInventoryItems(bot)
    local status = "Статус сортировки рюкзака:\n"
    
    -- Основной инвентарь
    status = status .. "Основной инвентарь:\n"
    for i = 0, 5 do
        local item = bot:GetItemInSlot(i)
        if item then
            local weight = GetItemWeight(item:GetName())
            status = status .. string.format("  Слот %d: %s (вес: %d)\n", i, item:GetName(), weight)
        else
            status = status .. string.format("  Слот %d: пусто\n", i)
        end
    end
    
    -- Рюкзак
    status = status .. "Рюкзак:\n"
    for i = 6, 8 do
        local item = bot:GetItemInSlot(i)
        if item then
            local weight = GetItemWeight(item:GetName())
            status = status .. string.format("  Слот %d: %s (вес: %d)\n", i, item:GetName(), weight)
        else
            status = status .. string.format("  Слот %d: пусто\n", i)
        end
    end
    
    -- Время последнего обновления
    local botID = bot:GetPlayerID()
    local lastUpdate = lastUpdateTime[botID] or 0
    status = status .. string.format("\nПоследнее обновление: %.1f сек назад", DotaTime() - lastUpdate)
    
    return status
end

-- Очистить таймеры (при перезагрузке скриптов)
function BackpackManager.ClearTimers()
    lastUpdateTime = {}
end

return BackpackManager