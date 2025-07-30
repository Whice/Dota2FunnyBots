local selfBot
local botSlotNumber
local botNumberInTeam
local stateLaning = true
local LaneTypes = 
{
    EASE  =1,
    MID  =2,
    HARD  =3
}
local laneType

function IsRadiant(bot)
    return bot:GetTeam()== TEAM_RADIANT
end
function GetConcreteLineByLaneType(bot)
    local isRadiant = IsRadiant(bot)

    if(laneType == LaneTypes.MID) then
            return LANE_MID      
    end
    if(laneType == LaneTypes.EASE) then
        if isRadiant then
            return LANE_BOT
        else
            return LANE_TOP            
        end
    end
    if(laneType == LaneTypes.HARD) then
        if isRadiant then
            return LANE_TOP
        else
            return LANE_BOT        
        end
    end

end

function SetLaneType()
    
        local or15 = botNumberInTeam == 1 or botNumberInTeam == 5
        local or34 = botNumberInTeam == 3 or botNumberInTeam == 4
        local is2 = botNumberInTeam == 2
        if or15  then
    laneType = LaneTypes.EASE
        end
        if or34 then
            laneType = LaneTypes.HARD
        else
            laneType = LaneTypes.MID
        end
end
function SendMsg(message)
    selfBot:ActionImmediate_Chat( message, false)
end
function SendMsgAll(message)
    selfBot:ActionImmediate_Chat( message, true)
end
function IsNecrolyte(bot)
    if bot ~= nil and bot:IsHero() then
        return bot:GetUnitName() == "npc_dota_hero_necrolyte"
    end
    return false
end

--Функция, чтобы отправить бота на линию за крипами
function SetFrontOnLine()
    local line  = GetConcreteLineByLaneType(selfBot)
        selfBot:Action_MoveToLocation(GetLaneFrontLocation(selfBot:GetTeam(), line, -600))  
end

function IsAnyCreepNear()

    --  `float GetUnitToUnitDistanceSqr( hUnit1, hUnit2 )` - Возвращает квадрат расстояния между двумя юнитами (оптимизировано для сравнений).
    --{ hUnit, ... } GetNearbyCreeps( nRadius, bEnemies ) - Крипы в радиусе (до 1600).


    local nearDistance = 1000
    local nearDistanceSqr = nearDistance*nearDistance


end

local isNamePrint = false

function Think()
    if selfBot == nil then
    selfBot = GetBot()

    botSlotNumber = selfBot:GetPlayerID()
if botSlotNumber<5 then
    botNumberInTeam = botSlotNumber+1
else
    botNumberInTeam = botSlotNumber-4
end
SetLaneType()
    end

if not isNamePrint then
    --SendMsgAll("My slot: "..botSlotNumber)
    SendMsgAll("My pos: "..botNumberInTeam)
    local line  = GetConcreteLineByLaneType(selfBot)
    SendMsgAll("My line: "..line)
    isNamePrint = true
end

    if(stateLaning) then        
        if selfBot:IsChanneling() then return end -- Не прерывать касты
        
        local creepMinHp = 99999
        local hMinHpCreep = nil
        for _, creep in pairs(selfBot:GetNearbyCreeps(1000, true)) do
            local hp = creep:GetHealth()
            if hp < creepMinHp then
                creepMinHp = hp
                hMinHpCreep = creep
            end
        end

        if(hMinHpCreep==nil)then
        SetFrontOnLine()
    else
        local damage  = selfBot:GetAttackDamage()
        if creepMinHp <= damage then
            --Action_AttackUnit( hUnit, bOnce ) - Приказывает атаковать юнита. При bOnce=true останавливается после одной атаки.
            selfBot:Action_AttackUnit(hMinHpCreep, true)

        end
    end
        
    end
end