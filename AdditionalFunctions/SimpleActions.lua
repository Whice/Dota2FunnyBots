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

return SimpleActions