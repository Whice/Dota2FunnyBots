-- ItemPurchase/item_recipes.lua
-- Централизованное хранилище рецептов предметов Dota 2

local ItemRecipes = {}

-- Базовые стартовые предметы
ItemRecipes["item_tango"] = {}
ItemRecipes["item_branches"] = {}
ItemRecipes["item_circlet"] = {}
ItemRecipes["item_slippers"] = {}
ItemRecipes["item_faerie_fire"] = {}
ItemRecipes["item_clarity"] = {}

-- Рецепты для сборных предметов

-- Wraith Band (ВБ)
ItemRecipes["item_wraith_band"] = {
    "item_circlet",              -- Circlet (155)
    "item_slippers",             -- Slippers of Agility (140)
    "item_recipe_wraith_band"    -- Рецепт (210)
}

-- Boots (Ботинки)
ItemRecipes["item_boots"] = {}

-- Maelstrom (Молния)
ItemRecipes["item_maelstrom"] = {
    "item_mithril_hammer",       -- Mithril Hammer (1600)
    "item_javelin",              -- Javelin (900)
    "item_gloves"                -- Gloves of Haste (450)
}

-- Dragon Lance (Драгон Лэнс)
ItemRecipes["item_dragon_lance"] = {
    "item_blade_of_alacrity",    -- Blade of Alacrity (1000)
    "item_belt_of_strength",     -- Belt of Strength (450)
    "item_recipe_dragon_lance"   -- Рецепт (450)
}

-- Boots of Travel (Тревела, уровень 1)
ItemRecipes["item_travel_boots"] = {
    "item_boots",                -- Boots of Speed (500)
    "item_recipe_travel_boots"   -- Рецепт (2000)
}

-- Mjollnir (Мьёлнир)
ItemRecipes["item_mjollnir"] = {
    "item_maelstrom",            -- Maelstrom (2950)
    "item_hyperstone",           -- Hyperstone (2000)
    "item_recipe_mjollnir"       -- Рецепт (550)
}

-- Yasha (Яша, компонент для Manta)
ItemRecipes["item_yasha"] = {
    "item_blade_of_alacrity",    -- Blade of Alacrity (1000)
    "item_boots_of_elves",    -- Band of Elvenskin (450)
    "item_recipe_yasha"          -- Рецепт (650)
}

-- Manta Style (Манта)
ItemRecipes["item_manta"] = {
    "item_yasha",                -- Yasha (2100)
    "item_diadem",               -- Diadem (1000)
    "item_recipe_manta"          -- Рецепт (1550)
}

-- Satanic (Сатаник)
ItemRecipes["item_satanic"] = {
    "item_lifesteal",          -- Morbid Mask (900)
    "item_claymore",             -- Claymore (1350)
    "item_reaver"                -- Reaver (2800)
}

-- Butterfly (Бабочка)
ItemRecipes["item_butterfly"] = {
    "item_eaglesong",            -- Eaglesong (2800)
    "item_talisman_of_evasion",  -- Talisman of Evasion (1300)
    "item_claymore"              -- Claymore (1350)
}

-- Eye of Skadi (Скади)
ItemRecipes["item_skadi"] = {
    "item_ultimate_orb",         -- Ultimate Orb (2800)
    "item_ultimate_orb",         -- Ultimate Orb (2800)
    "item_point_booster"         -- Point Booster (1200)
}

-- Aghanim's Shard (Шард)
ItemRecipes["item_aghanims_shard"] = {}

-- Дополнительные компоненты и базовые предметы
ItemRecipes["item_mithril_hammer"] = {}
ItemRecipes["item_javelin"] = {}
ItemRecipes["item_gloves"] = {}
ItemRecipes["item_blight_stone"] = {}
ItemRecipes["item_claymore"] = {}
ItemRecipes["item_blade_of_alacrity"] = {}
ItemRecipes["item_belt_of_strength"] = {}
ItemRecipes["item_boots_of_elves"] = {}
ItemRecipes["item_hyperstone"] = {}
ItemRecipes["item_diadem"] = {}
ItemRecipes["item_lifesteal"] = {}
ItemRecipes["item_reaver"] = {}
ItemRecipes["item_eaglesong"] = {}
ItemRecipes["item_talisman_of_evasion"] = {}
ItemRecipes["item_ultimate_orb"] = {}
ItemRecipes["item_point_booster"] = {}
ItemRecipes["item_recipe_wraith_band"] = {}
ItemRecipes["item_recipe_dragon_lance"] = {}
ItemRecipes["item_recipe_travel_boots"] = {}
ItemRecipes["item_recipe_mjollnir"] = {}
ItemRecipes["item_recipe_yasha"] = {}
ItemRecipes["item_recipe_manta"] = {}

return ItemRecipes