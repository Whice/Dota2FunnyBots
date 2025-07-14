-- Dota 2 Bot Script
-- Последовательность поведений: лейн -> лес -> групповой пуш

local bot = GetBot()

-- Константы
local PHASE_LANING = 1
local PHASE_JUNGLE = 2
local PHASE_GROUP_PUSH = 3

-- Временные границы фаз (в секундах)
local LANING_TIME = 5 * 60    -- 5 минут
local JUNGLE_TIME = 10 * 60   -- 10 минут

-- Порог здоровья для возврата на базу
local LOW_HEALTH_THRESHOLD = 0.2

-- Порядок покупки предметов
local ITEM_PURCHASE_ORDER = {
    "item_boots",
    "item_wind_lace", 
    "item_power_treads",
    "item_ring_of_health",
    "item_vanguard",
    "item_void_stone",
    "item_linkens_sphere"
}

-- Переменные состояния
local currentPhase = PHASE_LANING
local purchaseIndex = 1
local assignedLane = nil

-- Функция определения текущей фазы игры
function GetCurrentPhase()
    local gameTime = DotaTime()
    
    if gameTime < LANING_TIME then
        return PHASE_LANING
    elseif gameTime < JUNGLE_TIME then
        return PHASE_JUNGLE
    else
        return PHASE_GROUP_PUSH
    end
end

-- Функция проверки низкого здоровья
function IsLowHealth()
    return bot:GetHealth() / bot:GetMaxHealth() < LOW_HEALTH_THRESHOLD
end

-- Функция возврата на базу
function ReturnToBase()
    local fountain = GetAncient(GetTeam())
    if fountain then
        bot:Action_MoveToLocation(fountain:GetLocation())
        return true
    end
    return false
end

-- Функция покупки предметов
function PurchaseItems()
    if purchaseIndex <= #ITEM_PURCHASE_ORDER then
        local itemName = ITEM_PURCHASE_ORDER[purchaseIndex]
        local itemCost = GetItemCost(itemName)
        
        if bot:GetGold() >= itemCost then
            bot:Action_PurchaseItem(itemName)
            purchaseIndex = purchaseIndex + 1
        end
    end
end

-- Функция определения назначенной линии
function GetAssignedLane()
    if assignedLane == nil then
        local botID = bot:GetPlayerID()
        local lanes = {LANE_TOP, LANE_MID, LANE_BOT}
        assignedLane = lanes[(botID % 3) + 1]
    end
    return assignedLane
end

-- Функция поведения на линии (0-5 минут)
function LaningBehavior()
    local lane = GetAssignedLane()
    local laneFront = GetLaneFrontLocation(GetTeam(), lane, 0)
    
    -- Ищем вражеских крипов для добивания
    local enemyCreeps = bot:GetNearbyCreeps(1200, true)
    local targetCreep = nil
    
    for _, creep in pairs(enemyCreeps) do
        if creep:GetHealth() <= bot:GetAttackDamage() * 2 then
            targetCreep = creep
            break
        end
    end
    
    if targetCreep then
        bot:Action_AttackUnit(targetCreep, false)
    else
        -- Движение к линии фронта
        if GetUnitToLocationDistance(bot, laneFront) > 200 then
            bot:Action_MoveToLocation(laneFront)
        end
    end
end

-- Функция поведения в лесу (5-10 минут)
function JungleBehavior()
    local nearbyNeutrals = bot:GetNearbyNeutralCreeps(1200)
    
    if #nearbyNeutrals > 0 then
        -- Атакуем ближайшего нейтрального крипа
        local target = nearbyNeutrals[1]
        bot:Action_AttackUnit(target, false)
    else
        -- Ищем ближайший лагерь нейтралов
        local neutralCamps = {}
        
        -- Координаты основных лагерей нейтралов (примерные)
        if GetTeam() == TEAM_RADIANT then
            neutralCamps = {
                Vector(-400, -400, 0),   -- Малый лагерь
                Vector(400, -1200, 0),   -- Средний лагерь
                Vector(-1200, -3000, 0), -- Сложный лагерь
                Vector(3000, -400, 0),   -- Лагерь древних
            }
        else
            neutralCamps = {
                Vector(400, 400, 0),     -- Малый лагерь
                Vector(-400, 1200, 0),   -- Средний лагерь
                Vector(1200, 3000, 0),   -- Сложный лагерь
                Vector(-3000, 400, 0),   -- Лагерь древних
            }
        end
        
        -- Идем к ближайшему лагерю
        local closestCamp = nil
        local closestDistance = math.huge
        
        for _, camp in pairs(neutralCamps) do
            local distance = GetUnitToLocationDistance(bot, camp)
            if distance < closestDistance then
                closestDistance = distance
                closestCamp = camp
            end
        end
        
        if closestCamp then
            bot:Action_MoveToLocation(closestCamp)
        end
    end
end

-- Функция группового поведения (после 10 минут)
function GroupPushBehavior()
    local hardLane = nil
    
    -- Определяем сложную линию (обычно верхняя для Radiant, нижняя для Dire)
    if GetTeam() == TEAM_RADIANT then
        hardLane = LANE_TOP
    else
        hardLane = LANE_BOT
    end
    
    local laneFront = GetLaneFrontLocation(GetTeam(), hardLane, 0)
    local towers = bot:GetNearbyTowers(1200, true)
    local enemyCreeps = bot:GetNearbyCreeps(1200, true)
    
    -- Приоритет: сначала крипы, потом башни
    if #enemyCreeps > 0 then
        local targetCreep = enemyCreeps[1]
        bot:Action_AttackUnit(targetCreep, false)
    elseif #towers > 0 then
        local targetTower = towers[1]
        bot:Action_AttackUnit(targetTower, false)
    else
        -- Движение к линии фронта
        if GetUnitToLocationDistance(bot, laneFront) > 200 then
            bot:Action_MoveToLocation(laneFront)
        end
    end
end

-- Основная функция думания бота
function Think()
    -- Проверяем здоровье
    if IsLowHealth() then
        ReturnToBase()
        return
    end
    
    -- Пытаемся купить предметы
    PurchaseItems()
    
    -- Определяем текущую фазу
    currentPhase = GetCurrentPhase()
    
    -- Выполняем поведение в зависимости от фазы
    if currentPhase == PHASE_LANING then
        LaningBehavior()
    elseif currentPhase == PHASE_JUNGLE then
        JungleBehavior()
    elseif currentPhase == PHASE_GROUP_PUSH then
        GroupPushBehavior()
    end
end

-- Функция получения желания использовать способность
function GetDesire()
    return Think()
end