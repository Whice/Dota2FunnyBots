-- AdditionalFunctions/MovingHelper.lua
local MovingHelper = {}

-- Импортируем необходимые модули
local TeleportHelper = require(GetScriptDirectory().."/AdditionalFunctions/TeleportHelper")
local SimpleActions = require(GetScriptDirectory().."/AdditionalFunctions/SimpleActions")
local TowersHelper = require(GetScriptDirectory().."/AdditionalFunctions/TowersHelper")

-- Таблица для хранения последних целей ботов
MovingHelper.lastTargetPositions = {}

-- Константы
MovingHelper.TELEPORT_TIME_BONUS = 20  -- секунд, если телепорт экономит больше этого времени, то используем
MovingHelper.TELEPORT_CAST_TIME = 2    -- секунд, время каста телепорта
MovingHelper.POSITION_TOLERANCE = 100  -- единиц, погрешность для сравнения позиций
MovingHelper.DISTANCE_TOLERANCE = 1.1  -- коэффициент для учета, что путь не прямой.


-- Находит ближайшую допустимую точку для телепортации
function MovingHelper.FindTeleportDestination(bot, targetPosition, teleportType)
    if teleportType == "none" then
        return nil
    end
    
    local team = bot:GetTeam()
    local bestTarget = nil
    local bestDistance = 99999
    
    -- Для всех типов телепортов: союзные здания
    local buildings = {}
    
    -- Добавляем башни
    for lane = LANE_TOP, LANE_BOT do
        for i = 0, 2 do
            local tower = TowersHelper.GetAllyTowerForLane(bot, lane, i)
            if tower and tower:IsAlive() then
                table.insert(buildings, tower)
            end
        end
    end
    
    -- Добавляем бараки
    for i = 0, 5 do
        local barracks = GetBarracks(team, i)
        if barracks and barracks:IsAlive() then
            table.insert(buildings, barracks)
        end
    end
    
    -- Добавляем древнее
    local ancient = GetAncient(team)
    if ancient and ancient:IsAlive() then
        table.insert(buildings, ancient)
    end
    
    -- Проверяем здания
    for _, building in ipairs(buildings) do
        local buildingPos = building:GetLocation()
        local distance = GetUnitToLocationDistance(building, targetPosition)
        
        if distance < bestDistance then
            bestDistance = distance
            bestTarget = buildingPos
        end
    end
    
    -- Для boots_1 и boots_2: союзные герои
    if teleportType == "boots_1" or teleportType == "boots_2" then
        local teamPlayers = GetTeamPlayers(team)
        
        for _, playerID in ipairs(teamPlayers) do
            local hero = GetTeamMember(playerID)
            if hero and hero:IsAlive() and hero:CanBeSeen() then
                local heroPos = hero:GetLocation()
                local distance = GetUnitToLocationDistance(hero, targetPosition)
                
                if distance < bestDistance then
                    bestDistance = distance
                    bestTarget = heroPos
                end
            end
        end
    end
    
    -- Для boots_2 и scroll: союзные крипы (в зоне видимости)
    if teleportType == "boots_2" or teleportType == "scroll" then
        local creeps = bot:GetNearbyCreeps(2000, false) -- Союзные крипы в радиусе 2000
        
        for _, creep in ipairs(creeps) do
            if creep and creep:IsAlive() and creep:CanBeSeen() then
                local creepPos = creep:GetLocation()
                local distance = GetUnitToLocationDistance(creep, targetPosition)
                
                if distance < bestDistance then
                    bestDistance = distance
                    bestTarget = creepPos
                end
            end
        end
    end
    
    return bestTarget, bestDistance
end

-- Оценивает время движения пешком до позиции
function MovingHelper.EstimateWalkingTime(bot, targetPosition)
    if not bot or not targetPosition then
        return 99999
    end
    
    local distance = GetUnitToLocationDistance(bot, targetPosition)
    local speed = bot:GetCurrentMovementSpeed()
    
    if speed <= 0 then
        speed = 300 -- минимальная скорость
    end
    
    -- Учитываем время на повороты и небольшие задержки
    local walkingTime = distance / speed
    
    -- Добавляем коэффициент на неровности пути
    return walkingTime * MovingHelper.DISTANCE_TOLERANCE
end

-- Оценивает, стоит ли использовать телепорт
function MovingHelper.ShouldUseTeleport(bot, targetPosition)
    -- Проверяем наличие и готовность телепорта
    if not SimpleActions.IsTeleportReady(bot) then
        return false, nil
    end

    -- Определяем тип телепорта
    local teleportType = TeleportHelper.GetTeleportType(bot)
    if teleportType == "none" then
        return false, nil
    end

    -- Оцениваем время пути пешком
    local walkTime = MovingHelper.EstimateWalkingTime(bot, targetPosition)

    -- Находим ближайшую точку телепортации
    local teleportTarget, distanceAfterTeleport = MovingHelper.FindTeleportDestination(bot, targetPosition, teleportType)
    if not teleportTarget then
        return false, nil
    end

    -- Оцениваем время после телепорта
    local teleportTime = MovingHelper.TELEPORT_CAST_TIME -- время каста телепорта

    -- Предполагаем, что после телепорта мы будем на расстоянии distanceAfterTeleport от цели
    local walkTimeAfterTeleport = distanceAfterTeleport / bot:GetCurrentMovementSpeed()
    walkTimeAfterTeleport = walkTimeAfterTeleport * MovingHelper.DISTANCE_TOLERANCE

    -- Общее время с телепортом
    local totalTeleportTime = teleportTime + walkTimeAfterTeleport

    -- Логируем расчеты
    -- SimpleActions.SayAction(bot, string.format(
    --     "Рассчет телепорта: пешком %.1fсек, телепорт %.1fсек (каст %.1fсек + путь %.1fсек)",
    --     walkTime, totalTeleportTime, teleportTime, walkTimeAfterTeleport
    -- ))

    -- Сравниваем времена
    if walkTime > (totalTeleportTime + MovingHelper.TELEPORT_TIME_BONUS) then
        -- Телепорт экономит больше 20 секунд
        -- SimpleActions.SayAction(bot, string.format(
        --     "Использую телепорт! Экономия: пешком %.1fсек, телепорт %.1fсек",
        --     walkTime, totalTeleportTime
        -- ))
        return true, teleportTarget
    else
        -- SimpleActions.SayAction(bot, string.format(
        --     "Иду пешком: быстрее на %.1fсек (пешком %.1fсек, телепорт %.1fсек)",
        --     totalTeleportTime - (walkTime + MovingHelper.TELEPORT_TIME_BONUS),
        --     walkTime, totalTeleportTime
        -- ))
    end

    return false, nil
end

-- Основная функция: перемещает бота к позиции с учетом телепорта
function MovingHelper.MoveToPosition(bot, targetPosition)
    if not bot or not targetPosition then
        return
    end
    
    -- Проверяем, изменилась ли цель
    local lastTarget = MovingHelper.lastTargetPositions[bot:GetPlayerID()]
    if lastTarget then
        local dx = math.abs(lastTarget.x - targetPosition.x)
        local dy = math.abs(lastTarget.y - targetPosition.y)
        
        if dx < MovingHelper.POSITION_TOLERANCE and dy < MovingHelper.POSITION_TOLERANCE then
            -- Позиция не изменилась, ничего не делаем
            return
        end
    end
    
    -- Сохраняем новую позицию
    MovingHelper.lastTargetPositions[bot:GetPlayerID()] = targetPosition
    
    -- Проверяем, стоит ли использовать телепорт
    local useTeleport, teleportTarget = MovingHelper.ShouldUseTeleport(bot, targetPosition)
    
    if useTeleport and teleportTarget then
        -- Используем телепорт
        local teleportItem = TeleportHelper.GetTeleportItem(bot)
        if teleportItem then
            bot:Action_UseAbilityOnLocation(teleportItem, teleportTarget)
            --SimpleActions.SayAction(bot, "Использую телепорт для быстрого перемещения.")
            return
        end
    end
    
    -- Двигаемся пешком
    bot:Action_MoveToLocation(targetPosition)
end

-- Очищает историю позиций для бота (например, при смерти)
function MovingHelper.ClearBotHistory(bot)
    if bot then
        MovingHelper.lastTargetPositions[bot:GetPlayerID()] = nil
    end
end

-- Очищает всю историю (например, при перезагрузке скриптов)
function MovingHelper.ClearAllHistory()
    MovingHelper.lastTargetPositions = {}
end

return MovingHelper