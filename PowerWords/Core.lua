-- Core.lua
local ADDON_NAME = ...

PowerWords = PowerWords or {}
PowerWords._pendingPITargetByCastGUID = PowerWords._pendingPITargetByCastGUID or {}

-- Constants
local PI_SPELL_ID = 10060 -- Power Infusion

local DEFAULT_MESSAGES = {
    "Power Infusion incoming.",
    "PI is on you. Go hard.",
    "You are infused. Send it.",
    "PI applied. Pump damage.",
    "You got PI. Make it count.",
}

local function CopyArray(src)
    local t = {}
    for i, v in ipairs(src or {}) do t[i] = v end
    return t
end

-- DB
function PowerWords:InitDB()
    PowerWordsDB = PowerWordsDB or {}

    if PowerWordsDB.enabled == nil then PowerWordsDB.enabled = true end
    if PowerWordsDB.allowSelf == nil then PowerWordsDB.allowSelf = false end

    if not PowerWordsDB.audience then
        PowerWordsDB.audience = {
            mode = "EVERYONE", -- EVERYONE | GUILD | BNET | GUILD_OR_BNET | WHITELIST | BLACKLIST
            whitelist = {},
            blacklist = {},
        }
    else
        PowerWordsDB.audience.mode = PowerWordsDB.audience.mode or "EVERYONE"
        PowerWordsDB.audience.whitelist = PowerWordsDB.audience.whitelist or {}
        PowerWordsDB.audience.blacklist = PowerWordsDB.audience.blacklist or {}
    end

    if type(PowerWordsDB.messages) ~= "table" or #PowerWordsDB.messages == 0 then
        PowerWordsDB.messages = CopyArray(DEFAULT_MESSAGES)
    end
end

-- Utilities
function PowerWords:NormalizeName(name)
    if not name or name == "" then return nil end
    return Ambiguate(name, "none")
end

function PowerWords:SplitLinesToMessages(text)
    local out = {}
    for line in (text or ""):gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then table.insert(out, line) end
    end
    return out
end

function PowerWords:MessagesToText(messages)
    return table.concat(messages or {}, "\n")
end

function PowerWords:SplitLinesToNameSet(text)
    local set = {}
    for line in (text or ""):gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then
            local normalized = self:NormalizeName(line) or line
            set[normalized] = true
        end
    end
    return set
end

function PowerWords:NameSetToText(set)
    local names = {}
    for name, enabled in pairs(set or {}) do
        if enabled then table.insert(names, name) end
    end
    table.sort(names)
    return table.concat(names, "\n")
end

-- Audience checks
function PowerWords:IsGuildmate(fullName)
    if not IsInGuild() then return false end

    local short = Ambiguate(fullName, "short")

    if C_GuildInfo and C_GuildInfo.GetNumGuildMembers and C_GuildInfo.GetGuildRosterInfo then
        local n = C_GuildInfo.GetNumGuildMembers()
        for i = 1, n do
            local info = C_GuildInfo.GetGuildRosterInfo(i)
            if info and info.name and Ambiguate(info.name, "short") == short then
                return true
            end
        end
        return false
    end

    if GetNumGuildMembers and GetGuildRosterInfo then
        for i = 1, GetNumGuildMembers() do
            local name = GetGuildRosterInfo(i)
            if name and Ambiguate(name, "short") == short then
                return true
            end
        end
    end

    return false
end

function PowerWords:IsBNetFriend(fullName)
    if not BNGetNumFriends then return false end

    local targetShort = Ambiguate(fullName, "short")

    if BNGetNumFriendGameAccounts and BNGetFriendGameAccountInfo and BNGetFriendInfo then
        local num = BNGetNumFriends()
        for i = 1, num do
            local hasAccount = select(1, BNGetFriendInfo(i))
            if hasAccount then
                local gameAccounts = BNGetNumFriendGameAccounts(i) or 0
                for j = 1, gameAccounts do
                    local info = BNGetFriendGameAccountInfo(i, j)
                    if info and info.clientProgram == "WoW" and info.characterName == targetShort then
                        return true
                    end
                end
            end
        end
        return false
    end

    if BNGetFriendInfo and BNGetGameAccountInfo then
        local num = BNGetNumFriends()
        for i = 1, num do
            local _, _, _, _, _, _, _, _, _, _, _, _, _, _, bnetIDGameAccount = BNGetFriendInfo(i)
            if bnetIDGameAccount then
                local _, characterName = BNGetGameAccountInfo(bnetIDGameAccount)
                if characterName == targetShort then
                    return true
                end
            end
        end
    end

    return false
end

function PowerWords:CanMessageTarget(fullName)
    if not PowerWordsDB or not PowerWordsDB.audience then return true end

    local a = PowerWordsDB.audience
    fullName = self:NormalizeName(fullName)
    if not fullName then return false end

    if a.mode == "EVERYONE" then
        return true
    elseif a.mode == "GUILD" then
        return self:IsGuildmate(fullName)
    elseif a.mode == "BNET" then
        return self:IsBNetFriend(fullName)
    elseif a.mode == "GUILD_OR_BNET" then
        return self:IsGuildmate(fullName) or self:IsBNetFriend(fullName)
    elseif a.mode == "WHITELIST" then
        return a.whitelist and a.whitelist[fullName] == true
    elseif a.mode == "BLACKLIST" then
        return not (a.blacklist and a.blacklist[fullName] == true)
    end

    return true
end

-- Messaging
function PowerWords:GetNextMessage()
    local msgs = PowerWordsDB and PowerWordsDB.messages
    if type(msgs) ~= "table" or #msgs == 0 then return nil end

    PowerWordsDB._msgIndex = (PowerWordsDB._msgIndex or 0) + 1
    if PowerWordsDB._msgIndex > #msgs then
        PowerWordsDB._msgIndex = 1
    end

    return msgs[PowerWordsDB._msgIndex]
end

function PowerWords:SendTestMessage(toTarget)
    if not PowerWordsDB then return end

    local msg = self:GetNextMessage()
    if not msg then
        print("PowerWords: No messages saved.")
        return
    end

    local recipient
    if toTarget then
        recipient = UnitName("target")
        if not recipient or recipient == "" then
            print("PowerWords: No target selected.")
            return
        end
        recipient = self:NormalizeName(recipient) or recipient
    else
        recipient = self:NormalizeName(UnitName("player")) or UnitName("player")
    end

    SendChatMessage(msg, "WHISPER", nil, recipient)
end

function PowerWords:SendPIMessage(destName)
    if not PowerWordsDB or not PowerWordsDB.enabled then return end
    if not destName or destName == "" then return end

    destName = self:NormalizeName(destName) or destName

    local me = self:NormalizeName(UnitName("player"))
    if me and destName == me and not PowerWordsDB.allowSelf then
        return
    end

    if not self:CanMessageTarget(destName) then return end

    local msg = self:GetNextMessage()
    if not msg then return end

    SendChatMessage(msg, "WHISPER", nil, destName)
end

-- Slash commands
SLASH_POWERWORDS1 = "/powerwords"
SLASH_POWERWORDS2 = "/pw"
SlashCmdList["POWERWORDS"] = function()
    if PowerWords.ToggleConfig then
        PowerWords:ToggleConfig()
    end
end

-- Events
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterUnitEvent("UNIT_SPELLCAST_SENT", "player")
f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")

f:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName ~= ADDON_NAME then return end

        PowerWords:InitDB()
        if PowerWords.CreateConfigWindow then
            PowerWords:CreateConfigWindow()
        end
        return
    end

    if event == "UNIT_SPELLCAST_SENT" then
        local unit, targetName, castGUID, spellId = ...
        if unit ~= "player" then return end
        if spellId ~= PI_SPELL_ID then return end
        if not castGUID then return end

        PowerWords._pendingPITargetByCastGUID[castGUID] = targetName
        return
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, castGUID, spellId = ...
        if unit ~= "player" then return end
        if spellId ~= PI_SPELL_ID then return end

        local targetName = PowerWords._pendingPITargetByCastGUID[castGUID]
        PowerWords._pendingPITargetByCastGUID[castGUID] = nil

        if targetName and targetName ~= "" then
            PowerWords:SendPIMessage(targetName)
        end
    end
end)
