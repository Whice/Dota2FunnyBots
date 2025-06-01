local BotsInit = require("game/botsinit")
local MyModule = BotsInit.CreateGeneric()

local bot = GetBot()

if bot:GetUnitName() == 'npc_dota_hero_monkey_king' then
	local trueMK = nil;
	for i, id in pairs(GetTeamPlayers(GetTeam())) do
		if IsPlayerBot(id) and GetSelectedHeroName(id) == 'npc_dota_hero_monkey_king' then
			local member = GetTeamMember(i)
			if member ~= nil then
				trueMK = member
			end
		end
	end
	if trueMK ~= nil and bot ~= trueMK then
		print("AbilityItemUsage "..tostring(bot).." isn't true MK")
		return;
	elseif trueMK == nil or bot == trueMK then
		print("AbilityItemUsage "..tostring(bot).." is true MK")
	end
end

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion()
then
	return
end

local HeroInfoFile = "NOT IMPLEMENTED"

if bot:IsHero() then
	HeroInfoFile = require(GetScriptDirectory() .. "/HeroInfo/" .. string.gsub(GetBot():GetUnitName(), "npc_dota_hero_", ""));
end

local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PItems = require(GetScriptDirectory() .. "/Library/PhalanxItems")
local PIU = require(GetScriptDirectory() .. "/Library/PhalanxItemUsage")
local PChat = require(GetScriptDirectory() .. "/Library/PhalanxChat")

bot.castAmuletTime = DotaTime()

local courierTime = -90
local cState = -1
bot.SShopUser = false
local returnTime = -90
local apiAvailable = true

bot.courierID = 0
bot.courierAssigned = false
local checkCourier = false
local define_courier = false
local cr = nil
local tm =  GetTeam()
local pIDs = GetTeamPlayers(tm)

local bbtime = {}
bbtime['lastbbtime'] = -90;

function CourierUsageThink()
	if bot:GetAbilityInSlot(5):GetName() == "dazzle_nothl_projection_end" then
		return
	end
	
	if P.pIDInc < #pIDs + 1 and DotaTime() > -60 then
		if IsPlayerBot(pIDs[P.pIDInc]) == true then
			local currID = pIDs[P.pIDInc];
				if bot:GetPlayerID() == currID  then
					if checkCourier == true and DotaTime() > P.calibrateTime + 5  then
						local cst = GetCourierState(cr)
						if cst == 6 then -- 2
							P.pIDInc = P.pIDInc + 1;
							print(bot:GetUnitName().." : Courier Successfully Assigned ."..tostring(bot.courierID));
							checkCourier = false;
							bot.courierAssigned = true;
							P.calibrateTime = DotaTime();
							bot:ActionImmediate_Courier( cr, COURIER_ACTION_RETURN_STASH_ITEMS )
							return;
						else
							bot.courierID = bot.courierID + 1;
							checkCourier = false;
							P.calibrateTime = DotaTime();
						end
					elseif checkCourier == false then
						cr = GetCourier(bot.courierID);
						bot:ActionImmediate_Courier( cr, COURIER_ACTION_SECRET_SHOP )
						checkCourier = true;
					end
				end
		else
			P.pIDInc = P.pIDInc + 1;
		end
	end	
	
	if not bot.courierAssigned then
		return
	end
	
	local Courier = GetCourier(bot.courierID)
	
	if not Courier:IsAlive() or not Courier:IsCourier() then
		return
	end
	
	if GetCourierState(Courier) == COURIER_STATE_RETURNING_TO_BASE
	or GetCourierState(Courier) == COURIER_STATE_DEAD then
		return
	end
	
	if not bot:IsAlive() and GetCourierState(Courier) == COURIER_STATE_DELIVERING_ITEMS then
		bot:ActionImmediate_Courier(Courier, COURIER_ACTION_RETURN_STASH_ITEMS)
	end
	
	local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	for v, enemy in pairs(Enemies) do
		if GetUnitToUnitDistance(Courier, enemy) <= 1200 then
			bot:ActionImmediate_Courier(Courier, COURIER_ACTION_RETURN_STASH_ITEMS)
			
			local burst = Courier:GetAbilityByName("courier_burst")
			if bot:GetLevel() >= 10 and burst:IsFullyCastable() then
				bot:ActionImmediate_Courier(Courier, COURIER_ACTION_BURST)
			end
		end
	end
	
	if bot:IsAlive() and bot.SecretShop and Courier:DistanceFromFountain() < 7000 then
		bot:ActionImmediate_Courier(npcCourier, COURIER_ACTION_SECRET_SHOP)
	end
	
	local ValueThreshold = 25
	if bot:GetStashValue() > ValueThreshold or bot:GetCourierValue() > ValueThreshold then
		if GetCourierState(Courier) ~= COURIER_STATE_RETURNING_TO_BASE
		and GetCourierState(Courier) ~= COURIER_STATE_DELIVERING_ITEMS then
			if bot:GetStashValue() > ValueThreshold and bot:IsAlive() then
				bot:ActionImmediate_Courier(Courier, COURIER_ACTION_TAKE_STASH_ITEMS)
			elseif bot:GetCourierValue() > ValueThreshold then
				bot:ActionImmediate_Courier(Courier, COURIER_ACTION_TRANSFER_ITEMS)
			end
		end
	end
end

function AbilityUsageThink()
	if P.IsMeepoClone(bot) then
		HeroInfoFile = "/HeroInfo/meepo"
	end

	HeroInfoFile.UseAbilities()
end

function ItemUsageThink()
	
end

function BuybackUsageThink() 
	if bot:IsInvulnerable()
	or not bot:IsHero()
	or bot:IsIllusion()
	or P.IsMeepoClone(bot)
	or bot:HasModifier("modifier_arc_warden_tempest_double")
	or bot:GetAbilityInSlot(5):GetName() == "dazzle_nothl_projection_end"
	or ShouldBuyBack() == false then
		return;
	end
	
	if bot:IsAlive() and TimeDeath ~= nil then
		TimeDeath = nil;
	end
	
	if not bot:HasBuyback() then
		return;
	end
	
	if bot:GetUnitName() == "npc_dota_hero_vengefulspirit" then
		if bot.StrongIllusion ~= nil then
			return
		end
	end

	if not bot:IsAlive() then
		if TimeDeath == nil then
			TimeDeath = DotaTime();
		end
	end
	
	local RespawnTime = GetRemainingRespawnTime();
	
	if RespawnTime < 10 then
		return;
	end
	
	local ancient = GetAncient(GetTeam());
	
	if ancient ~= nil 
	then
		local nEnemies = GetNumEnemyNearby(ancient);
		if  nEnemies > 0 and nEnemies >= GetNumOfAliveHeroes(GetTeam()) then
			PRoles['lastbbtime'] = DotaTime();
			bot:ActionImmediate_Buyback();
			return;
		end	
	end
end

local PointLevel = 1
if DotaTime() > -90 then
	PointLevel = bot:GetLevel()
end

function AbilityLevelUpThink()
	if bot:GetAbilityInSlot(5):GetName() == "dazzle_nothl_projection_end" then
		return
	end
	
	local HumanOnTeam = false
	for v, Ally in pairs(GetTeamPlayers(bot:GetTeam())) do
		if not IsPlayerBot(Ally) then
			HumanOnTeam = true
		end
	end
	
	if not HumanOnTeam then
		UseGlyph()
	end
	
	if bot:GetUnitName() == "npc_dota_hero_life_stealer"
	and bot:HasModifier("modifier_life_stealer_infest") then
		return
	end
	
	if bot:GetUnitName() == "npc_dota_hero_morphling"
	and bot:GetAbilityInSlot(0):GetName() ~= "morphling_waveform" then
		return
	end
	
	if bot:GetUnitName() == "npc_dota_hero_jakiro" then
		if bot:GetAbilityInSlot(1):GetName() ~= "jakiro_ice_path" then
			return
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_shredder" then
		if bot:GetAbilityInSlot(5):GetName() ~= "shredder_chakram" then
			return
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_ringmaster" then
		if bot:GetAbilityInSlot(0):GetName() ~= "ringmaster_tame_the_beasts" then
			return
		end
	end

	local BotLevel = bot:GetLevel()
	local SkillPoints = HeroInfoFile.GetHeroLevelPoints()
	
	if bot:GetAbilityPoints() > 0 and BotLevel <= 30 then
		--[[if bot:GetUnitName() == "npc_dota_hero_ogre_magi" then
			if bot:GetLevel() == 2 then
				bot:ActionImmediate_LevelAbility(bot:GetAbilityInSlot(1):GetName())
				bot:ActionImmediate_LevelAbility(bot:GetAbilityInSlot(0):GetName())
				bot:ActionImmediate_LevelAbility(bot:GetAbilityInSlot(1):GetName())
				PointLevel = 2
				return
			end
			
			if bot:GetLevel() == 16 then
				bot:ActionImmediate_LevelAbility(bot:GetAbilityInSlot(5):GetName())
				PointLevel = 16
				return
			end
		end]]--
		
		if SkillPoints[PointLevel] == "NoLevel" then
			PointLevel = (PointLevel + 1)
		else
			bot:ActionImmediate_LevelAbility(SkillPoints[PointLevel])
			PointLevel = (PointLevel + 1)
		end
	end
end

-- Extra functions --

function UseGlyph()
	if GetGlyphCooldown( ) > 0 then
		return
	end	
	
	local T1 = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
		TOWER_TOP_3,
		TOWER_MID_3, 
		TOWER_BOT_3, 
		TOWER_BASE_1, 
		TOWER_BASE_2
	}
	
	for _,t in pairs(T1)
	do
		local tower = GetTower(GetTeam(), t);
		if  tower ~= nil and tower:GetHealth() > 0 and tower:GetHealth()/tower:GetMaxHealth() < 0.15 and tower:GetAttackTarget() ~=  nil
		then
			bot:ActionImmediate_Glyph( )
			return
		end
	end
	

	local MeleeBarrack = {
		BARRACKS_TOP_MELEE,
		BARRACKS_MID_MELEE,
		BARRACKS_BOT_MELEE
	}
	
	for _,b in pairs(MeleeBarrack)
	do
		local barrack = GetBarracks(GetTeam(), b);
		if barrack ~= nil and barrack:GetHealth() > 0 and barrack:GetHealth()/barrack:GetMaxHealth() < 0.5 and IsTargetedByEnemy(barrack)
		then
			bot:ActionImmediate_Glyph()
			return
		end
	end
	
	local Ancient = GetAncient(GetTeam())
	if Ancient ~= nil and Ancient:GetHealth() > 0 and Ancient:GetHealth()/Ancient:GetMaxHealth() < 0.5 and IsTargetedByEnemy(Ancient)
	then
		bot:ActionImmediate_Glyph()
		return
	end
end

function ShouldBuyBack()
	return DotaTime() > bbtime['lastbbtime'] + 2.0;
end

function GetNumEnemyNearby(building)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1]; 
				if dInfo ~= nil and GetUnitToLocationDistance(building, dInfo.location) <= 2750 and dInfo.time_since_seen < 1.0 then
					nearbynum = nearbynum + 1;
				end
			end
		end
	end
	return nearbynum;
end

function GetNumOfAliveHeroes(team)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(team)) do
		if IsHeroAlive(id) then
			nearbynum = nearbynum + 1;
		end
	end
	return nearbynum;
end

function GetRemainingRespawnTime()
	if TimeDeath == nil then
		return 0;
	else
		return bot:GetRespawnTime() - ( DotaTime() - TimeDeath );
	end
end

function GetNumOfAliveHeroes(team)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(team)) do
		if IsHeroAlive(id) then
			nearbynum = nearbynum + 1;
		end
	end
	return nearbynum;
end

function GetRemainingRespawnTime()
	if TimeDeath == nil then
		return 0;
	else
		return bot:GetRespawnTime() - ( DotaTime() - TimeDeath );
	end
end

return MyModule