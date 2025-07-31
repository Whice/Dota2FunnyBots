

gf = {}


function gf.SendMsg(bot, message)
    bot:ActionImmediate_Chat(message, false)
end

function gf.SendMsgAll(bot, message)
    bot:ActionImmediate_Chat(message, true)
end
function gf.IsRadiant(bot)
    return bot:GetTeam()== TEAM_RADIANT
end

return gf