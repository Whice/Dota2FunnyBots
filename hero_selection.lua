local desiredHeroes = {
    "npc_dota_hero_sniper",      -- Снайпер
    "npc_dota_hero_necrolyte",   -- Некрофос
    "npc_dota_hero_naga_siren",  -- Нага Сирена
    "npc_dota_hero_ogre_magi",   -- Огр Маг
    "npc_dota_hero_warlock"      -- Варлок
}

function Think()
    -- Получаем текущее состояние выбора героев
    local pickState = GetHeroPickState()
    
    -- Если не фаза выбора героев, выходим
    if pickState == HEROPICK_STATE_NONE then
        return
    end
    
    -- Получаем команду, для которой выполняется скрипт
    local team = GetTeam()
    
    -- Получаем всех игроков в команде
    local teamPlayers = GetTeamPlayers(team)
    
    local selectedHeroes = {}
    
    -- Сначала собираем информацию о уже выбранных героях
    for _, playerID in ipairs(teamPlayers) do
        local heroName = GetSelectedHeroName(playerID)
        if heroName and heroName ~= "" then
            table.insert(selectedHeroes, heroName)
        end
    end
    
    -- Для каждого игрока в команде
    for _, playerID in ipairs(teamPlayers) do
        -- Проверяем, является ли игрок ботом
        if IsPlayerBot(playerID) then
            -- Проверяем, не выбран ли уже герой для этого бота
            local currentHero = GetSelectedHeroName(playerID)
            if not currentHero or currentHero == "" then
                -- Ищем еще не выбранного героя из нашего списка
                for _, heroName in ipairs(desiredHeroes) do
                    -- Проверяем, не выбран ли этот герой уже другим игроком
                    local alreadySelected = false
                    for _, selectedHero in ipairs(selectedHeroes) do
                        if selectedHero == heroName then
                            alreadySelected = true
                            break
                        end
                    end
                    
                    -- Если герой еще не выбран и игрок может выбирать героя
                    if not alreadySelected and IsPlayerInHeroSelectionControl(playerID) then
                        -- Выбираем героя
                        SelectHero(playerID, heroName)
                        table.insert(selectedHeroes, heroName)
                        break
                    end
                end
            else
                -- Если герой уже выбран, добавляем его в список выбранных
                table.insert(selectedHeroes, currentHero)
            end
        end
    end
end

function UpdateLaneAssignments()
    -- Базовое распределение по линиям
    local team = GetTeam()
    local teamPlayers = GetTeamPlayers(team)
    
    local laneAssignments = {}
    
    -- Распределение героев по линиям (можно настроить под конкретных героев)
    local laneIndex = 1
    local lanes = {LANE_TOP, LANE_MID, LANE_BOT, LANE_BOT, LANE_TOP}
    
    for _, playerID in ipairs(teamPlayers) do
        if IsPlayerBot(playerID) then
            -- Назначаем линию в зависимости от позиции в списке
            laneAssignments[playerID] = lanes[laneIndex] or LANE_MID
            laneIndex = laneIndex + 1
        else
            -- Для игроков-людей назначаем случайную линию
            laneAssignments[playerID] = RandomInt(LANE_TOP, LANE_BOT)
        end
    end
    
    return laneAssignments
end

function GetBotNames()
    -- Возвращаем имена для ботов
    return {
        "SniperBot",
        "NecroBot",
        "NagaBot",
        "OgreBot",
        "WarlockBot"
    }
end