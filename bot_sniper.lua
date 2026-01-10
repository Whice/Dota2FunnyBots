-- game/dota/scripts/vscripts/bots/bot_sniper.lua
-- Подключаем дополнительные функции
local SimpleActions = require(GetScriptDirectory().."/AdditionalFunctions/SimpleActions")

-- Основные константы для снайпера
local LANING_RADIUS = 1200
local FARM_RADIUS = 1000
local ATTACK_RANGE = 950  -- Дальность атаки снайпера с Take Aim

-- Функция для расчета расстояния
function GetDistance(v1, v2)
    return math.sqrt(math.pow(v1.x - v2.x, 2) + math.pow(v1.y - v2.y, 2))
end

function GetDesire()
    -- Эта функция будет вызываться режимами
    return 0
end

function OnStart()
    -- Вызывается при старте режима
end

function OnEnd()
    -- Вызывается при завершении режима
end

function Think()
    local npcBot = GetBot()
    
    -- Проверяем, жив ли герой
    if not npcBot:IsAlive() then
        return
    end
    
    -- Получаем ближайших врагов
    local enemies = npcBot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
    local creeps = SimpleActions.GetNearbyCreepsInfo(npcBot, 1200, true)
    
    -- Основная логика поведения
    if #enemies > 0 then
        -- Есть враги поблизости - атакуем самого слабого
        HandleCombat(npcBot, enemies)
    else
        -- Нет врагов - фармим
        HandleFarming(npcBot)
    end
    
    -- Использование способностей
    UseAbilities(npcBot)
end

function HandleCombat(npcBot, enemies)
    -- Находим самого слабого врага
    local weakestEnemy = nil
    local lowestHealth = 10000
    
    for _, enemy in ipairs(enemies) do
        if enemy and enemy:IsAlive() then
            local health = enemy:GetHealth()
            if health < lowestHealth then
                lowestHealth = health
                weakestEnemy = enemy
            end
        end
    end
    
    if weakestEnemy then
        local distance = GetUnitToUnitDistance(npcBot, weakestEnemy)
        
        -- Если враг в пределах атаки
        if distance <= npcBot:GetAttackRange() + 200 then
            npcBot:Action_AttackUnit(weakestEnemy, false)
        else
            -- Подходим ближе
            npcBot:Action_MoveToLocation(weakestEnemy:GetLocation())
        end
    end
end

function HandleFarming(npcBot)
    -- Используем нашу функцию для поиска цели для ластхита
    local lastHitTarget = SimpleActions.GetLastHitTarget(npcBot, 1000)
    local denyTarget = SimpleActions.GetDenyTarget(npcBot, 1000)
    
    if lastHitTarget then
        -- Атакуем крипа для ластхита
        npcBot:Action_AttackUnit(lastHitTarget.unit, false)
    elseif denyTarget then
        -- Денаим союзного крипа
        npcBot:Action_AttackUnit(denyTarget.unit, false)
    else
        -- Ищем крипа с наименьшим здоровьем для фарма
        local lowestHealthCreep = SimpleActions.GetLaneCreepWithLowestHealth(npcBot, 1000, true)
        
        if lowestHealthCreep then
            npcBot:Action_AttackUnit(lowestHealthCreep.unit, false)
        else
            -- Если нет крипов, двигаемся к линии
            GoToLane(npcBot)
        end
    end
end

function GoToLane(npcBot)
    local assignedLane = npcBot:GetAssignedLane()
    
    if assignedLane == LANE_NONE then
        assignedLane = LANE_MID  -- По умолчанию идем на мид
    end
    
    -- Получаем позицию фронта на нашей линии
    local laneFront = GetLaneFrontLocation(GetTeam(), assignedLane, 0)
    
    if laneFront then
        npcBot:Action_MoveToLocation(laneFront)
    end
end

function UseAbilities(npcBot)
    -- Получаем способности снайпера
    local shrapnel = npcBot:GetAbilityByName("sniper_shrapnel")
    local headshot = npcBot:GetAbilityByName("sniper_headshot")
    local takeAim = npcBot:GetAbilityByName("sniper_take_aim")
    local assassinate = npcBot:GetAbilityByName("sniper_assassinate")
    
    -- Используем Take Aim если доступно и не прокачано
    if takeAim and takeAim:IsFullyCastable() and takeAim:GetLevel() < takeAim:GetMaxLevel() then
        npcBot:Action_UseAbility(takeAim)
        return
    end
    
    -- Используем Shrapnel для замедления врагов или фарма
    if shrapnel and shrapnel:IsFullyCastable() then
        local enemies = npcBot:GetNearbyHeroes(shrapnel:GetCastRange(), true, BOT_MODE_NONE)
        
        if #enemies > 0 then
            -- Бросаем Shrapnel под ноги врагам
            local targetLocation = enemies[1]:GetLocation()
            npcBot:Action_UseAbilityOnLocation(shrapnel, targetLocation)
        else
            -- Используем для фарма крипов
            local creeps = npcBot:GetNearbyCreeps(shrapnel:GetCastRange(), true)
            if #creeps >= 3 then  -- Если есть группа крипов
                local creepLocation = creeps[1]:GetLocation()
                npcBot:Action_UseAbilityOnLocation(shrapnel, creepLocation)
            end
        end
    end
    
    -- Используем Assassinate для добивания
    if assassinate and assassinate:IsFullyCastable() then
        local enemies = npcBot:GetNearbyHeroes(assassinate:GetCastRange(), true, BOT_MODE_NONE)
        
        for _, enemy in ipairs(enemies) do
            if enemy and enemy:IsAlive() then
                local enemyHealth = enemy:GetHealth()
                local killThreshold = 300 + (npcBot:GetLevel() * 50)  -- Примерный порог убийства
                
                if enemyHealth <= killThreshold then
                    npcBot:Action_UseAbilityOnEntity(assassinate, enemy)
                    return
                end
            end
        end
    end
end

-- Функция для покупки предметов
function ItemPurchaseThink()
    local npcBot = GetBot()
    
    -- Базовый билд для снайпера
    local itemBuild = {
        "item_wraith_band",
        "item_power_treads",
        "item_magic_wand",
        "item_manta_style",
        "item_dragon_lance",
        "item_hurricane_pike",
        "item_greater_crit",
        "item_butterfly"
    }
    
    -- Логика покупки предметов
    for _, itemName in ipairs(itemBuild) do
        if npcBot:GetGold() >= GetItemCost(itemName) then
            -- Проверяем, есть ли уже этот предмет
            local found = false
            for i = 0, 8 do
                local item = npcBot:GetItemInSlot(i)
                if item and item:GetName() == itemName then
                    found = true
                    break
                end
            end
            
            if not found then
                npcBot:ActionImmediate_PurchaseItem(itemName)
                break
            end
        end
    end
end

-- Функция для использования предметов
function ItemUsageThink()
    local npcBot = GetBot()
    
    -- Проверяем предметы в инвентаре
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i)
        if item then
            local itemName = item:GetName()
            
            -- Использование healing salve или tango
            if (itemName == "item_tango" or itemName == "item_flask" or 
                itemName == "item_enchanted_mango") and npcBot:GetHealth() < npcBot:GetMaxHealth() * 0.5 then
                npcBot:Action_UseAbility(item)
                return
            end
            
            -- Использование magic stick/wand
            if (itemName == "item_magic_stick" or itemName == "item_magic_wand") and 
               item:IsFullyCastable() and npcBot:GetHealth() < npcBot:GetMaxHealth() * 0.4 then
                npcBot:Action_UseAbility(item)
                return
            end
        end
    end
end

-- Экспорт функций для системы ботов
local botSniper = {}

botSniper.Think = Think
botSniper.ItemPurchaseThink = ItemPurchaseThink
botSniper.ItemUsageThink = ItemUsageThink

return botSniper