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

    --Функция, чтобы отправить бота на линию за крипами
    function LaningStateBehaviour.SetFrontOnLine()
        local line = LaningStateBehaviour.GetConcreteLineByLaneType(LaningStateBehaviour.selfBot )
        LaningStateBehaviour.selfBot:Action_MoveToLocation(GetLaneFrontLocation(LaningStateBehaviour.selfBot:GetTeam(), line, -600))
    end

    --Найти крипа с минимальным здоровьем.
    --Если крип не найден, будет пустая ссылка.
    --Если найден, то вернётся ссылка на крипа и размер его здоровья.
    --isEnemy - указать, должен ли быть это вражеский крип
    function LaningStateBehaviour.GetNearbyCreepWithMinHP(isEnemy)
        local creepMinHp = 99999
        local hMinHpCreep = nil
        for _, creep in pairs(LaningStateBehaviour.selfBot :GetNearbyCreeps(1000, isEnemy)) do
            local hp = creep:GetHealth()
            if hp < creepMinHp then
                creepMinHp = hp
                hMinHpCreep = creep
            end
        end
        return hMinHpCreep, creepMinHp
    end

    function LaningStateBehaviour.CanLastHit(hCreep, creepHP, damage)
        --float GetActualIncomingDamage( nDamage, nDamageType ) - Расчет входящего урона после сопротивлений.
        local forCreepDamage = hCreep:GetActualIncomingDamage(damage, DAMAGE_TYPE_PHYSICAL)
        return forCreepDamage >= creepHP
    end

    function LaningStateBehaviour.Think(dotaTime)
        if LaningStateBehaviour.selfBot :IsChanneling() then return end -- Не прерывать касты

        local enemyCreepMinHp = 99999
        local hMinHpEnemyCreep = nil
        hMinHpEnemyCreep, enemyCreepMinHp = LaningStateBehaviour.GetNearbyCreepWithMinHP(LaningStateBehaviour.selfBot, true)
        local damage = LaningStateBehaviour.selfBot:GetAttackDamage()

        --Вражеский крип найден
        local hasEnemyCreep = hMinHpEnemyCreep ~= nil
        --Вражеского крипа можно добить одним ударом
        local canLastHitEnemyCreep = hasEnemyCreep and
        LaningStateBehaviour.CanLastHit(hMinHpEnemyCreep, enemyCreepMinHp, damage)
        --Надо отойти в безопасное положение за линией фронта
        local retreatToSafeOnLine = not hasEnemyCreep or not canLastHitEnemyCreep

        if (retreatToSafeOnLine) then
            LaningStateBehaviour.SetFrontOnLine()
        else
            if canLastHitEnemyCreep then
                --Action_AttackUnit( hUnit, bOnce ) - Приказывает атаковать юнита. При bOnce=true останавливается после одной атаки.
                LaningStateBehaviour.selfBot :Action_AttackUnit(hMinHpEnemyCreep, true)
            end
        end
    end

    return LaningStateBehaviour
end

return LaningStateBehaviourCreator