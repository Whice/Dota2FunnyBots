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

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PItems = require(GetScriptDirectory() .. "/Library/PhalanxItems")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PChat = require(GetScriptDirectory() .. "/Library/PhalanxChat")

bot.itemToBuy = {};
bot.currentItemToBuy = nil;
bot.currentComponentToBuy = nil;
bot.currListItemToBuy = {};
bot.SecretShop = false;
bot.SideShop = false;
local unitName = bot:GetUnitName();

---Update the status to prevent bots selling stout shield and queling blade
bot.buildBFury = false;
bot.buildVanguard = false;
bot.buildHoly = false;

for i=1, math.ceil(#bot.itemToBuy/2) do
	if bot.itemToBuy[i] == "item_bfury" or bot.itemToBuy[#bot.itemToBuy-i+1] == "item_bfury" then
		bot.buildBFury = true;
	end
	if bot.itemToBuy[i] == "item_vanguard" or bot.itemToBuy[#bot.itemToBuy-i+1] == "item_vanguard" 
	or bot.itemToBuy[i] == "item_crimson_guard" or bot.itemToBuy[#bot.itemToBuy-i+1] == "item_crimson_guard"
	or bot.itemToBuy[i] == "item_abyssal_blade" or bot.itemToBuy[#bot.itemToBuy-i+1] == "item_abyssal_blade"
	then
		bot.buildVanguard = true;
	end
	if bot.itemToBuy[i] == "item_holy_locket" or bot.itemToBuy[#bot.itemToBuy-i+1] == "item_holy_locket" then
		bot.buildHoly = true;
	end
end

local courier = nil;
local buytime = -90;
local check_time = -90;

local lastItemToBuy = nil;
local CanPurchaseFromSecret = false;
local CanPurchaseFromSide = false;
local itemCost = 0;
local courier = nil;
local t3AlreadyDamaged = false;
local t3Check = -90;

--General item purchase logic
local function GeneralPurchase()

	--Cache all needed item properties when the last item to buy not equal to current item component to buy
	if lastItemToBuy ~= bot.currentComponentToBuy then
		lastItemToBuy = bot.currentComponentToBuy;
		bot:SetNextItemPurchaseValue( GetItemCost( bot.currentComponentToBuy ) );
		CanPurchaseFromSecret = IsItemPurchasedFromSecretShop(bot.currentComponentToBuy);
		itemCost = GetItemCost( bot.currentComponentToBuy );
		lastItemToBuy = bot.currentComponentToBuy ;
	end
	
	local cost = itemCost;
	
	--Save the gold for buyback whenever a tier 3 tower damaged or destroyed
	if t3AlreadyDamaged == false and DotaTime() > t3Check + 1.0 then
		for i=2, 8, 3 do
			local tower = GetTower(GetTeam(), i);
			if tower == nil or tower:GetHealth()/tower:GetMaxHealth() < 0.5 then
				t3AlreadyDamaged = true;
				break;
			end
		end
		t3Check = DotaTime();
	elseif t3AlreadyDamaged == true and bot:GetBuybackCooldown() <= 30 then
		cost = itemCost + bot:GetBuybackCost() + 100; 
		--( 200 + bot:GetNetWorth()/12 );
	end
	
	--buy the item if we have the gold
	if ( bot:GetGold() >= cost ) then
		
		if courier == nil and bot.courierAssigned == true then
			courier = GetCourier(bot.courierID);
		end
		
		--purchase done by courier for secret shop item
		if bot.SecretShop and courier ~= nil and GetCourierState(courier) == COURIER_STATE_IDLE and courier:DistanceFromSecretShop() == 0 then
			if courier:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) == PURCHASE_ITEM_SUCCESS then
				bot.currentComponentToBuy = nil;
				bot.currListItemToBuy[#bot.currListItemToBuy] = nil; 
				courier.latestUser = bot;
				bot.SecretShop = false;
				return
			end
		end
		
		--Get bot distance from side shop and secret shop
		local dSecretShop = bot:DistanceFromSecretShop();
		
		--Logic to decide in which shop bot have to purchase the item
		if CanPurchaseFromSecret and bot:DistanceFromSecretShop() > 0 then
			bot.SecretShop = true;
		else
			if bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy ) == PURCHASE_ITEM_SUCCESS then
				bot.currentComponentToBuy = nil;
				bot.currListItemToBuy[#bot.currListItemToBuy] = nil; 
				bot.SecretShop = false;
				return
			else
				if not P.IsMeepoClone(bot) then
					print("[item_purchase_generic] "..bot:GetUnitName().." failed to purchase "..bot.currentComponentToBuy.." : "..tostring(bot:ActionImmediate_PurchaseItem( bot.currentComponentToBuy )))
				end
			end
		end	
	else
		bot.SecretShop = false;
	end
end

local lastInvCheck = -90
local fullInvCheck = -90
local lastBootsCheck = -90
local buyBootsStatus = false
local addVeryLateGameItem = false
local buyRD = false
local buyTP = false
local buyBottle = false
local buystartingitems = false
local shardpurchased = false
bot.shard = false
local raindroppurchased = false

local declarePosition = false
local listset = false

function ItemPurchaseThink()  
	PChat.ChatModule()
	PAF.AcquireTarget()

	if buystartingitems == false then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
			if bot:GetUnitName() == "npc_dota_hero_medusa" then
				bot:ActionImmediate_PurchaseItem("item_magic_stick")
				bot:ActionImmediate_PurchaseItem("item_branches")
				bot:ActionImmediate_PurchaseItem("item_branches")
				bot:ActionImmediate_PurchaseItem("item_recipe_magic_wand")
			else
				bot:ActionImmediate_PurchaseItem("item_tango")
				bot:ActionImmediate_PurchaseItem("item_flask")
				bot:ActionImmediate_PurchaseItem("item_circlet")
				bot:ActionImmediate_PurchaseItem("item_branches")
				bot:ActionImmediate_PurchaseItem("item_branches")
			end
			
			buystartingitems = true
		end
		
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
			bot:ActionImmediate_PurchaseItem("item_tango")
			bot:ActionImmediate_PurchaseItem("item_flask")
			bot:ActionImmediate_PurchaseItem("item_circlet")
			bot:ActionImmediate_PurchaseItem("item_branches")
			bot:ActionImmediate_PurchaseItem("item_branches")
			
			buystartingitems = true
		end
		
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
			bot:ActionImmediate_PurchaseItem("item_tango")
			bot:ActionImmediate_PurchaseItem("item_tango")
			bot:ActionImmediate_PurchaseItem("item_circlet")
			bot:ActionImmediate_PurchaseItem("item_branches")
			bot:ActionImmediate_PurchaseItem("item_branches")
			
			buystartingitems = true
		end
		
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			bot:ActionImmediate_PurchaseItem("item_tango")
			bot:ActionImmediate_PurchaseItem("item_tango")
			bot:ActionImmediate_PurchaseItem("item_flask")
			bot:ActionImmediate_PurchaseItem("item_blood_grenade")
			bot:ActionImmediate_PurchaseItem("item_branches")
			bot:ActionImmediate_PurchaseItem("item_branches")
			
			buystartingitems = true
		end 
		
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			bot:ActionImmediate_PurchaseItem("item_tango")
			bot:ActionImmediate_PurchaseItem("item_tango")
			bot:ActionImmediate_PurchaseItem("item_flask")
			bot:ActionImmediate_PurchaseItem("item_blood_grenade")
			bot:ActionImmediate_PurchaseItem("item_branches")
			bot:ActionImmediate_PurchaseItem("item_branches")
			
			buystartingitems = true
		end
	end
	
	if ( GetGameState() ~= GAME_STATE_PRE_GAME and GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS ) 
	then
		return;
	end
	
	if listset == false and HeroInfoFile.GetHeroItemBuild() ~= nil then
		for i=1, math.ceil(#HeroInfoFile.GetHeroItemBuild()/2) do
			bot.itemToBuy[i] = HeroInfoFile.GetHeroItemBuild()[#HeroInfoFile.GetHeroItemBuild()-i+1]; 
			bot.itemToBuy[#HeroInfoFile.GetHeroItemBuild()-i+1] = HeroInfoFile.GetHeroItemBuild()[i];
		end
			
		listset = true
	end
	
	if bot:HasModifier('modifier_arc_warden_tempest_double') then
		bot.itemToBuy = {};
		return
	end
	
	-- Announce positions
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		if declarePosition == false and DotaTime() >= -74 then
			declarePosition = true
			bot:ActionImmediate_Chat("I will play Position 2 (MidLane Core).", false)
		end
	elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		if declarePosition == false and DotaTime() >= -75 then
			declarePosition = true
			bot:ActionImmediate_Chat("I will play Position 1 (SafeLane Carry).", false)
		end
	elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		if declarePosition == false and DotaTime() >= -73 then
			declarePosition = true
			bot:ActionImmediate_Chat("I will play Position 3 (OffLane Core).", false)
		end
	elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		if declarePosition == false and DotaTime() >= -72 then
			declarePosition = true
			bot:ActionImmediate_Chat("I will play Position 4 (OffLane Support).", false)
		end
	elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		if declarePosition == false and DotaTime() >= -71 then
			declarePosition = true
			bot:ActionImmediate_Chat("I will play Position 5 (SafeLane Support).", false)
		end
	end
	
	--Update invisible hero or item availability status
	if PRoles['invisEnemyExist'] == false then PRoles.UpdateInvisEnemyStatus(bot); end
	
	--Update boots availability status to make the bot start buy support item and rain drop
	if buyBootsStatus == false and DotaTime() > lastBootsCheck + 2.0 then buyBootsStatus = PItems.UpdateBuyBootStatus(bot); lastBootsCheck = DotaTime() end
	
	--purchase flying courier and support item
	if (PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport") then
		if PRoles['invisEnemyExist'] == true and buyBootsStatus == true and bot:GetGold() >= GetItemCost( "item_dust" ) 
			and PItems.GetEmptyInventoryAmount(bot) >= 4 and PItems.GetItemCharges(bot, "item_dust") < 1 and bot:GetCourierValue() == 0 
		then
			bot:ActionImmediate_PurchaseItem("item_dust"); 
		end
	end
	
	-- Smoke
	if (PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport")
	and not P.IsInLaningPhase() then
		if GetItemStockCount( "item_smoke_of_deceit" ) > 0
		and bot:GetGold() >= GetItemCost( "item_smoke_of_deceit" ) 
		and PItems.GetEmptyInventoryAmount(bot) >= 4
		and PItems.GetItemCharges(bot, "item_smoke_of_deceit") < 1
		and bot:GetCourierValue() == 0 then
			bot:ActionImmediate_PurchaseItem("item_smoke_of_deceit")
		end
	end
	
	-- Wards
	if (PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport") then
		if GetItemStockCount( "item_ward_observer" ) > 0
		and bot:GetGold() >= GetItemCost( "item_ward_observer" ) 
		and PItems.GetItemCharges(bot, "item_ward_observer") < 2
		and bot:GetCourierValue() == 0 
		and (DotaTime() < 0 or DotaTime() >= (10 * 60)) then
			bot:ActionImmediate_PurchaseItem("item_ward_observer")
		end
	end
	
	if (PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport") then
		if GetItemStockCount( "item_ward_sentry" ) > 0
		and bot:GetGold() >= GetItemCost( "item_ward_sentry" ) 
		and PItems.GetItemCharges(bot, "item_ward_sentry") < 2
		and bot:GetCourierValue() == 0
		and not P.IsInLaningPhase() then
			bot:ActionImmediate_PurchaseItem("item_ward_sentry")
		end
	end
	
	-- Blood Grenade
	if (PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport")
	and P.IsInLaningPhase() then
		if GetItemStockCount( "item_blood_grenade" ) > 0
		and DotaTime() > 0
		and bot:GetGold() >= GetItemCost( "item_blood_grenade" ) 
		and PItems.GetEmptyInventoryAmount(bot) >= 4
		and PItems.GetItemCharges(bot, "item_blood_grenade") < 1
		and bot:GetCourierValue() == 0 then
			bot:ActionImmediate_PurchaseItem("item_blood_grenade")
		end
	end
	
	---buy tom of knowledge
	if GetItemStockCount( "item_tome_of_knowledge" ) > 0 and bot:GetGold() >= GetItemCost( "item_tome_of_knowledge" ) and 
	   PItems.GetEmptyInventoryAmount(bot) >= 4 and PRoles.IsTheLowestLevel(bot)
	then
		bot:ActionImmediate_PurchaseItem("item_tome_of_knowledge"); 
	end
	
	if shardpurchased == false and GetItemStockCount( "item_aghanims_shard" ) > 0 and bot:GetGold() >= GetItemCost( "item_aghanims_shard" ) then
		shardpurchased = true
		bot.shard = true
		bot:ActionImmediate_PurchaseItem("item_aghanims_shard")
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane"
	and raindroppurchased == false
	and GetItemStockCount( "item_infused_raindrop" ) > 0
	and bot:GetGold() >= GetItemCost( "item_infused_raindrop" ) then
		raindroppurchased = true
		bot:ActionImmediate_PurchaseItem("item_infused_raindrop")
	end
	  
	--sell early game item   
	if  ( GetGameMode() ~= 23 and DotaTime() > 20*60 and DotaTime() > fullInvCheck + 2.0 
	      and ( bot:DistanceFromFountain() == 0 or bot:DistanceFromSecretShop() == 0 ) ) 
		or ( GetGameMode() == 23 and DotaTime() > 10*60 and DotaTime() > fullInvCheck + 2.0  )
	then
		local emptySlot = PItems.GetEmptyInventoryAmount(bot);
		local slotToSell = nil;
		if emptySlot < 2 then
			for i=1,#PItems['earlyGameItem'] do
				local item = PItems['earlyGameItem'][i];
				local itemSlot = bot:FindItemSlot(item);
				if itemSlot >= 0 and itemSlot <= 8 then
					if item == "item_stout_shield" then
						if bot.buildVanguard == false  then
							slotToSell = itemSlot;
							break;
						end
					elseif item == "item_magic_wand" or item == "item_magic_stick" then
						if bot.buildHoly == false then
							slotToSell = itemSlot;
							break;
						end	
					elseif item == "item_quelling_blade" then
						if bot.buildBFury == false then
							slotToSell = itemSlot;
							break;
						end
					elseif item == "item_hand_of_midas" then
						if #bot.itemToBuy <= 2 then
							slotToSell = itemSlot;
							break;
						end
					else
						slotToSell = itemSlot
						break;
					end
				end
			end
		end	
		if slotToSell ~= nil then
			bot:ActionImmediate_SellItem(bot:GetItemInSlot(slotToSell))
		end
		fullInvCheck = DotaTime()
	end
	
	--Sell non BoT boots when have BoT
	if DotaTime() > 30*60 and ( PItems.HasItem( bot, "item_travel_boots") or PItems.HasItem( bot, "item_travel_boots_2")) and
	   ( bot:DistanceFromFountain() == 0 or bot:DistanceFromSecretShop() == 0 )
	then	
		for i=1,#PItems['earlyBoots']
		do
			local bootsSlot = bot:FindItemSlot(PItems['earlyBoots'][i])
			if bootsSlot >= 0 then
				bot:ActionImmediate_SellItem(bot:GetItemInSlot(bootsSlot))
			end
		end
	end
	
	--Insert tp scroll to list item to buy and then change the buyTP flag so the bots don't reapeatedly add the tp scroll to list item to buy 
	if buyTP == false 
		and DotaTime() > 0 and bot:GetCourierValue() == 0 and bot:FindItemSlot('item_tpscroll') == -1 
	then
		bot.currentComponentToBuy = nil;	
		bot.currListItemToBuy[#bot.currListItemToBuy+1] = 'item_tpscroll';
		buyTP = true
		return
	end
	--Change the flag to buy tp scroll to false when it already has it in inventory so the bot can insert tp scroll to list item to buy whenever they don't have any tp scroll
	if buyTP == true and bot:FindItemSlot('item_tpscroll') > -1 then
		buyTP = false
	end
	
	--No need to purchase item when no item to purchase in the list
	if #bot.itemToBuy == 0 then bot:SetNextItemPurchaseValue( 0 ) return end
	
	--Get the next item to buy and break it to item components then add it to currListItemToBuy. 
	--It'll only done if the bot already has the item that formed from its component in their hero's inventory (not stash) to prevent unintended item combining
	if  bot.currentItemToBuy == nil and #bot.currListItemToBuy == 0 then
		bot.currentItemToBuy = bot.itemToBuy[#bot.itemToBuy];
		local tempTable = PItems.GetBasicItems({PItems.NormItemName(bot.currentItemToBuy)})
		for i=1,math.ceil(#tempTable/2) 
		do	
			bot.currListItemToBuy[i] = tempTable[#tempTable-i+1]
			bot.currListItemToBuy[#tempTable-i+1] = tempTable[i]
		end
		
	end
	
	--Check if the bot already has the item formed from its components in their inventory (not stash)
	if  #bot.currListItemToBuy == 0 and DotaTime() > lastInvCheck + 3.0 then
			if PItems.IsItemInHero(bot.currentItemToBuy) or ( bot.currentItemToBuy == 'item_ultimate_scepter_2' and  bot:HasScepter() ) then
				bot.currentItemToBuy = nil;
				bot.itemToBuy[#bot.itemToBuy] = nil
			else
				lastInvCheck = DotaTime();
			end
	--Added item component to current item component to buy and do the purchase	
	elseif #bot.currListItemToBuy > 0 then
		if bot.currentComponentToBuy == nil then
			bot.currentComponentToBuy = bot.currListItemToBuy[#bot.currListItemToBuy]
		else
			GeneralPurchase()
		end
	end
end