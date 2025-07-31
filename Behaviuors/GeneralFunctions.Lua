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

--Получить колическтво атакующих указанный юнит
function gf.GetNumAttackers(hTargetUnit)
    local attackers = 0
    local invalidTarget = not hTargetUnit or not hTargetUnit:IsAlive()
    if not invalidTarget then
        local nearbyEnemies = hTargetUnit:GetNearbyHeroes(1200, true, BOT_MODE_NONE) -- Герои в радиусе 1200

        -- Проверяем вражеских героев
        for _, enemy in ipairs(nearbyEnemies) do
            if enemy:GetAttackTarget() == hTargetUnit then
                attackers = attackers + 1
            end
        end

        -- Проверяем крипов (добавьте при необходимости)
        local nearbyCreeps = hTargetUnit:GetNearbyCreeps(1200, true)
        for _, creep in ipairs(nearbyCreeps) do
            if creep:GetAttackTarget() == hTargetUnit then
                attackers = attackers + 1
            end
        end
    end

    return attackers
end

return gf
