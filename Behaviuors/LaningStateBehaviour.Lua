local gf = require(GetScriptDirectory() .. "\\Behaviuors.GeneralFunctions")

local LaningStateBehaviourCreator = {}

function LaningStateBehaviourCreator.Create()
    local LaningStateBehaviour = {}
    LaningStateBehaviour.selfBot = nil

    LaningStateBehaviour.stateLaning = true
    LaningStateBehaviour.LaneTypes =
    {
        EASE = 1,
        MID  = 2,
        HARD = 3
    }
    LaningStateBehaviour.laneType = LaningStateBehaviour.LaneTypes.EASE

    --Получить конкретную линию для бота по его типу линии.
    --Т.е. если он на сложной линии, то в зависимости от стороны будет получен на верхняя или нижняя.
    function LaningStateBehaviour.GetConcreteLineByLaneType()
        local isRadiant = gf.IsRadiant(LaningStateBehaviour.selfBot)

        if (LaningStateBehaviour.laneType == LaningStateBehaviour.LaneTypes.MID) then
            return LANE_MID
        end
        if (LaningStateBehaviour.laneType == LaningStateBehaviour.LaneTypes.EASE) then
            if isRadiant then
                return LANE_BOT
            else
                return LANE_TOP
            end
        end
        if (LaningStateBehaviour.laneType == LaningStateBehaviour.LaneTypes.HARD) then
            if isRadiant then
                return LANE_TOP
            else
                return LANE_BOT
            end
        end
    end

    --Задать значение для LaningStateBehaviour.laneType
    function LaningStateBehaviour.SetLaneType(botNumberInTeam)
        local or15 = botNumberInTeam == 1 or botNumberInTeam == 5
        local or34 = botNumberInTeam == 3 or botNumberInTeam == 4
        local is2 = botNumberInTeam == 2
        if or15 then
            LaningStateBehaviour.laneType = LaningStateBehaviour.LaneTypes.EASE
        end
        if or34 then
            LaningStateBehaviour.laneType = LaningStateBehaviour.LaneTypes.HARD
        end
        if is2 then
            LaningStateBehaviour.laneType = LaningStateBehaviour.LaneTypes.MID
        end
    end

    --Задать текущему боту идти в указанное положение
    function LaningStateBehaviour.MoveBotLocation(location)
        LaningStateBehaviour.selfBot:Action_MoveToLocation(location)
    end

    --Функция, чтобы отправить бота на линию за крипами
    function LaningStateBehaviour.GetFrontOnLine()
        local line = LaningStateBehaviour.GetConcreteLineByLaneType(LaningStateBehaviour.selfBot)
        return GetLaneFrontLocation(LaningStateBehaviour.selfBot:GetTeam(), line, -600)
    end
    --Функция, чтобы отправить бота на линию за крипами
    function LaningStateBehaviour.MoveToFrontOnLine()
        local location =  LaningStateBehaviour.GetFrontOnLine()
        LaningStateBehaviour.MoveBotLocation(location)
    end

    --Найти крипа с минимальным здоровьем.
    --Если крип не найден, будет пустая ссылка.
    --Если найден, то вернётся ссылка на крипа, размер его здоровья, и процент здоровья
    --isEnemy - указать, должен ли быть это вражеский крип
    function LaningStateBehaviour.GetNearbyCreepWithMinHP(isEnemy)
        local creepMinHp = 99999
        local creepHpPercent = 1
        local hMinHpCreep = nil
        for _, creep in pairs(LaningStateBehaviour.selfBot:GetNearbyCreeps(1000, isEnemy)) do
            local hp = creep:GetHealth()
            if hp < creepMinHp then
                creepMinHp = hp
                hMinHpCreep = creep
            end
        end

        if hMinHpCreep ~= nil then
            -- текущее и максимальное HP
            local currentHP = hMinHpCreep:GetHealth()
            local maxHP = hMinHpCreep:GetMaxHealth()
            creepHpPercent = (currentHP / maxHP)
        end

        return hMinHpCreep, creepMinHp, creepHpPercent
    end

    function LaningStateBehaviour.CanLastHit(hCreep, creepHP, damage)
        --float GetActualIncomingDamage( nDamage, nDamageType ) - Расчет входящего урона после сопротивлений.
        local forCreepDamage = hCreep:GetActualIncomingDamage(damage, DAMAGE_TYPE_PHYSICAL)
        return forCreepDamage >= creepHP
    end

    function LaningStateBehaviour.Think(dotaTime)
        if LaningStateBehaviour.selfBot:IsChanneling() then return end -- Не прерывать касты

        local enemyCreepMinHp = 99999
        local creepHpPercent = 1
        local hMinHpEnemyCreep = nil
        hMinHpEnemyCreep, enemyCreepMinHp, creepHpPercent = LaningStateBehaviour.GetNearbyCreepWithMinHP(true)
        local damage = LaningStateBehaviour.selfBot:GetAttackDamage()

        --ToDo: позже надо будет вынести причины отступления в отдельную функцию для чистоты и оптимизации
        --Вражеский крип найден
        local hasEnemyCreep = hMinHpEnemyCreep ~= nil
        --Скоро надо будет добить крипа
        local isSoonHitCreep = creepHpPercent < 0.3
        --Надо отойти в безопасное положение за линией фронта
        local retreatToSafeOnLine = not hasEnemyCreep or not isSoonHitCreep
        --Отойти также, если атакую двое или больше
        local botAttakersCount = gf.GetNumAttackers(LaningStateBehaviour.selfBot)
        retreatToSafeOnLine = retreatToSafeOnLine or botAttakersCount > 1

        --Отойти в безопасность, если надо
        if (retreatToSafeOnLine) then
            LaningStateBehaviour.MoveToFrontOnLine()
        else
            --Вражеского крипа можно добить одним ударом
            local canLastHitEnemyCreep = hasEnemyCreep and
                LaningStateBehaviour.CanLastHit(hMinHpEnemyCreep, enemyCreepMinHp, damage)
            if canLastHitEnemyCreep then
                --Action_AttackUnit( hUnit, bOnce ) - Приказывает атаковать юнита. При bOnce=true останавливается после одной атаки.
                LaningStateBehaviour.selfBot:Action_AttackUnit(hMinHpEnemyCreep, true)
            else
                if isSoonHitCreep then --Подойти к крипу, которого скоро можно будет добить.
                    local creepLocation = hMinHpEnemyCreep:GetLocation()
                    LaningStateBehaviour.MoveBotLocation(creepLocation)
                end
            end
        end
    end

    return LaningStateBehaviour
end

return LaningStateBehaviourCreator
