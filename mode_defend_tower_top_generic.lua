local PDefend = require(GetScriptDirectory() .. "/Library/PhalanxDefend")

local bot = GetBot()

function GetDesire()
  return PDefend.GetDefendDesire(bot, LANE_TOP)
end