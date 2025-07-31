

gf = {}
gf.selfBot = GetBot()


function gf.SendMsg(message)
    gf.selfBot:ActionImmediate_Chat(message, false)
end

function gf.SendMsgAll(message)
    gf.selfBot:ActionImmediate_Chat(message, true)
end
function gf.IsRadiant(bot)
    return bot:GetTeam()== TEAM_RADIANT
end

return gf