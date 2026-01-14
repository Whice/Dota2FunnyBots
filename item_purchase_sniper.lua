-- item_purchase_sniper.lua
-- Логика покупки предметов для Снайпера (без использования goto)

local ItemPurchaseSniper = {}

-- Время последней покупки кларетки
local lastClarityPurchaseTime = -120

-- Хранилище рецептов предметов
local itemRecipes = {
    ["item_tango"] = {},
    ["item_branches"] = {},
    ["item_circlet"] = {},
    ["item_slippers"] = {},
    ["item_faerie_fire"] = {},
    ["item_clarity"] = {},
    
    ["item_wraith_band"] = {
        "item_circlet",
        "item_slippers",  
        "item_recipe_wraith_band"
    },
    
    ["item_boots"] = {},
    
    ["item_maelstrom"] = {
        "item_mithril_hammer",
        "item_javelin",
        "item_gloves"
    },
    
    ["item_desolator"] = {
        "item_blight_stone",
        "item_mithril_hammer",
        "item_claymore"
    },
    
    ["item_dragon_lance"] = {
        "item_blade_of_alacrity",
        "item_belt_of_strength",
        "item_recipe_dragon_lance"
    },
    
    ["item_travel_boots"] = {
        "item_boots",
        "item_recipe_travel_boots"
    },
    
    ["item_mjollnir"] = {
        "item_maelstrom",
        "item_hyperstone",
        "item_recipe_mjollnir"
    },
    
    ["item_yasha"] = {
        "item_blade_of_alacrity",
        "item_band_of_elvenskin",
        "item_recipe_yasha"
    },
    
    ["item_manta"] = {
        "item_yasha",
        "item_diadem",
        "item_recipe_manta"
    },
    
    ["item_satanic"] = {
        "item_morbid_mask",
        "item_claymore",
        "item_reaver"
    },
    
    ["item_butterfly"] = {
        "item_eaglesong",
        "item_talisman_of_evasion",
        "item_claymore"
    },
    
    ["item_skadi"] = {
        "item_ultimate_orb",
        "item_ultimate_orb",
        "item_point_booster"
    },
    
    ["item_aghanims_shard"] = {}
}

-- Порядок покупки предметов
local purchaseOrder = {
    "item_tango",
    "item_branches",
    "item_branches", 
    "item_branches",
    "item_circlet",
    "item_slippers",
    "item_faerie_fire",
    
    "item_circlet",
    "item_slippers",
    "item_recipe_wraith_band",
    
    "item_circlet",
    "item_slippers",
    "item_recipe_wraith_band",
    
    "item_boots",
    
    "item_mithril_hammer",
    "item_javelin",
    "item_gloves",
    
    "item_blight_stone",
    "item_mithril_hammer",
    "item_claymore",
    
    "item_blade_of_alacrity",
    "item_belt_of_strength",
    "item_recipe_dragon_lance",
    
    "item_boots",
    "item_recipe_travel_boots",
    
    "item_blade_of_alacrity",
    "item_belt_of_strength",
    "item_recipe_dragon_lance",
    
    "item_blade_of_alacrity",
    "item_band_of_elvenskin",
    "item_recipe_yasha",
    
    "item_yasha",
    "item_diadem",
    "item_recipe_manta",
    
    "item_maelstrom",
    "item_hyperstone",
    "item_recipe_mjollnir",
    
    "item_morbid_mask",
    "item_claymore",
    "item_reaver",
    
    "item_eaglesong",
    "item_talisman_of_evasion",
    "item_claymore",
    
    "item_ultimate_orb",
    "item_ultimate_orb",
    "item_point_booster"
}

-- Предметы для продажи
local itemsToSell = {
    "item_branches",
    "item_circlet", 
    "item_slippers",
    "item_faerie_fire",
    "item_wraith_band",
    "item_boots",
    "item_blight_stone",
    "item_morbid_mask"
}

-- Получить стоимость предмета
local function GetItemCostSafe(itemName)
    local cost = GetItemCost(itemName)
    return cost or 0
end

-- Проверяет, есть ли у бота предмет
local function HasItem(bot, itemName)
    for i = 0, 15 do
        local item = bot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            return true
        end
    end
    return false
end

-- Проверяет, собран ли предмет полностью
local function IsItemCompleted(bot, itemName)
    if not itemRecipes[itemName] or #itemRecipes[itemName] == 0 then
        return HasItem(bot, itemName)
    end
    return HasItem(bot, itemName)
end

-- Проверяет, нужен ли предмет для крафта следующего предмета
local function IsItemNeededForCrafting(bot, itemName)
    local nextItem = ItemPurchaseSniper.GetNextPurchaseItem(bot)
    if not nextItem then
        return false
    end
    
    local recipe = itemRecipes[nextItem]
    if not recipe then
        return false
    end
    
    for _, comp in ipairs(recipe) do
        if comp == itemName then
            return true
        end
    end
    
    return false
end

-- Проверяет, нужно ли купить танго
function ItemPurchaseSniper.ShouldBuyTango(bot)
    local tpSlot = bot:GetItemInSlot(15)
    if tpSlot and tpSlot:GetName() == "item_tpscroll" then
        if tpSlot:GetCurrentCharges() <= 1 then
            return true
        end
    else
        return true
    end
    
    for i = 0, 5 do
        local item = bot:GetItemInSlot(i)
        if item and item:GetName() == "item_tango" then
            if item:GetCurrentCharges() <= 1 then
                return true
            end
        end
    end
    
    return false
end

-- Проверяет, нужно ли купить кларетку
function ItemPurchaseSniper.ShouldBuyClarity(bot)
    local currentTime = DotaTime()
    
    if currentTime - lastClarityPurchaseTime < 120 then
        return false
    end
    
    local hasClarity = false
    for i = 0, 15 do
        local item = bot:GetItemInSlot(i)
        if item and item:GetName() == "item_clarity" then
            hasClarity = true
            break
        end
    end
    
    if bot:GetMana() / bot:GetMaxMana() < 0.4 and not hasClarity then
        lastClarityPurchaseTime = currentTime
        return true
    end
    
    return false
end

-- Проверяет, доступен ли шард для покупки
function ItemPurchaseSniper.IsShardAvailable()
    return DotaTime() > 900
end

-- Получает следующий предмет для покупки
function ItemPurchaseSniper.GetNextPurchaseItem(bot)
    -- Проверяем приоритетные покупки
    if ItemPurchaseSniper.ShouldBuyTango(bot) then
        return "item_tango"
    end
    
    if ItemPurchaseSniper.ShouldBuyClarity(bot) then
        return "item_clarity"
    end
    
    if ItemPurchaseSniper.IsShardAvailable() and not HasItem(bot, "item_aghanims_shard") then
        return "item_aghanims_shard"
    end
    
    -- Локальная функция для обработки составных предметов
    local function processCompositeItem(itemName)
        if IsItemCompleted(bot, itemName) then
            return nil  -- Предмет уже собран
        end
        
        -- Проверяем все компоненты
        for _, component in ipairs(itemRecipes[itemName]) do
            if not HasItem(bot, component) then
                -- Для составных компонентов (как Yasha) рекурсивно проверяем
                if itemRecipes[component] and #itemRecipes[component] > 0 then
                    if not IsItemCompleted(bot, component) then
                        local subItem = ItemPurchaseSniper.GetNextPurchaseItem(bot)
                        if subItem then
                            return subItem
                        end
                    end
                else
                    -- Простой компонент, которого нет
                    return component
                end
            end
        end
        
        -- Если все компоненты есть, но предмет не собран, значит нужен рецепт
        if itemName:find("recipe") then
            return itemName
        end
        
        return nil
    end
    
    -- Основной цикл по порядку покупки
    for _, itemName in ipairs(purchaseOrder) do
        local nextItem = nil
        
        if itemRecipes[itemName] and #itemRecipes[itemName] > 0 then
            -- Составной предмет
            nextItem = processCompositeItem(itemName)
        else
            -- Простой предмет
            if not HasItem(bot, itemName) then
                nextItem = itemName
            end
        end
        
        if nextItem then
            return nextItem
        end
    end
    
    -- Проверяем апгрейд предметы
    local upgradeChecks = {
        "item_mjollnir",
        "item_satanic", 
        "item_butterfly",
        "item_skadi",
        "item_aghanims_shard"
    }
    
    for _, itemName in ipairs(upgradeChecks) do
        if not IsItemCompleted(bot, itemName) then
            if itemRecipes[itemName] then
                -- Для составных апгрейд-предметов
                for _, component in ipairs(itemRecipes[itemName]) do
                    if not HasItem(bot, component) then
                        return component
                    end
                end
            else
                -- Простой апгрейд-предмет
                if not HasItem(bot, itemName) then
                    return itemName
                end
            end
        end
    end
    
    return nil
end

-- Продает лишние предметы
function ItemPurchaseSniper.SellUnneededItems(bot)
    for _, itemName in ipairs(itemsToSell) do
        for i = 0, 15 do
            local item = bot:GetItemInSlot(i)
            if item and item:GetName() == itemName then
                -- Проверяем, не нужен ли предмет для текущего крафта
                if IsItemNeededForCrafting(bot, itemName) then
                    -- Пропускаем продажу, если предмет нужен для крафта
                    break
                end
                
                -- Продаем предмет
                bot:ActionImmediate_SellItem(item)
                return true
            end
        end
    end
    return false
end

-- Основная функция покупки предметов
function ItemPurchaseSniper.ItemPurchaseThink()
    local bot = GetBot()
    
    if not bot or not bot:IsAlive() or bot:IsChanneling() then
        return
    end
    
    -- Продаем лишние предметы
    if ItemPurchaseSniper.SellUnneededItems(bot) then
        return
    end
    
    -- Получаем следующий предмет для покупки
    local nextItem = ItemPurchaseSniper.GetNextPurchaseItem(bot)
    if not nextItem then
        return
    end
    
    -- Проверяем стоимость и наличие денег
    local itemCost = GetItemCostSafe(nextItem)
    local currentGold = bot:GetGold()
    
    if itemCost > 0 and currentGold >= itemCost then
        local result = bot:ActionImmediate_PurchaseItem(nextItem)
        
        if result == PURCHASE_ITEM_SUCCESS then
            return
        elseif result == PURCHASE_ITEM_OUT_OF_STOCK then
            return
        elseif result == PURCHASE_ITEM_INSUFFICIENT_GOLD then
            return
        end
    end
end

return ItemPurchaseSniper