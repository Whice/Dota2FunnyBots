local SimpleActions = {}

function SimpleActions.GetNearbyCreepsInfo(unit, radius, bEnemies)
    -- Получаем ближайших крипов
    local creeps = unit:GetNearbyCreeps(radius, bEnemies)
    local creepInfo = {}
    
    for _, creep in ipairs(creeps) do
        if creep and creep:IsAlive() then
            local info = {
                unit = creep,
                health = creep:GetHealth(),
                maxHealth = creep:GetMaxHealth(),
                healthPercent = creep:GetHealth() / creep:GetMaxHealth(),
                position = creep:GetLocation(),
                distance = GetUnitToUnitDistance(unit, creep),
                isAncient = creep:IsAncientCreep(),
                bounty = creep:GetBountyGoldMin(), -- минимальная награда
                team = creep:GetTeam()
            }
            
            -- Добавляем информацию о типе крипа
            if not creep:IsAncientCreep() then
                if creep:GetTeam() == TEAM_RADIANT then
                    info.creepType = "Radiant Lane Creep"
                elseif creep:GetTeam() == TEAM_DIRE then
                    info.creepType = "Dire Lane Creep"
                else
                    info.creepType = "Neutral Creep"
                end
            else
                info.creepType = "Ancient Creep"
            end
            
            table.insert(creepInfo, info)
        end
    end
    
    -- Сортируем по расстоянию (от ближнего к дальнему)
    table.sort(creepInfo, function(a, b)
        return a.distance < b.distance
    end)
    
    return creepInfo
end

function SimpleActions.GetLaneCreepWithLowestHealth(unit, radius, bEnemies)
    -- Получаем информацию о всех крипах
    local creeps = SimpleActions.GetNearbyCreepsInfo(unit, radius, bEnemies)
    
    if #creeps == 0 then
        return nil
    end
    
    -- Фильтруем только лейн-крипы (не нейтралы)
    local laneCreeps = {}
    for _, creep in ipairs(creeps) do
        if creep.creepType == "Radiant Lane Creep" or creep.creepType == "Dire Lane Creep" then
            table.insert(laneCreeps, creep)
        end
    end
    
    if #laneCreeps == 0 then
        return nil
    end
    
    -- Находим крипа с минимальным здоровьем
    local lowestHealthCreep = laneCreeps[1]
    for _, creep in ipairs(laneCreeps) do
        if creep.health < lowestHealthCreep.health then
            lowestHealthCreep = creep
        end
    end
    
    return lowestHealthCreep
end

function SimpleActions.GetNeutralCreepCamps(unit, radius)
    -- Получаем все нейтральные крипы
    local neutralCreeps = unit:GetNearbyNeutralCreeps(radius)
    local camps = {}
    
    for _, creep in ipairs(neutralCreeps) do
        if creep and creep:IsAlive() then
            local campInfo = {
                unit = creep,
                position = creep:GetLocation(),
                health = creep:GetHealth(),
                maxHealth = creep:GetMaxHealth(),
                isAncient = creep:IsAncientCreep()
            }
            table.insert(camps, campInfo)
        end
    end
    
    return camps
end

function SimpleActions.GetLastHitTarget(unit, radius)
    -- Получаем вражеских крипов
    local enemyCreeps = SimpleActions.GetNearbyCreepsInfo(unit, radius, true)
    
    if #enemyCreeps == 0 then
        return nil
    end
    
    -- Фильтруем только тех, у кого здоровье меньше урона атаки
    local attackDamage = unit:GetAttackDamage()
    local potentialLastHits = {}
    
    for _, creep in ipairs(enemyCreeps) do
        -- Простая проверка: если здоровье меньше урона атаки
        if creep.health <= attackDamage then
            table.insert(potentialLastHits, creep)
        end
    end
    
    if #potentialLastHits > 0 then
        -- Сортируем по ближайшему
        return potentialLastHits[1]
    end
    
    return nil
end

function SimpleActions.GetDenyTarget(unit, radius)
    -- Получаем союзных крипов
    local allyCreeps = SimpleActions.GetNearbyCreepsInfo(unit, radius, false)
    
    if #allyCreeps == 0 then
        return nil
    end
    
    -- Фильтруем только тех, у кого здоровье меньше урона атаки
    local attackDamage = unit:GetAttackDamage()
    local potentialDenies = {}
    
    for _, creep in ipairs(allyCreeps) do
        if creep.health <= attackDamage then
            table.insert(potentialDenies, creep)
        end
    end
    
    if #potentialDenies > 0 then
        -- Сортируем по ближайшему
        return potentialDenies[1]
    end
    
    return nil
end

-- Добавьте эти функции в существующий SimpleActions.lua файл

-------------------------------------------------------------------------------
-- Проверяет наличие предмета телепорта (Scroll of Town Portal) у бота.
-- <br/>Проверяет все слоты инвентаря (0-5) и рюкзака (6-8) на наличие предмета.
-- <br/>Возвращает true если найден хотя бы один телепорт.
-------------------------------------------------------------------------------
function SimpleActions.HasTeleport(bot)
    if bot == nil then
        return false
    end
    
    --Это спец слот для телепорта
    local item = bot:GetItemInSlot(15)
    if item then
        --Получить количество предметов (оно количество зарядов) в рюкзаке
        local teleportCount = item:GetCurrentCharges()     
        if teleportCount > 0 then
            return true
        end
    end
    
    return false
end

-------------------------------------------------------------------------------
-- Проверяет готовность телепорта к использованию.
-- <br/>Проверяет наличие телепорта и что его перезарядка завершена.
-- <br/>Возвращает true если телепорт найден и готов к использованию.
-- <br/>Если телепортов несколько, проверяет первый найденный.
-------------------------------------------------------------------------------
function SimpleActions.IsTeleportReady(bot)
    if bot == nil then
        return false
    end
    
    --Это спец слот для телепорта
    local item = bot:GetItemInSlot(15)
    if item then
        --Получить количество предметов (оно количество зарядов) в рюкзаке
        local teleportCount = item:GetCurrentCharges()     
        if teleportCount> 0 then
                -- Проверяем готовность телепорта (CD завершен)
            return item:IsFullyCastable()
        end
    end
    
    return false
end

--Время последней попытки покупки телепорта, пытаться можно не чаще раза в 2 секунды.
-- <br/>Первую покупку можно попробовать совершить только спустя 30 секунд после начала матча.
SimpleActions.lastTimeTeleportBouhgt = 30
-------------------------------------------------------------------------------
-- Покупает телепорты до максимального количества 2.
-- <br/>Если денег хватает на 2 телепорта, покупает 2.
-- <br/>Если денег хватает только на 1 телепорт, покупает 1.
-- <br/>Если денег не хватает даже на 1 телепорт, ничего не покупает.
-- <br/>Возвращает количество купленных телепортов.
-------------------------------------------------------------------------------
function SimpleActions.TryBuyTeleports(bot)
    if bot == nil then
        return 0
    end

    if DotaTime()<SimpleActions.lastTimeTeleportBouhgt+2 then
        return 0
    end
    SimpleActions.lastTimeTeleportBouhgt = DotaTime()
    
    local itemName = "item_tpscroll"
    local itemCost = GetItemCost(itemName)
    local currentGold = bot:GetGold()
    local teleportsBought = 0
    

    -- Считаем текущее количество телепортов у бота
    local teleportCount = 0
    
    -- Возвращает текущее количество предмета на складе лавки.
    teleportCount = teleportCount + GetItemStockCount(itemName)

    --Это спец слот для телепорта
    local item = bot:GetItemInSlot(15)
    if item then
        --Получить количество предметов (оно количество зарядов) в рюкзаке
        teleportCount = teleportCount +  item:GetCurrentCharges()
    end
    -- Определяем сколько телепортов нужно купить
    local teleportsNeeded = 2 - teleportCount
    
    if teleportsNeeded <= 0 then
        return 0  -- Уже есть максимальное количество
    end
    
    -- Пытаемся купить максимально возможное количество
    if teleportsNeeded >= 2 and currentGold >= itemCost * 2 then
        -- Покупаем 2 телепорта
        bot:ActionImmediate_PurchaseItem(itemName)
        bot:ActionImmediate_PurchaseItem(itemName)
        teleportsBought = 2
    elseif teleportsNeeded >= 1 and currentGold >= itemCost then
        -- Покупаем 1 телепорт
        bot:ActionImmediate_PurchaseItem(itemName)
        teleportsBought = 1
    end
    
    return teleportsBought
end

-------------------------------------------------------------------------------
-- Отправляет сообщение в командный чат (видно только вашей команде).
-- <br/>Использует функцию ActionImmediate_Chat с параметром allChat = false.
-- <br/>Сообщение будет видно только союзникам.
-- <br/>Возвращает true если сообщение было успешно отправлено.
-- <br/>Если бот не указан или сообщение пустое, возвращает false.
-------------------------------------------------------------------------------
function SimpleActions.Say(bot, message)
    if bot == nil then
        return false
    end
    
    if message == nil or message == "" then
        return false
    end
    
    -- Отправляем сообщение в командный чат (allChat = false)
    bot:ActionImmediate_Chat(message, false)
    return true
end

-------------------------------------------------------------------------------
-- Отправляет сообщение во всеобщий чат (видно всем игрокам).
-- <br/>Использует функцию ActionImmediate_Chat с параметром allChat = true.
-- <br/>Сообщение будет видно всем игрокам, включая противников.
-- <br/>Возвращает true если сообщение было успешно отправлено.
-- <br/>Если бот не указан или сообщение пустое, возвращает false.
-------------------------------------------------------------------------------
function SimpleActions.SayAll(bot, message)
    if bot == nil then
        return false
    end
    
    if message == nil or message == "" then
        return false
    end
    
    -- Отправляем сообщение во всеобщий чат (allChat = true)
    bot:ActionImmediate_Chat(message, true)
    return true
end

-------------------------------------------------------------------------------
-- Отправляет системное сообщение о действии бота в командный чат.
-- <br/>Автоматически форматирует сообщение с именем героя и описанием действия.
-- <br/>Пример: "[Снайпер] Телепортуюсь на верхнюю линию"
-- <br/>Возвращает true если сообщение было успешно отправлено.
-------------------------------------------------------------------------------
function SimpleActions.SayAction(bot, actionDescription)
    if bot == nil or actionDescription == nil then
        return false
    end
    
    local heroName = bot:GetUnitName()
    -- Убираем префикс "npc_dota_hero_" для более читаемого имени
    heroName = string.gsub(heroName, "npc_dota_hero_", "")
    -- Делаем первую букву заглавной
    heroName = heroName:sub(1,1):upper() .. heroName:sub(2)
    
    local message = "[" .. heroName .. "] " .. actionDescription
    return SimpleActions.Say(bot, message)
end

-------------------------------------------------------------------------------
-- Отправляет предупреждение об опасности в командный чат.
-- <br/>Использует стандартный формат для предупреждений.
-- <br/>Пример: "Осторожно! Враг замечен в лесу"
-- <br/>Возвращает true если сообщение было успешно отправлено.
-------------------------------------------------------------------------------
function SimpleActions.SayWarning(bot, warningMessage)
    if bot == nil or warningMessage == nil then
        return false
    end
    
    local message = "Осторожно! " .. warningMessage
    return SimpleActions.Say(bot, message)
end

-------------------------------------------------------------------------------
-- Отправляет информацию о статусе бота в командный чат.
-- <br/>Автоматически форматирует сообщение с текущим здоровьем, маной и уровнем.
-- <br/>Пример: "Статус: 80% HP, 50% MP, Ур. 10"
-- <br/>Возвращает true если сообщение было успешно отправлено.
-------------------------------------------------------------------------------
function SimpleActions.SayStatus(bot)
    if bot == nil then
        return false
    end
    
    local healthPercent = math.floor((bot:GetHealth() / bot:GetMaxHealth()) * 100)
    local manaPercent = math.floor((bot:GetMana() / bot:GetMaxMana()) * 100)
    local level = bot:GetLevel()
    
    local message = string.format("Статус: %d%% HP, %d%% MP, Ур. %d", 
                                 healthPercent, manaPercent, level)
    return SimpleActions.Say(bot, message)
end
-- Проверяет, находится ли бот около фронта на своей линии
function SimpleActions.IsOnNearOfFrontAssignedLane(bot, target_lane, radius)
    radius = radius or LANE_RADIUS
    
    if target_lane == LANE_NONE then
        return false
    end
    
    local laneFront = GetLaneFrontLocation(bot:GetTeam(), target_lane, 0)
    if not laneFront then
        return false
    end
    
    local distance = GetUnitToLocationDistance(bot, laneFront)
    return distance <= radius
end
-- Проверяет, находится ли бот на своей назначенной линии (в любом месте на линии)
-- Использует GetAmountAlongLane для определения позиции вдоль линии
-- @param bot - бот для проверки
-- @param target_lane - назначенная линия (LANE_TOP, LANE_MID, LANE_BOT)
-- @param max_distance_from_lane - максимальное расстояние от линии (по умолчанию 1500)
-- @return true если бот находится на линии, false иначе
function SimpleActions.IsOnAssignedLane(bot, target_lane, max_distance_from_lane)
    max_distance_from_lane = max_distance_from_lane or 1500  -- По умолчанию 1500 единиц
    
    if target_lane == LANE_NONE then
        return false
    end
    
    -- Получаем позицию бота
    local bot_location = bot:GetLocation()
    
    -- Используем GetAmountAlongLane для определения позиции на линии
    -- Функция возвращает таблицу { amount, distance }
    local lane_info = GetAmountAlongLane(target_lane, bot_location)
    
    if not lane_info then
        return false  -- Не удалось получить информацию о линии
    end
    
    local amount = lane_info.amount       -- Позиция вдоль линии (0.0 - 1.0)
    local distance = lane_info.distance   -- Расстояние от линии
    
    -- Проверяем условия:
    -- 1. amount должен быть между 0 и 1 (включительно)
    -- 2. Расстояние от линии должно быть меньше max_distance_from_lane
    -- 3. Также проверяем amount на небольшой допуск за пределы 0-1
    local tolerance = 0.05  -- 5% допуск за пределы линии
    
    if (amount >= 0 - tolerance and amount <= 1 + tolerance) and 
       (distance <= max_distance_from_lane) then
        return true
    end
    
    return false
end

return SimpleActions