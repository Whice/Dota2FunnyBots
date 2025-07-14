-- bot_generic.lua
-- Универсальное поведение ботов по фазам игры

function Think()
    local bot = GetBot()
    if not bot:IsAlive() then return end

    -- 1) Отступ на базу при здоровье <20%
    if bot:GetHealth() / bot:GetMaxHealth() < 0.20 then
        bot:Action_MoveToLocation(GetFountainLocation(bot:GetTeam()))
        return
    end

    local time = DotaTime()

    if time < 300 then
        -- 2) Лайнинг (0–5 мин)
        local creeps = bot:GetNearbyLaneCreeps(1200, true)
        if #creeps > 0 then
            bot:Action_AttackUnit(creeps[1], false)
        else
            bot:Action_MoveToLocation(
                GetLaneFrontLocation(bot:GetTeam(), bot:GetAssignedLane(), 0)
            )
        end

    elseif time < 600 then
        -- 3) Фарм леса (5–10 мин)
        -- Инициализация очереди лагерей при первом заходе в фазу
        if not bot.campOrder then
            local camps = GetNeutralSpawners()
            -- сортируем по расстоянию до бота
            table.sort(camps, function(a, b)
                return GetUnitToLocationDistance(bot, a[2]) < GetUnitToLocationDistance(bot, b[2])
            end)
            bot.campOrder = camps         -- [{ type, pos }, ...]
            bot.campIndex = 1
        end

        local camp = bot.campOrder[bot.campIndex]
        local campPos = camp[2]

        -- фильтруем крипов именно из этого лагеря (в радиусе 800)
        local campCreeps = {}
        for _, c in pairs(bot:GetNearbyNeutralCreeps(1200)) do
            if GetUnitToLocationDistance(c, campPos) < 800 then
                table.insert(campCreeps, c)
            end
        end

        if #campCreeps > 0 then
            -- убиваем крипа в текущем лагере
            bot:Action_AttackUnit(campCreeps[1], false)
        else
            -- лагерь пуст — переходим к следующему
            bot.campIndex = bot.campIndex + 1
            if bot.campIndex > #bot.campOrder then
                bot.campIndex = 1  -- зациклиться
            end
            -- идём к следующему лагерю
            local nextPos = bot.campOrder[bot.campIndex][2]
            bot:Action_MoveToLocation(nextPos)
        end

    else
        -- 4) Пуш оффлейна (после 10 мин)
        local team = bot:GetTeam()
        local opp = GetOpposingTeam()
        -- для Radiant оффлейн = LANE_TOP, для Dire = LANE_BOT
        local offlane = (team == TEAM_RADIANT) and LANE_TOP or LANE_BOT
        local towerType = (team == TEAM_RADIANT) and TOWER_TOP_1 or TOWER_BOT_1

        local tower = GetTower(opp, towerType)
        if tower and tower:IsAlive() then
            bot:Action_AttackMove(tower:GetLocation())
        else
            -- если башня упала — идём на фронт оффлейна
            bot:Action_AttackMove(
                GetLaneFrontLocation(team, offlane, 0)
            )
        end
    end
end

-- Вспомогательная: координаты фонтанов
function GetFountainLocation(team)
    if team == TEAM_RADIANT then
        return Vector(-7144, -6556)
    else
        return Vector(7100, 6500)
    end
end
