logic = {}

function FindItem(itemName)
    local bot = GetBot()
    -- Проверяем все слоты инвентаря на наличие TP Scroll
    for i = 0, 15 do
        local item = bot:GetItemInSlot(i)
        if item and item:GetName() == itemName then
            return item
        end
    end
    return nil
end
function GetAssignedLaneNumber()
    local bot = GetBot()
    local assignedLane = bot:GetAssignedLane()
    if assignedLane == LANE_TOP then
        return 0
    elseif assignedLane == LANE_MID then
        return 1
    elseif assignedLane == LANE_BOT then
        return 2
    else
        print("Error: Invalid lane assigned to bot")
        return 0
    end
end
function GetFirstTower()
    local tower = nil
    local towerNumber = 0
    while tower == nil do
        local laneNumber = GetAssignedLaneNumber() - 1
        tower = GetTower(GetTeam(), laneNumber * 3 + towerNumber)
        towerNumber = towerNumber + 1
    end
    return tower
end
-- Функция для определения координат базы
local function getBaseLocation(team)
    if team == TEAM_RADIANT then
        return Vector(-7000, -6500, 0) -- Координаты базы Radiant
    else
        return Vector(7000, 6500, 0) -- Координаты базы Dire
    end
end

-- Функция для движения бота к базе
function MoveToBase(bot)
    local baseLocation = getBaseLocation(bot:GetTeam())
    bot:Action_MoveToLocation(baseLocation)
end
-- Функция для перемещения бота к своей башне
function MoveToTower()
    local bot = GetBot()

    local tower = GetFirstTower()
    if tower then
        local tpScroll = FindItem("item_tpscroll")
        if tpScroll and tpScroll:IsFullyCastable() then
            -- Использовать телепорт, если он доступен
            bot:Action_UseAbilityOnLocation(tpScroll, tower:GetLocation())
        else
            -- Перемещаться к башне, если телепорт недоступен
            bot:Action_MoveToLocation(tower:GetLocation())
        end
    end
end
-- Функция для перемещения бота вперед по линии
function MoveForwardOnLane()
    local bot = GetBot()
    local laneNumber = GetAssignedLaneNumber()
    -- Получаем точку на передней линии для текущей линии бота
    -- local frontLocation = GetLaneFrontLocation(bot:GetTeam(), laneNumber, 0) -- 0 для передней линии
    local frontLocation = GetLaneFrontLocation(bot:GetTeam(), laneNumber, 200)
    local frontLocationDistance = (frontLocation - bot:GetLocation()):Length2D()
    if frontLocationDistance > 3000000 then
        MoveToTower()
    elseif frontLocation then
        -- Перемещаемся к точке на передней линии
        bot:Action_MoveToLocation(frontLocation)
        bot:ActionImmediate_Chat("Иду на линию!", true)
    else
        print("Error: Failed to get lane front location")
    end
end

-- Функция для поиска крипа с наименьшим здоровьем
function GetWeakestCreep(laneCreeps)
    local weakestCreep = nil
    local lowestHealth = 100000 -- Большое начальное значение
    for _, creep in pairs(laneCreeps) do
        local health = creep:GetHealth()
        if health < lowestHealth then
            weakestCreep = creep
            lowestHealth = health
        end
    end

    return weakestCreep
end

local botsAttackState ={}
-- Функция для фарма на линии
function FarmLane(dotaTime)
    local bot = GetBot()

    if dotaTime < 0 then
        return
    end

    local searchRadius = 700
    local laneCreeps = bot:GetNearbyLaneCreeps(searchRadius, true)
    if laneCreeps == nil or #laneCreeps < 1 then
        MoveForwardOnLane()
    elseif laneCreeps ~= nil then
        local botDamage = bot:GetAttackDamage()
        local targetCreep = GetWeakestCreep(laneCreeps)

        if targetCreep ~= nil then
            local creepHealth = targetCreep:GetHealth()
            local creepHalfMaxHealth = targetCreep:GetMaxHealth() / 2
            local distanceToCreep = GetUnitToUnitDistance(bot, targetCreep)

            -- Если здоровье крипа меньше, чем на 1 атаку бота, атаковать его
            if false and creepHealth <= botDamage then
                bot:Action_AttackUnit(targetCreep, true)
                -- Если здоровье крипа меньше, чем на 2 атаки бота, приближаться к нему
            elseif false and creepHealth <= creepHalfMaxHealth and distanceToCreep > bot:GetAttackRange() then
                bot:Action_MoveToUnit(targetCreep)
                bot:ActionImmediate_Chat("Хочу атаковать!", true)
            else
                bot:ActionImmediate_Chat("Смещаюсь назад!", true)
                local backLocation = GetLaneFrontLocation(bot:GetTeam(), laneNumber, 200)
                --MoveToBase(bot)
                bot:Action_MoveToLocation(Vector(0, 0, 0))
                if backLocation then
                    -- Перемещаемся к точке на передней линии
                    --bot:Action_MoveToLocation(backLocation)
                else
                    local randomX = bot:GetLocation().x + math.random(-20, 20)
                    local randomY = bot:GetLocation().y + math.random(-20, 20)
                    bot:Action_MoveToLocation(Vector(randomX, randomY, 0))
                end
                -- Перемещаться в случайные позиции в небольшом радиусе

            end
        else
            Warning(" targetCreep == nil !")
        end
    end
end

return logic
