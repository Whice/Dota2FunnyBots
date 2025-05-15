local json = require('bots.ts_libs.utils.json')
local Version = require 'bots.FunLib.version'
local Utils = require 'bots.FunLib.utils'
local teamNames = require 'bots.FunLib.aba_team_names'
local Localization = require 'bots/FunLib/localization'
require 'bots.FretBots.Utilities'
require 'bots.FretBots.Timers'

local Chat = { }
-- OpenAI ApiKey
local API_KEY = ''

local recordedMessages = {}
local maxpromptsLength = 3
local countErrorMsg = 0
local chatUpdateTimerName = "chatUpdate"
local chatVersionDetermineTime = -45

function Chat:SendMessageToBackend(inputText, playerInfo)
    local inputContent
    if playerInfo ~= nil then
        inputContent = {player = playerInfo, said = inputText}
    end
    local inputData = ConstructChatBotRequest(json.encode(inputContent))
    Chat:SendHttpRequest('chat', inputData)
end

function Chat:SendHttpRequest(api, inputData, callback)
    local jsonString = json.encode(inputData)

    -- local request = CreateHTTPRequest("POST", "http://127.0.0.1:5000/"..api)
    local request = CreateHTTPRequest("POST", "https://chatgpt-with-dota2bot.onrender.com/"..api)
    request:SetHTTPRequestHeaderValue("Content-Type", "application/json")
    request:SetHTTPRequestRawPostBody("application/json", jsonString)
    request:SetHTTPRequestHeaderValue("Authorization", API_KEY)

    request:Send(function(response)
        local res = response.Body

        if response.StatusCode == 200 then
            local success, resJsonObj = pcall(function() return json.decode(res) end)
            if success and resJsonObj and resJsonObj.error then
                Chat:HandleFailMessage(tostring(resJsonObj.message), false)
            else
                if callback then callback(resJsonObj)
                else
                    Chat:HandleResponseMessage(jsonString, res)
                end
            end
        else
            local success, resJsonObj = pcall(function() return json.decode(res) end)
            if success and resJsonObj and resJsonObj.error then
                Chat:HandleFailMessage(tostring(resJsonObj.error), false)
            else
                Chat:HandleFailMessage(Localization.Get("fret_req_error_msg"), false)
            end
        end
    end)
end

function Chat.StartCallback(resJsonObj)
	if resJsonObj.updates_behind and resJsonObj.updates_behind > 0 then
        print('Script is out of date.')
        Timers:CreateTimer(chatUpdateTimerName, {endTime = 1, callback = Chat['NotifyUpdate']} )
    end
end

function Chat:NotifyUpdate()
	local gameTime = Utilities:GetAbsoluteTime()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME and gameTime > chatVersionDetermineTime then
        Utilities:Print(Localization.Get('newer_version'), MSG_WARNING)
		Timers:RemoveTimer(chatUpdateTimerName)
        return nil
    end
	return 1
end

local function getFormattedGameTime()
    local gameTime = Utilities:GetTime()
    local minutes = math.floor(gameTime / 60)
    local seconds = math.floor(gameTime % 60)
    return string.format("%dm:%ds", minutes, seconds)
end

function ConstructChatBotRequest(inputContent)
    local contentStruct = {
        all_heroes_in_game = Utilities:HeroStatsInGame(AllUnits),
        current_game_time = getFormattedGameTime(),
        locale_language_code = Localization.GetLocale(),
    }
    table.insert(recordedMessages, 1, { role = "user", content = json.encode(contentStruct)})
    table.insert(recordedMessages, { role = "user", content = inputContent })

    -- Initialize data table
    local data = { prompts = {}, version = Version.number, scriptID = Utils.ScriptID, nameSuffix = teamNames.defaultPostfix }

    -- Copy global messages into data.prompts
    for _, message in ipairs(recordedMessages) do
        table.insert(data.prompts, message)
    end

    if #data.prompts > maxpromptsLength then
        for i = 1, #data.prompts - maxpromptsLength - 1 do
            table.remove(data.prompts, 2)
        end
    end

    return data
end

local function getRandomBot()
    local val
	for team = 2, 3 do
    local temp = math.random(1, #AllBots[team])
    for idx, value in pairs(AllBots[team]) do
        val = value
        if idx == temp then
            return value
        end
    end
    end
    return val
end

local function splitHeroNameFromMessage(message)
    local hero_pattern = "(npc_dota_hero_[%w_]+)" 
    local before_hero, hero_name, _ = message:match("^(.-)(" .. hero_pattern .. ")(.*)$")
    if before_hero and hero_name then
        return before_hero, hero_name
    else
        return message, nil  -- If no hero name is found, return the original message and nil
    end
end

function Chat:HandleFailMessage(message, isBotSay)
    -- print("API Failure: " .. message)
    countErrorMsg = countErrorMsg + 1
    if countErrorMsg <= 3 then
        if isBotSay then
            local aBot = getRandomBot()
            if aBot ~= nil then
                Say(aBot, message, false)
            end
        else
            Utilities:Print(message, MSG_WARNING)
        end
    else
        print("[ERROR] Cannot get valid repsonse from Chat server. Hide the errors to avoid spams.")
    end
    if countErrorMsg >= 6 then
        -- Reset count every 5 times so users can get re-notified about the error.
        countErrorMsg = 0
    end
end

function Chat:HandleResponseMessage(inputText, message)
    -- print("API Response: " .. message)
    local foundBot = false
    local aiText, heroHame = splitHeroNameFromMessage(message)
    if heroHame then
        for team = 2, 3 do
            for _, bot in ipairs(AllBots[team]) do
                if bot.stats.isBot and bot.stats.internalName == heroHame then
                    Say(bot, aiText, false)
                    foundBot = true
                end
            end
        end
    end
    if not foundBot then
        local aBot = getRandomBot()
        if aBot ~= nil then
            Say(aBot, aiText, false)
        end
    end
    if not heroHame then
        return
    end
    table.insert(recordedMessages, { role = "assistant", content = message })
end

return Chat