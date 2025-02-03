-- Загрузка необходимых библиотек
local farmLaneLogic = require(GetScriptDirectory() .. "/Logics/FarmLogic/BotLiningFarmLogic")

-- Инициализация переменных
local bot = GetBot()
local dotaTime = 0
local unitName = bot:GetUnitName()
local abilities = {
    s1 = "naga_siren_mirror_image",
    s2 = "naga_siren_ensnare",
    s3 = "naga_siren_rip_tide",
    s4 = "naga_siren_song_of_the_siren"
}
local abilityLevels = {abilities.s1, abilities.s2, abilities.s3, abilities.s1, abilities.s1, abilities.s4, abilities.s1,
                       abilities.s2, abilities.s2, abilities.s2, abilities.s2, abilities.s3, abilities.s3, abilities.s3,
                       abilities.s3, abilities.s4, abilities.s4, abilities.s4, abilities.s4, abilities.s4, abilities.s4,
                       abilities.s4, abilities.s4, abilities.s4, abilities.s4, abilities.s4}

-- Объект состояния поведения
local BehaviorState = {
    MOVE_TO_TOWER = "MOVE_TO_TOWER",
    FARM_LANE = "FARM_LANE",
    PUSH_LANE_ILLUSIONS = "PUSH_LANE_ILLUSIONS",
    PUSH_LANE_WITH_ILLUSIONS = "PUSH_LANE_WITH_ILLUSIONS",
    PLACE_WARDS = "PLACE_WARDS",
    ATTACK_HERO = "ATTACK_HERO"
}

local currentState = BehaviorState.MOVE_TO_TOWER
local currentTarget = nil

-- Функция для прокачивания навыков и талантов
local function LevelUpAbilities()
    local level = bot:GetLevel()
    for i = 1, level do
        local ability = abilityLevels[i]
        if ability and bot:GetAbilityPoints() > 0 then
            bot:ActionImmediate_LevelAbility(ability)
        end
    end

    -- Прокачивание талантов
    if bot:GetAbilityPoints() > 0 then
        local talentTree = bot:GetTalentTree()
        for i = 1, #talentTree do
            if bot:GetAbilityPoints() > 0 and bot:CanUpgradeAbility(talentTree[i]) then
                bot:ActionImmediate_LevelAbility(talentTree[i])
            end
        end
    end
end

-- Функция для пуша линии иллюзиями
local function PushLaneWithIllusions()
    local mirrorImage = bot:GetAbilityByName(abilities.s1)
    if mirrorImage and mirrorImage:IsFullyCastable() then
        local target = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
        if #target > 0 then
            bot:Action_UseAbilityOnEntity(mirrorImage, target[1])
        else
            bot:Action_UseAbility(mirrorImage)
        end
    end
end

-- Функция для пуша линии вместе с иллюзиями
local function PushLaneWithIllusionsTogether()
    FarmLane()
    PushLaneWithIllusions()
end

-- Функция для расстановки вардов
local function PlaceWards()
    -- Логика для расстановки вардов
end

-- Функция для атаки героя
local function AttackHero()
    local enemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    if #enemyHeroes > 0 then
        bot:Action_AttackUnit(enemyHeroes[1], true)
    end
end

-- Функция для смены состояния и цели
local function ChangeState(newState, newTarget)
    if currentState ~= newState or currentTarget ~= newTarget then
        currentState = newState
        currentTarget = newTarget
        bot:ActionImmediate_Chat("Changing state to " .. newState .. " with target " .. (newTarget or "none"), false)
    end
end

function ProcessState()
    if currentState == BehaviorState.MOVE_TO_TOWER then
        MoveToTower()
    elseif currentState == BehaviorState.FARM_LANE then
        FarmLane(dotaTime)
    end
end

function CheckState()
    local tower = GetFirstTower()
    local firstTowerDistance = (tower:GetLocation() - bot:GetLocation()):Length2D()
    if currentState == BehaviorState.MOVE_TO_TOWER then
        if firstTowerDistance < 200 then
            currentState = BehaviorState.FARM_LANE
        end
    elseif currentState == BehaviorState.FARM_LANE then
        if firstTowerDistance > 5000 then
            currentState = BehaviorState.MOVE_TO_TOWER
        end
    end
end

-- Основная функция для поведения бота
function Think()
    dotaTime = DotaTime()
    -- Прокачивание навыков при получении уровня
    LevelUpAbilities()

    CheckState()
    ProcessState()
end

-- Функция для определения приоритета выполнения поведения
function GetDesire()
    return 0.9
end
