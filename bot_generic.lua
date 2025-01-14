local P = require(GetScriptDirectory() .. "/Library/PhalanxFunctions")
local PRole = require(GetScriptDirectory() ..  "/Library/PhalanxRoles")
local refThink5Pos = require(GetScriptDirectory() ..  "/BehaviourExtensions/ThinksFor5PositionBot")

local bot = GetBot()

function MinionThink(hMinionUnit)
    if not hMinionUnit:IsNull() and hMinionUnit ~= nil then
        if hMinionUnit:IsIllusion() then
            local target = P.IllusionTarget(hMinionUnit, bot)

            if target ~= nil then
                hMinionUnit:Action_AttackUnit(target, false)
            else
                if GetUnitToUnitDistance(hMinionUnit, bot) > 200 then
                    hMinionUnit:Action_MoveToLocation(bot:GetLocation())
                else
                    hMinionUnit:Action_MoveToLocation(bot:GetLocation() + RandomVector(200))
                end
            end
        end
    end
end

function Think1()

    local heroName = bot:GetUnitName()

    -- Определяем позицию бота в команде
    local position = GetBotPositionInTeam(bot)

    -- Вызов соответствующей функции в зависимости от позиции
    if position == 1 then
        ThinkPos1(bot, heroName)
    elseif position == 2 then
        ThinkPos2(bot, heroName)
    elseif position == 3 then
        ThinkPos3(bot, heroName)
    elseif position == 4 then
        ThinkPos4(bot, heroName)
    elseif position == 5 then
        ThinkPos5(bot, heroName)
    else
        -- Логика на случай, если позиция не определена
        print("Не удалось определить позицию для бота: " .. heroName)
    end
end

-- Вспомогательная функция для определения позиции бота
function GetBotPositionInTeam(bot)
    local playerID = bot:GetPlayerID()
    local teamPlayers = GetTeamPlayers(bot:GetTeam())
    
    -- Сортируем команду по порядку PlayerID
    table.sort(teamPlayers)
    
    -- Определяем позицию в зависимости от индекса PlayerID в списке
    for i, id in ipairs(teamPlayers) do
        if id == playerID then
            return i -- Позиция (1 = кэрри, 5 = саппорт)
        end
    end

    return -1 -- Возвращаем -1, если позиция не найдена
end

-- Пример функций для каждой позиции
function ThinkPos1(bot, heroName)
    --print(heroName .. " играет на позиции 1 (кэрри)")
    -- Логика для кэрри
end

function ThinkPos2(bot, heroName)
    --print(heroName .. " играет на позиции 2 (мид)")
    -- Логика для мида
end

function ThinkPos3(bot, heroName)
    --print(heroName .. " играет на позиции 3 (оффлейн)")
    -- Логика для оффлейна
end

function ThinkPos4(bot, heroName)
    --print(heroName .. " играет на позиции 4 (саппорт)")
    -- Логика для саппорта
end

