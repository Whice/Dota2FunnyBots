if GetScriptDirectory == nil then GetScriptDirectory = function () return "bots" end end
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )

local Dota2Teams = { }

Dota2Teams.defaultPostfix = 'OHA' -- Open Hyper AI.
Dota2Teams.maxTeamSize = 12 -- e.g. for 12 v 12

-- List should have a least 4 teams for better performance.
local defaultTeams = {
    {name = "Liquid", players = {"miCKe", "Nisha", "zai", "Boxi", "Insania"}},
    {name = "GaiminGladiators", players = {"dyrachyo", "Quinn", "Ace", "tOfu", "Seleri"}},
    {name = "TundraEsports", players = {"Skiter", "Nine", "33", "Sneyking", "Aui_2000"}},
    {name = "EvilGeniuses", players = {"Pakazs", "Chris Luck", "Wisper", "Matthew", "Panda"}},
    {name = "PSG_LGD", players = {"shiro", "NothingToSay", "niu 牛", "planet", "y`"}},
    {name = "ShopifyRebellion", players = {"Arteezy", "Abed", "SaberLight", "Cr1t-", "Fly"}},
    {name = "TalonEsports", players = {"23savage", "Mikoto", "Jabz", "Q", "Oli"}},
    {name = "beastcoast", players = {"K1", "Chris Luck", "Wisper", "Stinger", "Scofield"}},
    {name = "Spirit", players = {"Yatoro雨", "Larl", "Collapse", "Mira", "Miposhka"}},
    {name = "TSM", players = {"Timado", "Bryle", "Kasane", "Ari", "Whitemon"}},
    {name = "BetBoom", players = {"Nightfall", "gpk", "Pure", "Save-", "TORONTOTOKYO"}},
    {name = "Execration", players = {"Palos", "Bob", "Tino", "Shanks", "Carlo"}},
    {name = "QuestEsports", players = {"TA2000", "No!ob", "Tobi", "OmaR", "kaori"}},
    {name = "nouns", players = {"Gunnar", "Costabile", "Moo", "ZFreek", "Husky"}},
    {name = "BleedEsports", players = {"JaCkky", "Kordan", "iceiceice", "DJ", "DuBu"}},
    {name = "Aster", players = {"Monet", "Xxs", "Ori", "BoBoKa", "LaNm"}},
    {name = "InvictusGaming", players = {"flyfly", "Emo", "JT-", "Kaka 卡卡", "Oli"}},
    {name = "AzureRay", players = {"Eurus", "Somnus丶M", "Yang", "Fy", "xNova"}},
    {name = "Blacklist", players = {"Raven", "Karl", "Kuku", "TIMS", "Eyyou"}},
    {name = "VirtusPro", players = {"RAMZES666", "kiyotaka", "MieRo", "Antares", "Solo"}},
    {name = "9Pandas", players = {"RAMZES666", "kiyotaka", "MieRo", "Antares", "Solo"}}, -- Updated team from 2024
    {name = "TeamSMG", players = {"MidOne", "Moon", "Masaros", "Ahfu", "Raging Potato"}}, -- Team from SEA region, rising in 2024
    {name = "KeydStars", players = {"4dr", "Tavo", "hFn", "KJ", "mini"}}, -- Brazilian team prominent in 2024
    {name = "ThunderAwaken", players = {"Panda", "DarkMago", "Sacred", "Matthew", "Pakazs"}}, -- Updated for 2024 with roster changes
    {name = "Additionals", players = {
        "Azazel", "Lucifer", "Belial", "Lilith", "Diablo", "Mephisto", "Asmodeus", "Beelzebub", "Samael", "Abaddon", "Mammon", "Astaroth",
        "Leviathan", "Moloch", "Belphegor", "Apollyon", "Gorgoth", "Zaganthar", "Nyxoloth", "Malphas", "Inferno", "Darkfire", "Shadowblade",
        "Nightmare", "Hellspawn", "Bloodlust", "Doombringer", "Soulreaper", "Deathbringer", "Lightbringer", "Celestial", "Heavenly", "Seraphim",
        "Radiant", "Divinity", "Archangel", "Gloriosa", "Holystone", "Etherealis", "Heavenfire"
    }}
}

local function generateTeam(overrides)
    local playerList = { }
    local overriddenNames = { }
    local randomNum = 0
    repeat
        randomNum = RandomInt(1, #defaultTeams)
    -- ensure a team can only pick from certain team names.
    until randomNum % 2 == GetTeam() - 2 and defaultTeams[randomNum].name ~= 'Additionals'
    -- print('randomNum='..tostring(randomNum)..', team name='..tostring(defaultTeams[randomNum].name)..', for team='..tostring(GetTeam()))
    playerList = Utils.MergeLists(defaultTeams[randomNum].players, defaultTeams[#defaultTeams].players)
    if overrides and #overrides > 0 then
        for i = 1, #overrides do
            if overrides[i] and overrides[i] ~= 'Random' then
                playerList[i] = overrides[i]
                table.insert(overriddenNames, overrides[i])
            end
        end
    end

    local team = { }
    for i = 1, Dota2Teams.maxTeamSize do
        local pName = table.remove(playerList, 1)
        if Utils.HasValue(overriddenNames, pName) then
            table.insert(team, pName)
        else
            table.insert(team, defaultTeams[randomNum].name .. "." .. pName ..'.'..Dota2Teams.defaultPostfix)
        end
    end
    return team
end

--[[
    Example of overrides arg with specific player names for Radiant:
    local playerNameOverrides = {
        Radiant = {"p1", "p2", "p3", "p4", "p5"}
    }
]]
function Dota2Teams.generateTeams(overrides)
    local radiantOverrides = overrides and overrides.Radiant or {}
    local direOverrides = overrides and overrides.Dire or {}

    local radiantTeam = generateTeam(radiantOverrides)
    local direTeam = generateTeam(direOverrides)

    return {
        Radiant = radiantTeam,
        Dire = direTeam
    }
end

return Dota2Teams
