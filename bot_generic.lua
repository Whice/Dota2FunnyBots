local bot_behavior = {}

function bot_behavior.Think()
    local bot = GetBot()
    local time = DotaTime()
    local health_pct = bot:GetHealth() / bot:GetMaxHealth()
    
    -- Режим отступления при низком здоровье
    if health_pct < 0.2 then
        return mode_retreat_custom.OnStart()
    end
    
    -- Фазы игры
    if time < 300 then          -- До 5 минут
        return mode_laning_custom.OnStart()
    elseif time < 600 then      -- 5-10 минут
        return mode_jungle_custom.OnStart()
    else                        -- После 10 минут
        return mode_push_custom.OnStart()
    end
end

return bot_behavior