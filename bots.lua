-- bots.lua
local bot = GetBot()  -- Текущий бот
local lane_assigned = false  -- Назначена ли линия
local target_lane = LANE_NONE  -- Целевая линия
local farm_location = nil  -- Позиция для фарма

-- Определяем линию для бота по его слоту
function AssignLane()
    local team = bot:GetTeam()
    local slots = { -- Распределение слотов по линиям
        [1] = LANE_TOP,
        [2] = LANE_MID,
        [3] = LANE_BOT,
        [4] = LANE_TOP,
        [5] = LANE_BOT
    }
    
    -- Проверяем, не занята ли линия другими ботами
    local allies = GetTeamPlayers(team)
    for i,slot in pairs(slots) do
        if bot:GetPlayerID() == allies[i] then
            target_lane = slot
            return
        end
    end
end

-- Основная логика бота
function Think()
    if not lane_assigned then
        AssignLane()
        lane_assigned = true
    end

    -- Получаем позицию фарма на линии
    if farm_location == nil then
        farm_location = GetLaneFrontLocation(bot:GetTeam(), target_lane, 0)
    end

    -- Если крипы появились, двигаемся к точке фарма
    if GetGameTime() > 0 then
        -- Поиск крипов вокруг
        local creeps = bot:GetNearbyCreeps(1000, true)
        
        if #creeps > 0 then  -- Если есть крипы - атаковать
            bot:Action_AttackUnit(creeps[1], false)
        else  -- Если крипов нет - двигаться к точке
            bot:Action_MoveToLocation(farm_location)
        end
    else  -- До начала игры - стоять на базе
        bot:Action_MoveToLocation(GetAncient(team):GetLocation())
    end
end

-- Возвращаем назначенную линию (для системы)
function GetDesireToLane()
    return target_lane
end