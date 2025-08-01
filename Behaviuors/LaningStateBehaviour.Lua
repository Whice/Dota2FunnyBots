local gf = require(GetScriptDirectory() .. "\\Behaviuors.GeneralFunctions")

local LaningStateBehaviourCreator = {}

function LaningStateBehaviourCreator.Create()
    local LaningStateBehaviour = {}
    LaningStateBehaviour.selfBot = nil
    LaningStateBehaviour.weakestEnemyCreep = nil
    LaningStateBehaviour.weakestFriendCreep = nil
    LaningStateBehaviour.lastThinkTime = -500.0
    LaningStateBehaviour.thinkRate = 0.05

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
        local location = LaningStateBehaviour.GetFrontOnLine()
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
        local creeps = LaningStateBehaviour.selfBot:GetNearbyCreeps(1000, isEnemy)
        if creeps ~= nil then
            for _, creep in pairs(creeps) do
                local hp = creep:GetHealth()
                if hp < creepMinHp then
                    creepMinHp = hp
                    hMinHpCreep = creep
                end
            end
        end

        local creepResults = {}
        creepResults.handle = hMinHpCreep
        creepResults.hasEnemyCreep = hMinHpCreep ~= nil
        if creepResults.hasEnemyCreep then
            creepResults.creepMinHp = creepMinHp
            -- текущее и максимальное HP
            local currentHP = hMinHpCreep:GetHealth()
            local maxHP = hMinHpCreep:GetMaxHealth()
            creepHpPercent = (currentHP / maxHP)
            creepResults.creepMinHp = creepHpPercent

            
            local botAttakersCount, potentialDamage = gf.GetNumAttackersAndThierDamage(hMinHpCreep)
        
            local creepHpPercentAfterDamage =((currentHP - potentialDamage)/ maxHP)
            --ToDo: в будущем учесть получаемый крипом урон, дальность атаки бота и его скорость передвижения.
            --Скоро надо будет добить крипа
            creepResults.isSoonHitCreep = creepHpPercentAfterDamage < (0.3 + 0.02 * botAttakersCount)
        end

        if isEnemy then
            LaningStateBehaviour.weakestEnemyCreep = creepResults
        else
            LaningStateBehaviour.weakestFriendCreep = creepResults
        end

        return hMinHpCreep, creepMinHp, creepHpPercent
    end

    function LaningStateBehaviour.CanLastHit(hCreep, creepHP, damage)
        --float GetActualIncomingDamage( nDamage, nDamageType ) - Расчет входящего урона после сопротивлений.
        local forCreepDamage = hCreep:GetActualIncomingDamage(damage, DAMAGE_TYPE_PHYSICAL)
        return forCreepDamage >= creepHP
    end

    --Проверка, надо ли отступить
    function LaningStateBehaviour.IsNeedRetreatToSafeOnLine()
        --ToDo: нужны оптимизации

        --Скоро надо будет добить крипа
        local isSoonHitEnemyCreep = LaningStateBehaviour.weakestEnemyCreep.isSoonHitCreep
        --ToDo: позже надо будет вынести причины отступления в отдельную функцию для чистоты и оптимизации
        --Вражеский крип найден
        local hasEnemyCreep = LaningStateBehaviour.weakestEnemyCreep.hasEnemyCreep
        --Надо отойти в безопасное положение за линией фронта
        local retreatToSafeOnLine = not hasEnemyCreep or not isSoonHitEnemyCreep
        --Отойти также, если атакую двое или больше
        --ToDo: в будущем учесть атаку башни
        local botAttakersCount, _ = gf.GetNumAttackersAndThierDamage(LaningStateBehaviour.selfBot)
        retreatToSafeOnLine = retreatToSafeOnLine or botAttakersCount > 1

        return retreatToSafeOnLine
    end

    --Надо добить вражеского крипа
    function LaningStateBehaviour.IsNeedLastHitEnemyCreep()
        --Вражеский крип найден
        local hasEnemyCreep = LaningStateBehaviour.weakestEnemyCreep.hasEnemyCreep
        local hMinHpEnemyCreep = LaningStateBehaviour.weakestEnemyCreep.handle
        local enemyCreepMinHp = LaningStateBehaviour.weakestEnemyCreep.creepMinHp
        local damage = LaningStateBehaviour.selfBot:GetAttackDamage()
        local canLastHit = LaningStateBehaviour.CanLastHit(hMinHpEnemyCreep, enemyCreepMinHp, damage)
        --Вражеского крипа можно добить одним ударом
        local canLastHitEnemyCreep = hasEnemyCreep and canLastHit

        return canLastHitEnemyCreep
    end

    function LaningStateBehaviour.Think(dotaTime)
        local isNeedThink = LaningStateBehaviour.lastThinkTime + LaningStateBehaviour.thinkRate < dotaTime
        if not isNeedThink then return end
        LaningStateBehaviour.lastThinkTime = dotaTime

        if LaningStateBehaviour.selfBot:IsChanneling() then return end -- Не прерывать касты
        LaningStateBehaviour.GetNearbyCreepWithMinHP(true)

        local isNeedRetreatToSafeOnLine = LaningStateBehaviour.IsNeedRetreatToSafeOnLine()

        --Отойти в безопасность, если надо
        if (isNeedRetreatToSafeOnLine) then
            LaningStateBehaviour.MoveToFrontOnLine()
        else
            local canLastHitEnemyCreep = LaningStateBehaviour.IsNeedLastHitEnemyCreep()
            local hMinHpEnemyCreep = LaningStateBehaviour.weakestEnemyCreep.handle
            if canLastHitEnemyCreep then
                --Action_AttackUnit( hUnit, bOnce ) - Приказывает атаковать юнита. При bOnce=true останавливается после одной атаки.
                LaningStateBehaviour.selfBot:Action_AttackUnit(hMinHpEnemyCreep, true)
            else
                local prepareForAttack = gf.IsTargetInRange(LaningStateBehaviour.selfBot, hMinHpEnemyCreep)

                --Скоро надо будет добить крипа
                local isSoonHitEnemyCreep = LaningStateBehaviour.weakestEnemyCreep.isSoonHitCreep
                if isSoonHitEnemyCreep and not prepareForAttack then --Подойти к крипу, которого скоро можно будет добить.
                    local creepLocation = hMinHpEnemyCreep:GetLocation()
                    LaningStateBehaviour.MoveBotLocation(creepLocation)
                end
            end
        end
    end

    return LaningStateBehaviour
end

return LaningStateBehaviourCreator
