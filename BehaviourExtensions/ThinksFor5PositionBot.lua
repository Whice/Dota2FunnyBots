local hasMovedToCamp = false
local hasAttackedNeutral = false

local easyNeutralCamps = {
    Vector(-2600, -1500, 0), -- Легкий лагерь у Radiant
    Vector(3500, 500, 0),    -- Легкий лагерь у Dire
}

function ThinkPos5(bot, heroName)
    --print(heroName .. " думает на позиции 5 (хард саппорт)")
    local gameTime = DotaTime()

    -- Если бот еще не отправился к лагерю, планируем движение
    if not hasMovedToCamp then
        MoveToEasyCamp(bot)
    elseif not hasAttackedNeutral and gameTime % 60 >= 55 then
        AttackNeutral(bot)
    elseif hasAttackedNeutral then
        RetreatToLane(bot)
    end
end

-- Найти ближайший легкий лагерь к башне
function FindClosestEasyCampToTower(bot)
    local botTeam = bot:GetTeam()
    local tower = GetTower(botTeam, TOWER_MID_1) -- Используем ближайшую к линии башню
    local towerLocation = tower:GetLocation()
    local closestCamp = nil
    local minDistance = math.huge

    for _, campLocation in ipairs(easyNeutralCamps) do
        local distance = GetUnitToLocationDistance(tower, campLocation)
        if distance < minDistance then
            minDistance = distance
            closestCamp = campLocation
        end
    end

    return closestCamp
end

-- Перемещение к ближайшему лагерю
function 
    MoveToEasyCamp(bot)
    local campLocation = FindClosestEasyCampToTower(bot)
    local travelTime = GetUnitToLocationDistance(bot, campLocation) / bot:GetCurrentMovementSpeed()
    local gameTime = DotaTime()

    -- Проверяем, достаточно ли времени, чтобы добраться к лагерю к 52-54 секунде
    local targetTime = math.floor(gameTime / 60) * 60 + 52
    if targetTime - gameTime > travelTime then
        bot:Action_MoveToLocation(campLocation)
        hasMovedToCamp = true
        bot:ActionImmediate_Chat("I will move to stack easy camp!", false)
    end
end

-- Атака нейтрала
function AttackNeutral(bot)
    local nearbyCreeps = bot:GetNearbyNeutralCreeps(500)

    if #nearbyCreeps > 0 then
        bot:Action_AttackUnit(nearbyCreeps[1], true)
        hasAttackedNeutral = true
        bot:ActionImmediate_Chat("I now stack easy camp!", false)
    end
end

-- Отступление на линию
function RetreatToLane(bot)
    local lane = LANE_BOT -- Используем линию
    local retreatPosition = GetLaneFrontLocation(bot:GetTeam(), lane, 0) -- Горизонтальная точка линии
    retreatPosition.y = retreatPosition.y + 200 -- Смещаем бот горизонтально
    bot:Action_MoveToLocation(retreatPosition)
    bot:ActionImmediate_Chat("I  return to easy line!", false)
end
