[file name]: bot_generic.lua
[file content begin]
--[[
    Исправления:
    1. Улучшена проверка атакующих целей
    2. Добавлена проверка существования древнего
    3. Исправлена инициализация safe_position
    4. Добавлены константы для магических чисел
]]

-- Глобальные константы
local RETREAT_DISTANCE = 1000
local HEAL_THRESHOLD = 0.5
local FOUNTAIN_SAFE_DISTANCE = 2000
local TOWER_AGRO_RANGE = 800  -- Примерный радиус агрессии башен

-- Обновлённая функция проверки атак
function IsUnderAttack()
    local current_time = DotaTime()
    
    -- 1. Проверка атакующих крипов
    local creeps = bot:GetNearbyCreeps(RETREAT_DISTANCE, true)
    for _, creep in pairs(creeps) do
        if creep:GetAttackTarget() == bot and (current_time - creep:GetLastAttackTime()) < creep:GetAttackPoint() + 0.1 then
            return true
        end
    end
    
    -- 2. Проверка атакующих героев
    local heroes = bot:GetNearbyHeroes(RETREAT_DISTANCE, true, BOT_MODE_NONE)
    for _, hero in pairs(heroes) do
        local ability = hero:GetCurrentActiveAbility()
        if hero:GetAttackTarget() == bot or (ability and ability:GetTarget() == bot) then
            return true
        end
    end
    
    -- 3. Проверка атакующих башен
    local towers = bot:GetNearbyTowers(TOWER_AGRO_RANGE, true)
    for _, tower in pairs(towers) do
        if tower:GetAttackTarget() == bot then
            return true
        end
    end
    
    return false
end

-- Обновлённая функция отступления
local function RetreatLogic()
    if not safe_position then
        -- Инициализация safe_position при первом вызове
        local offset = TEAM == TEAM_RADIANT and -800 or 800
        safe_position = GetLaneFrontLocation(GetTeam(), GetLane(), offset)
    end

    local ancient = GetAncient(GetTeam())
    local retreat_point = GetLaneFrontLocation(GetTeam(), GetLane(), -800)
    
    if GetUnitToLocationDistance(bot, retreat_point) < 300 and ancient and not ancient:IsNull() then
        retreat_point = ancient:GetLocation()
    end
    
    bot:Action_MoveToLocation(retreat_point)
    bot:ActionImmediate_Chat("Отступаю к базе!", false)
end

-- Обновлённая таблица состояний
local states = {
    RETREAT = {
        priority = 100,
        check = function()
            return IsUnderAttack() or bot:WasRecentlyDamagedByAnyHero(2.0)
        end,
        execute = RetreatLogic
    },
    
    HEAL = {
        priority = 90,
        check = function()
            return bot:GetHealth()/bot:GetMaxHealth() < HEAL_THRESHOLD 
                   and not IsUnderAttack()
                   and bot:DistanceFromFountain() > FOUNTAIN_SAFE_DISTANCE
        end,
        execute = function()
            -- Добавить вызов функции лечения
            bot:Action_MoveToLocation(GetAncient(GetTeam()):GetLocation())
        end
    },
    
    FARM = {
        priority = 80,
        check = function() return true end,
        execute = function()
            -- Базовая логика фарма
            local creep = bot:GetNearbyCreeps(1200, false)[1]
            if creep then
                bot:Action_AttackUnit(creep, false)
            end
        end
    }
}

-- Инициализация безопасной позиции
local function InitSafePosition()
    local offset = TEAM == TEAM_RADIANT and -800 or 800
    safe_position = GetLaneFrontLocation(GetTeam(), GetLane(), offset)
end

-- Важные изменения:
-- 1. Добавлена явная инициализация safe_position
-- 2. Исправлена работа с командой и линией через GetTeam()/GetLane()
-- 3. Добавлена проверка на существование древнего
-- 4. Реализована базовая логика фарма
[file content end]