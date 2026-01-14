-- AdditionalFunctions/TeleportHelper.lua
local TeleportHelper = {}

-- Импортируем необходимые модули
local SimpleActions = require(GetScriptDirectory().."/AdditionalFunctions/SimpleActions")
local TowersHelper = require(GetScriptDirectory().."/AdditionalFunctions/TowersHelper")

-- Константы для телепортации
TeleportHelper.TELEPORT_CHECK_INTERVAL = 1.0
TeleportHelper.TELEPORT_ACTION_DELAY = 3.0

-- Пытается телепортироваться на линию
function TeleportHelper.TryTeleportToLane(npcBot, lane_assigned, target_lane, last_teleport_check, last_teleport_action_time)
    
    -- Проверяем интервал между проверками
    if DotaTime() < last_teleport_check + TeleportHelper.TELEPORT_CHECK_INTERVAL then
        return false, last_teleport_check, last_teleport_action_time
    end
    last_teleport_check = DotaTime()
    
    -- Проверяем, не выполняем ли уже действие телепорта
    if DotaTime() < last_teleport_action_time + TeleportHelper.TELEPORT_ACTION_DELAY then
        return false, last_teleport_check, last_teleport_action_time
    end
    
    -- Основные проверки
    if not npcBot:IsAlive() then
        return false, last_teleport_check, last_teleport_action_time
    end
    
    if not lane_assigned or target_lane == LANE_NONE then
        return false, last_teleport_check, last_teleport_action_time
    end
    
    -- Получаем самую дальнюю живую башню на линии (ближайшую к линии фронта)
    local outer_tower = TowersHelper.GetFirstAvailableAllyTowerForLane(npcBot, target_lane)
    if not outer_tower then
        return false, last_teleport_check, last_teleport_action_time  -- Нет живых башен на линии
    end
    
    -- Проверяем расстояние до башни
    local distance_to_tower = GetUnitToUnitDistance(npcBot, outer_tower)
    if distance_to_tower <= 3000 then
        return false, last_teleport_check, last_teleport_action_time  -- Слишком близко к башне, телепорт не нужен
    end
    
    -- Проверяем наличие готового телепорта
    if not SimpleActions.IsTeleportReady(npcBot) then
        -- Если телепорт не готов, пытаемся купить
        SimpleActions.TryBuyTeleports(npcBot)
        return false, last_teleport_check, last_teleport_action_time
    end
    
    -- Используем переданную башню для телепорта
    local teleport_target = outer_tower:GetLocation()
    
    -- Ищем предмет телепорта
    local teleport_item = TeleportHelper.GetTeleportItem(npcBot)
    if not teleport_item then
        return false, last_teleport_check, last_teleport_action_time
    end
    
    -- Проверяем, можно ли использовать телепорт
    if not teleport_item:IsFullyCastable() then
        return false, last_teleport_check, last_teleport_action_time
    end
    
    -- Используем телепорт
    npcBot:Action_UseAbilityOnLocation(teleport_item, teleport_target)
    SimpleActions.SayAction(npcBot, "Телепортуюсь на линию!")
    last_teleport_action_time = DotaTime()
    return true, last_teleport_check, last_teleport_action_time
end

-- Ищет цель для телепорта на линии
function TeleportHelper.FindTeleportTarget(npcBot, target_lane)
    local team = npcBot:GetTeam()
    
    -- Используем TowersHelper для получения доступной башни на целевой линии
    local tower = TowersHelper.GetFirstAvailableAllyTowerForLane(npcBot, target_lane)
    if tower and tower:IsAlive() and not tower:IsInvulnerable() then
        return tower:GetLocation()
    end
    
    -- Если нет башни, ищем союзные крипы на линии
    local creeps = npcBot:GetNearbyCreeps(6000, false)  -- Союзные крипы в радиусе 6000
    for _, creep in ipairs(creeps) do
        if creep and creep:IsAlive() and creep:IsCreep() and not creep:IsAncientCreep() then
            local creep_loc = creep:GetLocation()
            local lane_front = GetLaneFrontLocation(team, target_lane, 0)
            
            if lane_front then
                local distance = GetUnitToLocationDistance(creep, lane_front)
                if distance < 1500 then  -- Крип считается на линии, если ближе 1500 единиц
                    return creep:GetLocation()
                end
            end
        end
    end
    
    -- Если ничего не нашли, пытаемся получить точку на линии позади фронта
    local lane_location = GetLaneFrontLocation(team, target_lane, -500)  -- Немного позади линии фронта
    if lane_location then
        return lane_location
    end
    
    return nil
end

-- Возвращает предмет телепорта
function TeleportHelper.GetTeleportItem(npcBot)
    -- Проверяем специальный слот для телепорта (обычно 15)
    local teleport_slot = npcBot:GetItemInSlot(15)
    if teleport_slot and teleport_slot:GetName() == "item_tpscroll" then
        return teleport_slot
    end
    
    return nil
end

-- Определяет тип доступного телепорта (добавьте эту функцию в TeleportHelper)
function TeleportHelper.GetTeleportType(bot)
    if not bot then
        return "none"
    end
    
    -- Проверяем наличие и готовность телепорта
    local teleportItem = TeleportHelper.GetTeleportItem(bot)
    if not teleportItem or not teleportItem:IsFullyCastable() then
        return "none"
    end
    
    -- Проверяем тип телепорта по имени предмета
    local itemName = teleportItem:GetName()
    
    if itemName == "item_tpscroll" then
        return "scroll"  -- Обычный свиток телепорта
    elseif itemName == "item_travel_boots" then
        return "boots_1" -- Ботинки путешествий 1 уровня
    elseif itemName == "item_travel_boots_2" then
        return "boots_2" -- Ботинки путешествий 2 уровня
    end
    
    return "none"
end

return TeleportHelper