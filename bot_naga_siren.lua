-- Загрузка необходимых библиотек
local P = require(GetScriptDirectory() .. "/Library/PhalanxFunctions")
local PItems = require(GetScriptDirectory() .. "/Library/PhalanxItems")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local PAF = require(GetScriptDirectory() .. "/Library/PhalanxAbilityFunctions")
local PChat = require(GetScriptDirectory() .. "/Library/PhalanxChat")

-- Инициализация переменных
local bot = GetBot()
local unitName = bot:GetUnitName()
local abilities = {
	s1 = "naga_siren_mirror_image",
	s2 = "naga_siren_ensnare",
	s3 = "naga_siren_rip_tide",
	s4 = "naga_siren_song_of_the_siren"
}
local abilityLevels = {
	abilities.s1,
	abilities.s2,
	abilities.s3,
	abilities.s1,
	abilities.s1,
	abilities.s4,
	abilities.s1,
	abilities.s2,
	abilities.s2,
	abilities.s2,
	abilities.s2,
	abilities.s3,
	abilities.s3,
	abilities.s3,
	abilities.s3,
	abilities.s4,
	abilities.s4,
	abilities.s4,
	abilities.s4,
	abilities.s4,
	abilities.s4,
	abilities.s4,
	abilities.s4,
	abilities.s4,
	abilities.s4,
	abilities.s4
}

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

function GetFirstTower()
	return GetTower(GetTeam(), 0)
end

function FindItem(itemName)
	-- Проверяем все слоты инвентаря на наличие TP Scroll
	for i = 0, 15 do
		local item = bot:GetItemInSlot(i)
		if item and item:GetName() == itemName then
			return item
		end
	end
	return nil
end

-- Функция для перемещения бота к своей башне
local function MoveToTower()
	if not bot then
		print("Error: bot is nil")
		return
	end

	local tower = GetFirstTower()
	if tower then
		local tpScroll = FindItem("item_tpscroll")
		if tpScroll and tpScroll:IsFullyCastable() then
			-- Использовать телепорт, если он доступен
			bot:Action_UseAbilityOnLocation(tpScroll, tower:GetLocation())
		else
			-- Перемещаться к башне, если телепорт недоступен
			bot:Action_MoveToLocation(tower:GetLocation())
		end
	end
end
-- Функция для перемещения бота вперед по линии
local function MoveForwardOnLane()
    if not bot then
        print("Error: bot is nil")
        return
    end

    -- Получаем текущую линию бота (0 - top, 1 - middle, 2 - bottom)
    local lane = bot:GetAssignedLane()
    if lane == LANE_TOP then
        lane = 0
    elseif lane == LANE_MID then
        lane = 1
    elseif lane == LANE_BOT then
        lane = 2
    else
        print("Error: Invalid lane assigned to bot")
        return
    end

    -- Получаем точку на передней линии для текущей линии бота
    local frontLocation = GetLaneFrontLocation(bot:GetTeam(), lane, 0) -- 0 для передней линии
    if frontLocation then
        -- Перемещаемся к точке на передней линии
        bot:Action_MoveToLocation(frontLocation)
    else
        print("Error: Failed to get lane front location")
    end
end

-- Функция для фарма на линии
local function FarmLane()
	local searchRadius = 300
    local laneCreeps = bot:GetNearbyLaneCreeps(searchRadius, true)
	
    if #laneCreeps == 0 then
		MoveForwardOnLane()
	end

	local botDamage = bot:GetAttackDamage()
	local targetCreep = nil
	local minHealth = 99999

    bot:ActionImmediate_Chat("Target creep search", true)
	-- Найти крипа с минимальным здоровьем
	for _, creep in pairs(laneCreeps) do
		local creepHealth = creep:GetHealth()
		bot:ActionImmediate_Chat("Target creep health: "..creepHealth, true)
		if creep and creepHealth < minHealth then
			minHealth = creepHealth
			targetCreep = creep
		end
	end

    bot:ActionImmediate_Chat("Target creep: " .. toString(targetCreep), true)
	
	if targetCreep then
		bot:ActionImmediate_Chat("Target creep health: "..toString(targetCreep:GetHealth()), true)
		local creepHealth = targetCreep:GetHealth()
		local distanceToCreep = bot:GetDistanceTo(targetCreep)

		-- Если здоровье крипа меньше, чем на 1 атаку бота, атаковать его
		if creepHealth <= botDamage then
			bot:Action_AttackUnit(targetCreep, true)
			-- Если здоровье крипа меньше, чем на 2 атаки бота, приближаться к нему
		elseif creepHealth <= 2 * botDamage and distanceToCreep > bot:GetAttackRange() then
			bot:Action_MoveToUnit(targetCreep)
		else
			-- Перемещаться в случайные позиции в небольшом радиусе
			local randomX = bot:GetLocation().x + math.random(-100, 100)
			local randomY = bot:GetLocation().y + math.random(-100, 100)
			bot:Action_MoveToLocation(Vector(randomX, randomY, 0))
		end
	else
		-- Перемещаться в случайные позиции в небольшом радиусе
		local randomX = bot:GetLocation().x + math.random(-100, 100)
		local randomY = bot:GetLocation().y + math.random(-100, 100)
		bot:Action_MoveToLocation(Vector(randomX, randomY, 0))
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
		FarmLane()
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
	-- Прокачивание навыков при получении уровня
    LevelUpAbilities()
	
	CheckState()
	ProcessState()
end

-- Функция для определения приоритета выполнения поведения
function GetDesire()
	return 0.9
end
