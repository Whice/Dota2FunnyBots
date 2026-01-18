-- AdditionalFunctions/CourierManager.lua
-- Модуль для управления курьером с интервалом вызова
local SimpleActions = require(GetScriptDirectory().."/AdditionalFunctions/SimpleActions")


local CourierManager = {}

-- Константы
CourierManager.CALL_INTERVAL = 2.0  -- Интервал между вызовами (секунды)
CourierManager.lastCallTime = {}    -- Время последнего вызова для каждого бота

-------------------------------------------------------------------------------
-- Проверяет, есть ли предметы в сташе для доставки
-- @param bot - handle бота
-- @return true если есть предметы для доставки
-------------------------------------------------------------------------------
function CourierManager.HasItemsToDeliver(bot)
    if not bot then return false end
    
    -- Проверяем слоты сташа (9-14)
    for slot = 9, 14 do
        local item = bot:GetItemInSlot(slot)
        if item then
            return true
        end
    end
    
    -- Также проверяем, есть ли предметы у курьера
    local team = bot:GetTeam()
    local courier = GetCourier(bot:GetPlayerID())
    
    if courier then
        -- Проверяем слоты курьера (0-5 - инвентарь, 6-8 - рюкзак)
        for slot = 0, 8 do
            local item = courier:GetItemInSlot(slot)
            if item then
                return true
            end
        end
    end
    
    return false
end
-------------------------------------------------------------------------------
-- Проверяет, доступен ли курьер для команд
-- @param bot - handle бота
-- @return true если курьер доступен
-------------------------------------------------------------------------------
function CourierManager.IsCourierAvailableForCommand(bot)
    --Это не нужно, т.к. в нынешней версии игры он всегда есть у каждого игрока.
    --if not IsCourierAvailable() then        return false    end
    local team = bot:GetTeam()
    local courier = GetCourier(bot:GetPlayerID())
    
    if not courier then
        return false
    end
    
    local state = GetCourierState(courier)
    SimpleActions.SayAction(bot, "Курьер доступен для использования "..state)
    
    -- Курьер доступен для команд, если он в состоянии IDLE, AT_BASE или RETURNING_TO_BASE
    if state == COURIER_STATE_IDLE or
       state == COURIER_STATE_AT_BASE or
       state == COURIER_STATE_RETURNING_TO_BASE then
        return true
    end
    
    return false
end
function CourierManager.IsCourierBusy(bot)
    return not CourierManager.IsCourierAvailableForCommand(bot)
end

-------------------------------------------------------------------------------
-- Основная функция: отправляет курьера с предметами к боту
-- @param bot - handle бота
-- @return true если команда отправлена, false если курьер недоступен или прошло мало времени
-------------------------------------------------------------------------------
function CourierManager.SendCourierToBot(bot)
    if not bot then
        return false
    end
    
    local playerID = bot:GetPlayerID()
    local currentTime = DotaTime()
    
    -- Проверяем интервал между вызовами
    if CourierManager.lastCallTime[playerID] then
        if currentTime < CourierManager.lastCallTime[playerID] + CourierManager.CALL_INTERVAL then
            return false
        end
    end
    
    -- Обновляем время вызова
    CourierManager.lastCallTime[playerID] = currentTime
    
    -- Проверяем, есть ли предметы для доставки
    if not CourierManager.HasItemsToDeliver(bot) then
        return false
    end
    
    -- Проверяем доступность курьера
    if not CourierManager.IsCourierAvailableForCommand(bot) then
        return false
    end
    
    local team = bot:GetTeam()
    local courier = GetCourier(bot:GetPlayerID())
    
    if not courier then
        return false
    end
    
    -- Отправляем курьера с предметами к боту
    bot:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS)
    
    SimpleActions.SayAction(bot, "Вызываю курьера с предметами")
    return true
end

-------------------------------------------------------------------------------
-- Проверяет состояние курьера (вспомогательная функция)
-- @param bot - handle бота
-- @return строковое описание состояния курьера
-------------------------------------------------------------------------------
function CourierManager.GetCourierStatus(bot)
    
    local team = bot:GetTeam()
    local courier = GetCourier(bot:GetPlayerID())
    
    if not courier then
        return "Курьер не найден"
    end
    
    local state = GetCourierState(courier)
    local stateNames = {
        [COURIER_STATE_IDLE] = "Бездействует",
        [COURIER_STATE_AT_BASE] = "На базе",
        [COURIER_STATE_MOVING] = "В движении",
        [COURIER_STATE_DELIVERING_ITEMS] = "Доставляет предметы",
        [COURIER_STATE_RETURNING_TO_BASE] = "Возвращается на базу",
        [COURIER_STATE_DEAD] = "Мёртв"
    }
    
    return stateNames[state] or "Неизвестное состояние (" .. tostring(state) .. ")"
end

-------------------------------------------------------------------------------
-- Сбрасывает таймер для конкретного бота
-- @param bot - handle бота
-------------------------------------------------------------------------------
function CourierManager.ResetTimer(bot)
    if not bot then return end
    
    local playerID = bot:GetPlayerID()
    CourierManager.lastCallTime[playerID] = nil
end

-------------------------------------------------------------------------------
-- Сбрасывает все таймеры
-------------------------------------------------------------------------------
function CourierManager.ResetAllTimers()
    CourierManager.lastCallTime = {}
end

return CourierManager