local PC = {}

function PC.IsCarrySuitableToFight(bot, hero)
	local RequiredItem = nil
	
	if hero == "npc_dota_hero_naga_siren" then
		RequiredItem = "item_manta"
	end
	
	if hero == "npc_dota_hero_sven" then
		RequiredItem = "item_blink"
	end
	
	if hero == "npc_dota_hero_chaos_knight" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_skeleton_king" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_antimage" then
		RequiredItem = "item_manta"
	end
	
	if hero == "npc_dota_hero_juggernaut" then
		RequiredItem = "item_manta"
	end
	
	if hero == "npc_dota_hero_terrorblade" then
		RequiredItem = "item_skadi"
	end
	
	if hero == "npc_dota_hero_nevermore" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_bloodseeker" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_sniper" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_phantom_assassin" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_luna" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_arc_warden" then
		RequiredItem = "item_gungir"
	end
	
	if hero == "npc_dota_hero_phantom_lancer" then
		RequiredItem = "item_diffusal_blade"
	end
	
	if hero == "npc_dota_hero_life_stealer" then
		RequiredItem = "item_desolator"
	end
	
	if hero == "npc_dota_hero_sven" then
		RequiredItem = "item_blink"
	end
	
	if hero == "npc_dota_hero_medusa" then
		RequiredItem = "item_manta"
	end
	
	if hero == "npc_dota_hero_meepo" then
		RequiredItem = "item_skadi"
	end
	
	if hero == "npc_dota_hero_templar_assassin" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_lina" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_ursa" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_faceless_void" then
		RequiredItem = "item_black_king_bar"
	end
	
	if hero == "npc_dota_hero_slark" then
		RequiredItem = "item_diffusal_blade"
	end
	
	if hero == "npc_dota_hero_clinkz" then
		RequiredItem = "item_desolator"
	end
	
	if hero == "npc_dota_hero_spectre" then
		RequiredItem = "item_manta"
	end
	
	if hero == "npc_dota_hero_razor" then
		RequiredItem = "item_black_king_bar"
	end
	
	if bot:FindItemSlot(RequiredItem) == -1 then
		return false
	else
		return true
	end
end

return PC