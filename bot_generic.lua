function Think()
    local bot = GetBot()
    if bot:IsChanneling() then return end -- Не прерывать касты

    -- 1. Проверка безопасности
    if ShouldRetreat(bot) then
        bot:SetNextAction(MoveToSafeSpot())
        return
    end

    -- 2. Фарм крипов
    local creep = FindFarmTarget(bot)
    if creep ~= nil then
        -- 3. Выбор: атаковать или добить?
        if CanLastHit(bot, creep) then
            bot:SetNextAction(AttackCreep(creep)) -- Добивание
        else
            bot:SetNextAction(AttackCreep(creep)) -- Обычная атака
        end
        return
    end

    -- 3. Денай союзных крипов
    local denyTarget = FindDenyTarget(bot)
    if denyTarget ~= nil and CanDeny(bot, denyTarget) then
        bot:SetNextAction(AttackCreep(denyTarget))
        return
    end

    -- 4. Позиционирование
    bot:SetNextAction(AdjustPosition(bot))
end

function FindFarmTarget(bot)
    local creeps = bot:GetNearbyCreeps(1000, true) -- Вражеские крипы
    for _, creep in pairs(creeps) do
        if creep:GetHealth() > 0 and not creep:IsAncient() then
            return creep -- Первый доступный крип
        end
    end
    return nil
end

function CanLastHit(bot, creep)
    local dmg = bot:GetAttackDamage()
    local timeToHit = (GetDistance(bot, creep) / bot:GetAttackSpeed()) + 0.1 -- Задержка
    local predictedHP = creep:GetHealth() - GetIncomingDamage(creep)         -- Учет входящего урона

    -- Добивание возможно, если урон бота убьет крипа
    return predictedHP <= dmg and predictedHP > 0
end

function AdjustPosition(bot)
    local laneFront = GetLaneFrontLocation() -- Точка фронта линии
    local safePos = GetSafeSpot(bot) -- Безопасная позиция
    
    -- Держаться рядом с крипами, но не слишком близко к врагам
    if GetDistance(bot, laneFront) > 600 then
        return BOT_ACTION_DESIRE_MEDIUM, safePos
    end
    return BOT_ACTION_DESIRE_NONE
end