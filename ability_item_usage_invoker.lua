------------------------------
-- CREATED BY: MANSLAUGHTER --
------------------------------

local bot = GetBot()
if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() then return end

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

-- Spell Levels
local Quas = bot:GetAbilityByName("invoker_quas")
local Wex = bot:GetAbilityByName("invoker_wex")
local Exort = bot:GetAbilityByName("invoker_exort")
local Invoke = bot:GetAbilityByName("invoker_invoke")

-- Spells
local ColdSnap = bot:GetAbilityByName("invoker_cold_snap")
local GhostWalk = bot:GetAbilityByName("invoker_ghost_walk")
local Tornado = bot:GetAbilityByName("invoker_tornado")
local EMP = bot:GetAbilityByName("invoker_emp")
local Alacrity = bot:GetAbilityByName("invoker_alacrity")
local ChaosMeteor = bot:GetAbilityByName("invoker_chaos_meteor")
local SunStrike = bot:GetAbilityByName("invoker_sun_strike")
local ForgeSpirit = bot:GetAbilityByName("invoker_forge_spirit")
local IceWall = bot:GetAbilityByName("invoker_ice_wall")
local DeafeningBlast = bot:GetAbilityByName("invoker_deafening_blast")

-- Desires
local ColdSnapDesire = 0
local GhostWalkDesire = 0
local TornadoDesire = 0
local EMPDesire = 0
local AlacrityDesire = 0
local ChaosMeteorDesire = 0
local SunStrikeDesire = 0
local ForgeSpiritDesire = 0
local IceWallDesire = 0
local DeafeningBlastDesire = 0

-- Combo Desires
local TornadoComboDesire = 0

local AttackRange
local BotTarget
local AttackRange = 0

local SunStrikeEnabled = false

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	if P.IsRetreating(bot)
	and bot:HasModifier("modifier_invoker_ghost_walk_self")
	and not bot:HasModifier("modifier_item_dustofappearance") then
		return
	end
	
	-- Prepare Sunstrike
	if not SunStrikeEnabled then
		if Exort:IsTrained() then
			SunStrikeEnabled = true
			bot:Action_ClearActions(false)
			InvokeSpell(SunStrike)
		end
	end
	
	-- Prepare Tornado combo
	if not P.IsInLaningPhase() then
		if Tornado:IsFullyCastable() and not IsActiveAbility(Tornado) and Invoke:IsFullyCastable() then
			InvokeSpell(Tornado)
		end
		if EMP:IsFullyCastable() and not IsActiveAbility(EMP) and Invoke:IsFullyCastable() then
			InvokeSpell(EMP)
		end
	end
	
	-- The order to use abilities in
	GhostWalkDesire = UseGhostWalk()
	if GhostWalkDesire > 0 then
		bot:Action_ClearActions(false)
		
		if not IsActiveAbility(GhostWalk) and Invoke:IsFullyCastable() then
			InvokeSpell(GhostWalk)
		end
	
		if IsActiveAbility(GhostWalk) then
			bot:ActionQueue_UseAbility(GhostWalk)
			return
		end
	end
	
	TornadoComboDesire, TornadoComboTarget = UseTornadoCombo()
	if TornadoComboDesire > 0 then
		bot:Action_ClearActions(false)
		bot:ActionQueue_UseAbilityOnLocation(Tornado, TornadoComboTarget)
		bot:ActionQueue_UseAbilityOnLocation(EMP, TornadoComboTarget)
		InvokeSpell(ChaosMeteor)
		bot:ActionQueue_UseAbilityOnLocation(ChaosMeteor, TornadoComboTarget)
		return
	end
	
	TornadoDesire, TornadoTarget = UseTornado()
	if TornadoDesire > 0 then
		bot:Action_ClearActions(false)
		
		if not IsActiveAbility(Tornado) and Invoke:IsFullyCastable() then
			InvokeSpell(Tornado)
		end
	
		if IsActiveAbility(Tornado) then
			bot:ActionQueue_UseAbilityOnLocation(Tornado, TornadoTarget)
			return
		end
	end
	
	EMPDesire, EMPTarget = UseEMP()
	if EMPDesire > 0 then
		bot:Action_ClearActions(false)
		
		if not IsActiveAbility(EMP) and Invoke:IsFullyCastable() then
			InvokeSpell(EMP)
		end
	
		if IsActiveAbility(EMP) then
			bot:ActionQueue_UseAbilityOnLocation(EMP, EMPTarget)
			return
		end
	end
	
	ChaosMeteorDesire, ChaosMeteorTarget = UseChaosMeteor()
	if ChaosMeteorDesire > 0 then
		if not IsActiveAbility(ChaosMeteor) and Invoke:IsFullyCastable() then
			InvokeSpell(ChaosMeteor)
		end
	
		if IsActiveAbility(ChaosMeteor) then
			bot:ActionQueue_UseAbilityOnLocation(ChaosMeteor, ChaosMeteorTarget)
			return
		end
	end
	
	ColdSnapDesire, ColdSnapTarget = UseColdSnap()
	if ColdSnapDesire > 0 then
		bot:Action_ClearActions(false)
		
		if not IsActiveAbility(ColdSnap) and Invoke:IsFullyCastable() then
			InvokeSpell(ColdSnap)
		end
	
		if IsActiveAbility(ColdSnap) then
			bot:ActionQueue_UseAbilityOnEntity(ColdSnap, ColdSnapTarget)
			return
		end
	end
	
	AlacrityDesire, AlacrityTarget = UseAlacrity()
	if AlacrityDesire > 0 then
		bot:Action_ClearActions(false)
		
		if not IsActiveAbility(Alacrity) and Invoke:IsFullyCastable() then
			InvokeSpell(Alacrity)
		end
	
		if IsActiveAbility(Alacrity) then
			bot:ActionQueue_UseAbilityOnEntity(Alacrity, AlacrityTarget)
			return
		end
	end
	
	IceWallDesire = UseIceWall()
	if IceWallDesire > 0 then
		bot:Action_ClearActions(false)
		
		if not IsActiveAbility(IceWall) and Invoke:IsFullyCastable() then
			InvokeSpell(IceWall)
		end
	
		if IsActiveAbility(IceWall) then
			bot:ActionQueue_UseAbility(IceWall)
			return
		end
	end
	
	DeafeningBlastDesire, DeafeningBlastTarget = UseDeafeningBlast()
	if DeafeningBlastDesire > 0 then
		bot:Action_ClearActions(false)
		
		if not IsActiveAbility(DeafeningBlast) and Invoke:IsFullyCastable() then
			InvokeSpell(DeafeningBlast)
		end
	
		if IsActiveAbility(DeafeningBlast) then
			if bot:GetLevel() < 25 then
				bot:ActionQueue_UseAbilityOnLocation(DeafeningBlast, DeafeningBlastTarget)
			else
				bot:ActionQueue_UseAbility(DeafeningBlast)
			end
		end
		
		return
	end
	
	SunStrikeDesire, SunStrikeTarget = UseSunStrike()
	if SunStrikeDesire > 0 then
		bot:Action_ClearActions(false)
		
		if not IsActiveAbility(SunStrike) and Invoke:IsFullyCastable() then
			InvokeSpell(SunStrike)
		end
	
		if IsActiveAbility(SunStrike) then
			bot:ActionQueue_UseAbilityOnLocation(SunStrike, SunStrikeTarget)
			return
		end
	end
	
	ForgeSpiritDesire = UseForgeSpirit()
	if ForgeSpiritDesire > 0 then
		bot:Action_ClearActions(false)
		
		if not IsActiveAbility(ForgeSpirit) and Invoke:IsFullyCastable() then
			InvokeSpell(ForgeSpirit)
		end
	
		if IsActiveAbility(ForgeSpirit) then
			bot:ActionQueue_UseAbility(ForgeSpirit)
			return
		end
	end
end

function InvokeSpell(SpellToInvoke)
	local x = nil
	local y = nil
	local z = nil

	if SpellToInvoke == ColdSnap then
		x = Quas
		y = Quas
		z = Quas
	end
	if SpellToInvoke == GhostWalk then
		x = Quas
		y = Quas
		z = Wex
	end
	if SpellToInvoke == IceWall then
		x = Quas
		y = Quas
		z = Exort
	end
	if SpellToInvoke == EMP then
		x = Wex
		y = Wex
		z = Wex
	end
	if SpellToInvoke == Tornado then
		x = Wex
		y = Wex
		z = Quas
	end
	if SpellToInvoke == Alacrity then
		x = Wex
		y = Wex
		z = Exort
	end
	if SpellToInvoke == DeafeningBlast then
		x = Quas
		y = Wex
		z = Exort
	end
	if SpellToInvoke == SunStrike then
		x = Exort
		y = Exort
		z = Exort
	end
	if SpellToInvoke == ForgeSpirit then
		x = Exort
		y = Exort
		z = Quas
	end
	if SpellToInvoke == ChaosMeteor then
		x = Exort
		y = Exort
		z = Wex
	end
	
	bot:ActionQueue_UseAbility(x)
	bot:ActionQueue_UseAbility(y)
	bot:ActionQueue_UseAbility(z)
	bot:ActionQueue_UseAbility(Invoke)
end

function IsActiveAbility(SpellToCheck)
	if SpellToCheck:IsHidden() then
		return false
	else
		return true
	end
end

function CanCastTornadoCombo()
	if Quas:IsTrained()
	and Wex:IsTrained()
	and Exort:IsTrained()
	and Tornado:IsFullyCastable()
	and EMP:IsFullyCastable()
	and ChaosMeteor:IsFullyCastable()
	and IsActiveAbility(Tornado)
	and IsActiveAbility(EMP) then
		local TotalManaCost = 0
		
		TotalManaCost = (TotalManaCost + Tornado:GetManaCost())
		TotalManaCost = (TotalManaCost + EMP:GetManaCost())
		TotalManaCost = (TotalManaCost + ChaosMeteor:GetManaCost())
		
		if bot:GetMana() > TotalManaCost then
			return true
		end
	end
	
	return false
end

function UseTornadoCombo()
	if not CanCastTornadoCombo() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ComboCastRange = EMP:GetCastRange()
	local ComboRadius = Tornado:GetSpecialValueInt("area_of_effect")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), ComboCastRange, ComboRadius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function UseSunStrike()
	if not SunStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Exort:IsTrained() then return 0 end
	
	local Damage = SunStrike:GetSpecialValueInt("damage")
	local SSDelay = SunStrike:GetSpecialValueInt("delay")
	
	local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
	
	for v, Enemy in pairs(FilteredEnemies) do
		if PAF.IsValidHeroTarget(Enemy) then
			if Damage > Enemy:GetHealth()
			and GetUnitToUnitDistance(bot, Enemy) > (AttackRange + 50) then
				return BOT_MODE_DESIRE_HIGH, Enemy:GetExtrapolatedLocation(SSDelay)
			end
		end
	end
	
	return 0
end

function UseColdSnap()
	if not ColdSnap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Quas:IsTrained() then return 0 end
	
	local CR = ColdSnap:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end

function UseAlacrity()
	if not Alacrity:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Wex:IsTrained() then return 0 end
	if not Exort:IsTrained() then return 0 end
	
	local CR = Alacrity:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local StrongestAlly = PAF.GetStrongestAttackDamageUnit(FilteredAllies)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if StrongestAlly ~= nil
			and GetUnitToUnitDistance(StrongestAlly, BotTarget) <= (StrongestAlly:GetAttackRange() + 100) then
				return BOT_ACTION_DESIRE_HIGH, StrongestAlly
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, StrongestAlly
			end
		end
		
		if AttackTarget:IsBuilding() and AttackTarget:GetTeam() ~= bot:GetTeam() then
			local CreepsWithinRange = bot:GetNearbyCreeps(CastRange, false)
			
			for v, Creep in pairs(CreepsWithinRange) do
				if Creep:GetAttackTarget() == AttackTarget then
					if string.find(Creep:GetUnitName(), "siege") then
						return BOT_ACTION_DESIRE_HIGH, Creep
					end
					
					if string.find(Creep:GetUnitName(), "forged_spirit") then
						return BOT_ACTION_DESIRE_HIGH, Creep
					end
				end
			end
			
			if StrongestAlly ~= nil and StrongestAlly:GetAttackTarget() == AttackTarget then
				return BOT_ACTION_DESIRE_HIGH, StrongestAlly
			end
		end
	end
	
	return 0
end

function UseIceWall()
	if not IceWall:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Quas:IsTrained() then return 0 end
	if not Exort:IsTrained() then return 0 end
	
	local PlaceDistance = IceWall:GetSpecialValueInt("wall_place_distance")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(PlaceDistance, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		if #FilteredEnemies > 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if P.IsRetreating(bot) then
		if bot:HasModifier("modifier_invoker_ghost_walk_self")
		and not bot:HasModifier("modifier_item_dustofappearance") then
			-- Do nothing
		else
			local EnemiesWithinRetreatRange = bot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
			local FilteredRetreatEnemies = PAF.FilterUnitsForStun(EnemiesWithinRetreatRange)
		
			if #FilteredRetreatEnemies > 0 and bot:IsFacingLocation(PAF.GetFountainLocation(bot), 20) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= PlaceDistance then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget
			end
		end
	end
	
	return 0
end

function UseDeafeningBlast()
	if not DeafeningBlast:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Quas:IsTrained() then return 0 end
	if not Wex:IsTrained() then return 0 end
	if not Exort:IsTrained() then return 0 end
	
	local CR = DeafeningBlast:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	local StrongestEnemy = PAF.GetStrongestAttackDamageUnit(FilteredEnemies)
	
	if PAF.IsInTeamFight(bot) then
		if StrongestEnemy ~= nil then
			return BOT_ACTION_DESIRE_HIGH, StrongestEnemy:GetLocation()
		end
	end
	
	if P.IsRetreating(bot) then
		if bot:HasModifier("modifier_invoker_ghost_walk_self")
		and not bot:HasModifier("modifier_item_dustofappearance") then
			-- Do nothing
		else
			if StrongestEnemy ~= nil then
				return BOT_ACTION_DESIRE_HIGH, StrongestEnemy:GetLocation()
			end
		end
	end
	
	return 0
end

function UseGhostWalk()
	if not GhostWalk:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Quas:IsTrained() then return 0 end
	if not Wex:IsTrained() then return 0 end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseForgeSpirit()
	if not ForgeSpirit:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Quas:IsTrained() then return 0 end
	if not Exort:IsTrained() then return 0 end
	
	local MaxForgedSpiritCount = ForgeSpirit:GetSpecialValueInt("spirit_count")
	local CreepsWithinRange = bot:GetNearbyCreeps(1600, false)
	local ForgedSpiritCount = 0
	
	for v, Ally in pairs(CreepsWithinRange) do
		if string.find(Ally:GetUnitName(), "forged_spirit") then
			ForgedSpiritCount = (ForgedSpiritCount + 1)
		end
	end
	
	if ForgedSpiritCount < MaxForgedSpiritCount then
		if PAF.IsEngaging(bot) then
			return BOT_ACTION_DESIRE_HIGH
		end
		
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil then
			if bot:GetActiveMode() == BOT_MODE_FARM
			or bot:GetActiveMode() == BOT_MODE_PUSH_TOP
			or bot:GetActiveMode() == BOT_MODE_PUSH_MID
			or bot:GetActiveMode() == BOT_MODE_PUSH_BOT then
				if AttackTarget:IsCreep()
				or AttackTarget:IsBuilding() then
					if AttackTarget:GetTeam() ~= bot:GetTeam() then
						return BOT_ACTION_DESIRE_HIGH
					end
				end
			end
		end
	end
	
	return 0
end

function UseTornado()
	if not Tornado:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Quas:IsTrained() then return 0 end
	if not Wex:IsTrained() then return 0 end
	if CanCastTornadoCombo() then return 0 end
	
	local TravelDistance = Tornado:GetSpecialValueInt("travel_distance")
	local TornadoRadius = Tornado:GetSpecialValueInt("area_of_effect")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), TravelDistance, TornadoRadius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		if bot:HasModifier("modifier_invoker_ghost_walk_self")
		and not bot:HasModifier("modifier_item_dustofappearance") then
			-- Do nothing
		else
			local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
			return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
		end
	end
	
	return 0
end

function UseEMP()
	if not EMP:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Wex:IsTrained() then return 0 end
	if CanCastTornadoCombo() then return 0 end
	
	local CR = EMP:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local EMPRadius = EMP:GetSpecialValueInt("area_of_effect")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, EMPRadius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function UseChaosMeteor()
	if not ChaosMeteor:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not Exort:IsTrained() then return 0 end
	if not Wex:IsTrained() then return 0 end
	if CanCastTornadoCombo() then return 0 end
	
	local CR = ChaosMeteor:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local ChaosMeteorRadius = ChaosMeteor:GetSpecialValueInt("area_of_effect")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, ChaosMeteorRadius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end