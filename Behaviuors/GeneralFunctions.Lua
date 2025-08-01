gf = {}


function gf.SendMsg(bot, message)
    bot:ActionImmediate_Chat(message, false)
end

function gf.SendMsgAll(bot, message)
    bot:ActionImmediate_Chat(message, true)
end

function gf.IsRadiant(bot)
    return bot:GetTeam() == TEAM_RADIANT
end

--Получить колическтво атакующих указанный юнит, а также сколько урона они могут нанести
function gf.GetNumAttackersAndThierDamage(hTargetUnit)
    --float GetActualIncomingDamage( nDamage, nDamageType ) - Расчет входящего урона после сопротивлений.
    -- float GetAttackDamage() - Актуальный урон (с бонусами).

    local attackers = 0
    local summDamage = 0
    local invalidTarget = not hTargetUnit or not hTargetUnit:IsAlive()
    if not invalidTarget then
        local nearbyEnemies = hTargetUnit:GetNearbyHeroes(1200, true, BOT_MODE_NONE) -- Герои в радиусе 1200

        if nearbyEnemies ~= nil then
            -- Проверяем вражеских героев
            for _, enemy in ipairs(nearbyEnemies) do
                if enemy ~= nil and enemy:GetAttackTarget() == hTargetUnit then
                    local damage = enemy:GetAttackDamage()
                    local actualDamage = hTargetUnit:GetActualIncomingDamage(damage, DAMAGE_TYPE_PHYSICAL)
                    summDamage = summDamage + actualDamage
                    attackers = attackers + 1
                end
            end
        end

        -- Проверяем крипов (добавьте при необходимости)
        local nearbyCreeps = hTargetUnit:GetNearbyCreeps(1200, true)
        if nearbyCreeps ~= nil then
            for _, creep in ipairs(nearbyCreeps) do
                if creep ~= nil and creep:GetAttackTarget() == hTargetUnit then
                    local damage = creep:GetAttackDamage()
                    local actualDamage = hTargetUnit:GetActualIncomingDamage(damage, DAMAGE_TYPE_PHYSICAL)
                    summDamage = summDamage + actualDamage
                    attackers = attackers + 1
                end
            end
        end
    end

    return attackers, summDamage
end

function gf.IsTargetInRange(hUnitAttaker, hUnitTarget)
    local attackRange = hUnitAttaker:GetAttackRange()
    local sqrAttackRange = attackRange * attackRange
    -- `float GetUnitToUnitDistanceSqr( hUnit1, hUnit2 )` - Возвращает квадрат расстояния между двумя юнитами (оптимизировано для сравнений).
    local sqrDistance = GetUnitToUnitDistanceSqr(hUnitAttaker, hUnitTarget)
    return sqrDistance < sqrAttackRange
end

return gf
