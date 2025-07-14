local retreat_mode = dofile(GetScriptDirectory().."/mode_retreat_custom")
local laning_mode = dofile(GetScriptDirectory().."/mode_laning_custom")
local jungle_mode = dofile(GetScriptDirectory().."/mode_jungle_custom")
local push_mode = dofile(GetScriptDirectory().."/mode_push_custom")

local current_mode = "laning"
local last_switch_time = 0
local MIN_SWITCH_TIME = 5.0 -- Минимальное время между сменами режима

function Think()
    local bot = GetBot()
    if not bot:IsAlive() then return end -- Не действуем, если бот мертв
    
    local time = DotaTime()
    local health_pct = bot:GetHealth() / bot:GetMaxHealth()
    
    -- Приоритетный режим отступления
    if health_pct < 0.2 and time - last_switch_time > MIN_SWITCH_TIME then
        if current_mode ~= "retreat" then
            retreat_mode.OnStart()
            current_mode = "retreat"
            last_switch_time = time
        end
        retreat_mode.Think()
        return
    end
    
    -- Основные режимы по времени игры
    if time - last_switch_time > MIN_SWITCH_TIME then
        if time < 300 then -- 0-5 минут
            if current_mode ~= "laning" then
                laning_mode.OnStart()
                current_mode = "laning"
                last_switch_time = time
            end
        elseif time < 600 then -- 5-10 минут
            if current_mode ~= "jungle" then
                jungle_mode.OnStart()
                current_mode = "jungle"
                last_switch_time = time
            end
        else -- после 10 минут
            if current_mode ~= "push" then
                push_mode.OnStart()
                current_mode = "push"
                last_switch_time = time
            end
        end
    end
    
    -- Выполнение текущего режима
    if current_mode == "laning" then
        laning_mode.Think()
    elseif current_mode == "jungle" then
        jungle_mode.Think()
    elseif current_mode == "push" then
        push_mode.Think()
    end
end