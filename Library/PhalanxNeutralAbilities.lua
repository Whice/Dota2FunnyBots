local PNA = {}

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

function PNA.UseNeutralAbility(hAbility, bot, hCastingUnit)
	local BotTarget = bot:GetTarget()
	
	if hCastingUnit:IsCreep() and not PAF.IsEngaging(bot) then
		BotTarget = hCastingUnit:GetAttackTarget()
	end
	
	if not hAbility:IsFullyCastable() then
		return false
	end
	
	--[[if BotTarget == nil then
		return
	end]]--
	
	-- Hellbear Smasher
	if hAbility:GetName() == "polar_furbolg_ursa_warrior_thunder_clap" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetSpecialValueInt("radius")
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= (CastRange - 100)
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbility(hAbility)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Satyr Tormenter
	if hAbility:GetName() == "satyr_hellcaller_shockwave" then
		--if hCastingUnit:IsHero() then
			
			local CastRange = hAbility:GetCastRange()
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, BotTarget)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Centaur Conqueror
	if hAbility:GetName() == "centaur_khan_war_stomp" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetSpecialValueInt("radius")
			
			local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
			local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
			
			for v, Enemy in pairs(FilteredEnemies) do
				if GetUnitToUnitDistance(Enemy, hCastingUnit) <= CastRange then
					if Enemy:IsChanneling() then
						hCastingUnit:Action_UseAbility(hAbility)
						return true
					end
				end
			end
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= (CastRange - 100)
				and not PAF.IsMagicImmune(BotTarget)
				and not PAF.IsDisabled(BotTarget) then
					hCastingUnit:Action_UseAbility(hAbility)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Satyr Mindstealer
	if hAbility:GetName() == "satyr_soulstealer_mana_burn" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, BotTarget)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Satyr Banisher
	if hAbility:GetName() == "satyr_trickster_purge" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
			local FilteredAllies = PAF.FilterTrueUnits(Allies)
			
			for v, Ally in pairs(FilteredAllies) do
				if GetUnitToUnitDistance(Ally, hCastingUnit) <= CastRange then
					if Ally:IsSilenced() or Ally:IsRooted() then
						hCastingUnit:Action_UseAbilityOnEntity(hAbility, Ally)
						return true
					end
				end
			end
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, BotTarget)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Wildwing Ripper
	if hAbility:GetName() == "enraged_wildkin_hurricane" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
			local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
			
			for v, Enemy in pairs(FilteredEnemies) do
				if GetUnitToUnitDistance(Enemy, hCastingUnit) <= CastRange then
					if Enemy:IsChanneling() then
						hCastingUnit:Action_UseAbilityOnEntity(hAbility, Enemy)
						return true
					end
				end
			end
			
			return false
		--end
	end
	
	-- Wildwing
	if hAbility:GetName() == "enraged_wildkin_tornado" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbilityOnLocation(hAbility, BotTarget:GetLocation())
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Fell Spirit
	if hAbility:GetName() == "fel_beast_haunt" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
			local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
			
			for v, Enemy in pairs(FilteredEnemies) do
				if GetUnitToUnitDistance(Enemy, hCastingUnit) <= CastRange then
					if Enemy:IsChanneling() then
						hCastingUnit:Action_UseAbilityOnEntity(hAbility, Enemy)
						return true
					end
				end
			end
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget)
				and not BotTarget:IsSilenced()
				and not PAF.IsDisabled(BotTarget) then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, BotTarget)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Mud Golem
	if hAbility:GetName() == "mud_golem_hurl_boulder" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
			local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
			
			for v, Enemy in pairs(FilteredEnemies) do
				if GetUnitToUnitDistance(Enemy, hCastingUnit) <= CastRange then
					if Enemy:IsChanneling() then
						hCastingUnit:Action_UseAbilityOnEntity(hAbility, Enemy)
						return true
					end
				end
			end
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget)
				and not PAF.IsDisabled(BotTarget) then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, BotTarget)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Mud Golem
	if hAbility:GetName() == "mud_golem_hurl_boulder" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
			local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
			
			for v, Enemy in pairs(FilteredEnemies) do
				if GetUnitToUnitDistance(Enemy, hCastingUnit) <= CastRange then
					if Enemy:IsChanneling() then
						hCastingUnit:Action_UseAbilityOnEntity(hAbility, Enemy)
						return true
					end
				end
			end
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget)
				and not PAF.IsDisabled(BotTarget) then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, BotTarget)
					return true
				end
			end
			
			return
		--end
	end
	
	-- Dark Troll Summoner
	if hAbility:GetName() == "dark_troll_warlord_raise_dead" then
		--if hCastingUnit:IsHero() then
			
			hCastingUnit:Action_UseAbility(hAbility)
			return true
			
		--end
	end
	
	-- Hill Troll
	if hAbility:GetName() == "dark_troll_warlord_ensnare" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget)
				and not PAF.IsDisabled(BotTarget) then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, BotTarget)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Warpine Raider
	if hAbility:GetName() == "warpine_raider_seed_shot" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, BotTarget)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Giant Wolf
	if hAbility:GetName() == "giant_wolf_intimidate" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetSpecialValueInt("radius")
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= (CastRange - 100)
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbility(hAbility)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Croakers
	if hAbility:GetName() == "frogmen_arm_of_the_deep" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
			local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
			
			for v, Enemy in pairs(FilteredEnemies) do
				if GetUnitToUnitDistance(Enemy, hCastingUnit) <= CastRange then
					if Enemy:IsChanneling() then
						hCastingUnit:Action_UseAbilityOnLocation(hAbility, Enemy:GetLocation())
						return true
					end
				end
			end
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget)
				and not PAF.IsDisabled(BotTarget) then
					hCastingUnit:Action_UseAbilityOnLocation(hAbility, BotTarget:GetLocation())
					return true
				end
			end
			
			return false
		--end
	end
	
	if hAbility:GetName() == "frogmen_tendrils_of_the_deep" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
			local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
			
			for v, Enemy in pairs(FilteredEnemies) do
				if GetUnitToUnitDistance(Enemy, hCastingUnit) <= CastRange then
					if Enemy:IsChanneling() then
						hCastingUnit:Action_UseAbilityOnLocation(hAbility, Enemy:GetLocation())
						return true
					end
				end
			end
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget)
				and not PAF.IsDisabled(BotTarget) then
					hCastingUnit:Action_UseAbilityOnLocation(hAbility, BotTarget:GetLocation())
					return true
				end
			end
			
			return false
		--end
	end
	
	if hAbility:GetName() == "frogmen_congregation_of_the_deep" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetSpecialValueInt("range")
			
			local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
			local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
			
			for v, Enemy in pairs(FilteredEnemies) do
				if GetUnitToUnitDistance(Enemy, hCastingUnit) <= CastRange then
					if Enemy:IsChanneling() then
						hCastingUnit:Action_UseAbility(hAbility)
						return true
					end
				end
			end
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= (CastRange - 100)
				and not PAF.IsMagicImmune(BotTarget)
				and not PAF.IsDisabled(BotTarget) then
					hCastingUnit:Action_UseAbility(hAbility)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Marshmage
	if hAbility:GetName() == "frogmen_water_bubble_small"
	or hAbility:GetName() == "frogmen_water_bubble_medium"
	or hAbility:GetName() == "frogmen_water_bubble_large" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
			local FilteredAllies = PAF.FilterTrueUnits(Allies)
			
			for v, Ally in pairs(FilteredAllies) do
				if GetUnitToUnitDistance(Ally, hCastingUnit) <= CastRange then
					if Ally:WasRecentlyDamagedByAnyHero(1)
					and Ally:GetHealth() < (Ally:GetMaxHealth() * 0.75) then
						hCastingUnit:Action_UseAbilityOnEntity(hAbility, Ally)
						return true
					end
				end
			end
			
			return false
		--end
	end
	
	-- Ogre Bruiser
	if hAbility:GetName() == "ogre_bruiser_ogre_smash" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetSpecialValueInt("radius")
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget)
				and PAF.IsDisabled(BotTarget) then
					hCastingUnit:Action_UseAbilityOnLocation(hAbility, hCastingUnit:GetLocation())
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Ogre Frostmage
	if hAbility:GetName() == "ogre_magi_frost_armor" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
			local FilteredAllies = PAF.FilterTrueUnits(Allies)
			
			for v, Ally in pairs(FilteredAllies) do
				if GetUnitToUnitDistance(Ally, hCastingUnit) <= CastRange then
					if Ally:WasRecentlyDamagedByAnyHero(1)
					and Ally:GetHealth() < (Ally:GetMaxHealth() * 0.75) then
						hCastingUnit:Action_UseAbilityOnEntity(hAbility, Ally)
						return true
					end
				end
			end
			
			return false
		--end
	end
	
	-- Ancient Black Dragon
	if hAbility:GetName() == "black_dragon_fireball" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbilityOnLocation(hAbility, BotTarget:GetLocation())
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Ancient Thunderhide
	if hAbility:GetName() == "big_thunder_lizard_slam" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetSpecialValueInt("radius")
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= (CastRange - 100)
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbility(hAbility)
					return true
				end
			end
			
			return false
		--end
	end
	
	if hAbility:GetName() == "big_thunder_lizard_frenzy" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
			local FilteredAllies = PAF.FilterTrueUnits(Allies)
			
			local NearbyAllies = {}
			
			for v, Ally in pairs(FilteredAllies) do
				if GetUnitToUnitDistance(Ally, hCastingUnit) <= CastRange then
					table.insert(NearbyAllies, Ally)
				end
			end
			
			local StrongestAlly = PAF.GetStrongestDPSUnit(NearbyAllies)
			
			if StrongestAlly ~= nil then
				local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
				local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
				
				for v, Enemy in pairs(FilteredEnemies) do
					if GetUnitToUnitDistance(Enemy, hCastingUnit) <= 1200 then
						hCastingUnit:Action_UseAbilityOnEntity(hAbility, hCastingUnit) -- Possibly bugged?
						return true
					end
				end
			end
			
			return false
		--end
	end
	
	-- Ancient Prowler Shaman
	if hAbility:GetName() == "spawnlord_master_stomp" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetSpecialValueInt("radius")
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= (CastRange - 100)
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbility(hAbility)
					return true
				end
			end
			
			return false
		--end
	end
	
	if hAbility:GetName() == "spawnlord_master_freeze" then
		--if hCastingUnit:IsHero() then
		
			--[[local AttackTarget = hCastingUnit:GetAttackTarget()
	
			if AttackTarget ~= nil then
				if AttackTarget:IsHero() then
					if hAbility:GetAutoCastState() == false then
						hAbility:ToggleAutoCast()
					else
						return false
					end
				end
			end
			
			if hAbility:GetAutoCastState() == true then
				hAbility:ToggleAutoCast()
			end]]--
			
			return false
		--end
	end
	
	-- Harpy Stormcrafter
	if hAbility:GetName() == "harpy_storm_chain_lightning" then
		--if hCastingUnit:IsHero() then
		
			local CastRange = hAbility:GetCastRange()
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(hCastingUnit, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget) then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, BotTarget)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Ancient Ice Shaman
	if hAbility:GetName() == "ice_shaman_incendiary_bomb" then
		--if hCastingUnit:IsHero() then
		
			local AttackTarget = hCastingUnit:GetAttackTarget()
			
			if AttackTarget ~= nil then
				if AttackTarget:IsHero() or AttackTarget:IsBuilding() then
					hCastingUnit:Action_UseAbilityOnEntity(hAbility, AttackTarget)
					return true
				end
			end
			
			return false
		--end
	end
	
	-- Hill Troll Priest
	if hAbility:GetName() == "forest_troll_high_priest_heal" then
		--if hCastingUnit:IsHero() then
			local CastRange = hAbility:GetCastRange()
			local HealAmount = 100
			
			local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
			local FilteredAllies = PAF.FilterTrueUnits(Allies)
			
			local NearbyAllies = {}
			
			for v, Ally in pairs(FilteredAllies) do
				if GetUnitToUnitDistance(Ally, hCastingUnit) <= CastRange then
					table.insert(NearbyAllies, Ally)
				end
			end
			
			if #NearbyAllies > 0 then
				local WeakestAlly = PAF.GetWeakestUnit(NearbyAllies)
				
				if WeakestAlly ~= nil then
					if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() - (HealAmount * 2)) then
						hCastingUnit:Action_UseAbilityOnEntity(hAbility, WeakestAlly)
						return true
					end
				end
			end
			
			return false
		--end
	end
	
	return false
end

return PNA