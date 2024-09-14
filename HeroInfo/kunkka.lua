X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Torrent = bot:GetAbilityByName("kunkka_torrent")
local Tidebringer = bot:GetAbilityByName("kunkka_tidebringer")
local XMarksTheSpot = bot:GetAbilityByName("kunkka_x_marks_the_spot")
local Ghostship = bot:GetAbilityByName("kunkka_ghostship")
local XMTSReturn = bot:GetAbilityByName("kunkka_return")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Torrent:GetName())
	table.insert(abilities, Tidebringer:GetName())
	if XMarksTheSpot:IsHidden() then
		table.insert(abilities, XMTSReturn:GetName())
	else
		table.insert(abilities, XMarksTheSpot:GetName())
	end
	table.insert(abilities, Ghostship:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[1], -- Level 2
	abilities[2], -- Level 3
	abilities[3], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[3],   -- Level 15
	abilities[1], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuySphere("item_shivas_guard")
		
		ItemBuild = { 
		"item_bracer",
		"item_magic_wand",
		"item_phase_boots",
		
		"item_blade_mail",
		"item_ultimate_scepter",
		"item_black_king_bar",
		"item_bloodstone",
		SituationalItem1,
		"item_ultimate_scepter_2",
		"item_octarine_core",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
		
		ItemBuild = { 
		"item_bracer",
		"item_magic_wand",
		"item_phase_boots",
		
		CoreItem,
		"item_blade_mail",
		"item_ultimate_scepter",
		"item_black_king_bar",
		"item_heavens_halberd",
		"item_ultimate_scepter_2",
		"item_assault",
		}
	end
	
	return ItemBuild
end

return X