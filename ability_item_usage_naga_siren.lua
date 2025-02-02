------------------------------
-- CREATED BY: MANSLAUGHTER --
------------------------------

-- Получаем объект текущего бота
local bot = GetBot()

-- Проверка: если бот неуязвим, не является героем или является иллюзией, то код не выполняется
if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() then return end

-- Подключаем внешние библиотеки для общих функций и функций способностей
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions") -- Общие функции
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions") -- Функции для работы со способностями

-- Подключаем общую логику использования предметов и способностей
local ability_item_usage_generic = dofile(GetScriptDirectory().."/ability_item_usage_generic")

-- Делегирование стандартных функций общему модулю
function AbilityLevelUpThink()  
    ability_item_usage_generic.AbilityLevelUpThink(); -- Логика прокачки способностей
end

function BuybackUsageThink()
    ability_item_usage_generic.BuybackUsageThink(); -- Логика использования выкупа
end

function CourierUsageThink()
    ability_item_usage_generic.CourierUsageThink(); -- Логика использования курьера
end

function ItemUsageThink()
    ability_item_usage_generic.ItemUsageThink(); -- Логика использования предметов
end

-- Получаем объекты способностей Наги Сирены
local MirrorImage = bot:GetAbilityByName("naga_siren_mirror_image") -- Способность "Зеркальное изображение"
local Ensnare = bot:GetAbilityByName("naga_siren_ensnare") -- Способность "Сети"
local Riptide = bot:GetAbilityByName("naga_siren_rip_tide") -- Способность "Морская пучина"
local SongOfTheSiren = bot:GetAbilityByName("naga_siren_song_of_the_siren") -- Ультимативная способность "Песня сирены"

-- Переменные для хранения желания использовать способности
local MirrorImageDesire = 0
local EnsnareDesire = 0
local SongOfTheSirenDesire = 0

-- Переменные для хранения дальности атаки и текущей цели бота
local AttackRange
local BotTarget

-- Основная функция для принятия решений о использовании способностей
function AbilityUsageThink()
    AttackRange = bot:GetAttackRange() -- Получаем текущую дальность атаки бота
    BotTarget = bot:GetTarget() -- Получаем текущую цель бота

    -- Приоритет использования способностей:
    -- 1. Ульта (SongOfTheSiren)
    -- 2. Зеркальное изображение (MirrorImage)
    -- 3. Сети (Ensnare)

    -- Проверка на использование ульты
    SongOfTheSirenDesire, SongOfTheSirenTarget = UseSongOfTheSiren()
    if SongOfTheSirenDesire > 0 then
        bot:Action_UseAbility(SongOfTheSiren) -- Используем ульту
        return
    end
    
    -- Проверка на использование зеркальных изображений
    MirrorImageDesire, MirrorImageTarget = UseMirrorImage()
    if MirrorImageDesire > 0 then
        bot:Action_UseAbility(MirrorImage) -- Используем способность "Зеркальное изображение"
        return
    end
    
    -- Проверка на использование сетей
    EnsnareDesire, EnsnareTarget = UseEnsnare()
    if EnsnareDesire > 0 then
        bot:Action_UseAbilityOnEntity(Ensnare, EnsnareTarget) -- Используем способность "Сети" на цели
        return
    end
end

-- Функция для определения, когда использовать способность "Зеркальное изображение"
function UseMirrorImage()
    if not MirrorImage:IsFullyCastable() then return 0 end -- Проверка на перезарядку
    if P.CantUseAbility(bot) then return 0 end -- Общая проверка (из библиотеки)

    -- Использовать в бою против героев
    if PAF.IsEngaging(bot) then
        if PAF.IsValidHeroAndNotIllusion(BotTarget) then
            return BOT_ACTION_DESIRE_HIGH, BotTarget -- Высокое желание использовать, если цель - герой
        end
    end

    -- Использовать при атаке зданий
    local attacktarget = bot:GetAttackTarget()
    if attacktarget ~= nil and attacktarget:IsBuilding() then
        return BOT_ACTION_DESIRE_HIGH -- Высокое желание использовать, если цель - здание
    end

    -- Использовать для фарма крипов
    if bot:GetActiveMode() == BOT_MODE_FARM then
        if attacktarget ~= nil and attacktarget:IsCreep() then
            return BOT_ACTION_DESIRE_HIGH -- Высокое желание использовать, если цель - крип
        end
    end

    -- Использовать против Рошана
    if bot:GetActiveMode() == BOT_MODE_ROSHAN then
        if attacktarget ~= nil and PAF.IsRoshan(attacktarget) then
            return BOT_ACTION_DESIRE_HIGH -- Высокое желание использовать, если цель - Рошан
        end
    end

    return 0 -- Если ни одно условие не выполнено, желание использовать способность равно 0
end

-- Функция для определения, когда использовать способность "Сети"
function UseEnsnare()
    if not Ensnare:IsFullyCastable() then return 0 end -- Проверка на перезарядку
    if P.CantUseAbility(bot) then return 0 end -- Общая проверка (из библиотеки)

    local CastRange = PAF.GetProperCastRange(Ensnare:GetCastRange()) -- Получаем дальность применения способности
    
    -- Поиск врагов в радиусе применения
    local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
    local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange) -- Фильтр целей для контроля

    -- Прерывание каналов врагов (например, Teleport, Black Hole)
    for _, enemy in pairs(FilteredEnemies) do
        if enemy:IsChanneling() then
            return BOT_ACTION_DESIRE_HIGH, enemy -- Высокое желание использовать, если враг кастует способность
        end
    end

    -- Использование в бою
    if PAF.IsEngaging(bot) then
        if PAF.IsValidHeroAndNotIllusion(BotTarget) then
            if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
                return BOT_ACTION_DESIRE_HIGH, BotTarget -- Высокое желание использовать, если цель в радиусе
            end
        end
    end

    -- Использование при отступлении
    if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
        local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
        return BOT_ACTION_DESIRE_HIGH, ClosestTarget -- Высокое желание использовать, если бот отступает
    end

    -- Использование против Рошана
    if bot:GetActiveMode() == BOT_MODE_ROSHAN then
        local AttackTarget = bot:GetAttackTarget()
        if PAF.IsRoshan(AttackTarget) and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
            return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget -- Очень высокое желание использовать против Рошана
        end
    end

    return 0 -- Если ни одно условие не выполнено, желание использовать способность равно 0
end

-- Функция для определения, когда использовать ультимативную способность "Песня сирены"
function UseSongOfTheSiren()
    if not SongOfTheSiren:IsFullyCastable() then return 0 end -- Проверка на перезарядку
    if P.CantUseAbility(bot) then return 0 end -- Общая проверка (из библиотеки)

    local CastRange = SongOfTheSiren:GetSpecialValueInt("radius") -- Получаем радиус действия ульты
    local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE) -- Враги в радиусе

    -- Активация при отступлении, если есть враги рядом
    if P.IsRetreating(bot) and #enemies >= 1 then
        return BOT_ACTION_DESIRE_HIGH -- Высокое желание использовать, если бот отступает и враги рядом
    end

    return 0 -- Если ни одно условие не выполнено, желание использовать способность равно 0
end