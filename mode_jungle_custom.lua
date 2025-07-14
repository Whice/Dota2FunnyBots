local mode = {}
local target_camp = nil
local last_camp_check = -90

function mode.OnStart()
    print("Starting jungle mode")
    target_camp = nil
end

function mode.Think()
    local bot = GetBot()
    local time = DotaTime()
    
    -- Обновляем цель каждые 15 секунд или если текущая цель недоступна
    if target_camp == nil or time - last_camp_check > 15 then
        local camps = GetNeutralSpawners()
        local nearest_dist = 10000
        local nearest_camp = nil
        
        for _, camp in pairs(camps) do
            local camp_type = camp[1]
            -- Только дружественные лагеря (не вражеские)
            if not string.find(camp_type, "enemy") then
                local camp_loc = camp[2]
                local dist = GetUnitToLocationDistance(bot, camp_loc)
                if dist < nearest_dist then
                    nearest_dist = dist
                    nearest_camp = camp_loc
                end
            end
        end
        
        target_camp = nearest_camp
        last_camp_check = time
    end
    
    if target_camp then
        -- Движение к лагерю
        if GetUnitToLocationDistance(bot, target_camp) > 600 then
            bot:Action_MoveToLocation(target_camp)
        else
            -- Атака нейтралов
            local neutrals = bot:GetNearbyNeutralCreeps(600)
            if #neutrals > 0 then
                bot:Action_AttackUnit(neutrals[1], false)
            else
                -- Если крипов нет, ждем или ищем новый лагерь
                if time - last_camp_check > 10 then
                    target_camp = nil
                end
            end
        end
    end
end

return mode