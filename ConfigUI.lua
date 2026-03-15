-- ConfigUI.lua
PowerWords = PowerWords or {}

local AUDIENCE_OPTIONS = {
    { key = "EVERYONE",      text = "Everyone" },
    { key = "GUILD",         text = "Guild members only" },
    { key = "BNET",          text = "Battle.net friends only" },
    { key = "GUILD_OR_BNET", text = "Guild OR Battle.net friends" },
    { key = "WHITELIST",     text = "Whitelist only" },
    { key = "BLACKLIST",     text = "Everyone except blacklist" },
}

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(("|cffffd200PowerWords:|r %s"):format(msg))
end

local function EnsureSpecialFrame(frameName)
    if type(UISpecialFrames) ~= "table" then return end
    for _, name in ipairs(UISpecialFrames) do
        if name == frameName then return end
    end
    table.insert(UISpecialFrames, frameName)
end

function PowerWords:CreateConfigWindow()
    if PowerWordsConfigFrame then return end

    local f = CreateFrame("Frame", "PowerWordsConfigFrame", UIParent, "BackdropTemplate")
    f:SetSize(560, 520)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(100)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    EnsureSpecialFrame("PowerWordsConfigFrame")

    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.92)

    -- Header
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("PowerWords")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    local enableCheck = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", 18, -38)
    enableCheck.text:SetText("Enabled")
    enableCheck:SetScript("OnClick", function(self)
        PowerWordsDB.enabled = self:GetChecked() and true or false
    end)
    f.enableCheck = enableCheck

    local selfCheck = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    selfCheck:SetPoint("LEFT", enableCheck, "RIGHT", 90, 0)
    selfCheck.text:SetText("Works on Self")
    selfCheck:SetScript("OnClick", function(self)
        PowerWordsDB.allowSelf = self:GetChecked() and true or false
    end)
    f.selfCheck = selfCheck

    local audLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    audLabel:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -12)
    audLabel:SetText("Audience:")

    local audDrop = CreateFrame("DropdownButton", "PowerWordsAudienceDropdown", f, "WowStyle1DropdownTemplate")
    audDrop:SetPoint("LEFT", audLabel, "RIGHT", 4, 0)
    audDrop:SetWidth(230)
    f.audienceDropdown = audDrop

    -- List (Whitelist/Blacklist)
    local listHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    listHeader:SetPoint("TOPLEFT", audLabel, "BOTTOMLEFT", 0, -14)
    f.listHeader = listHeader

    local listSub = f:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    listSub:SetPoint("TOPLEFT", listHeader, "BOTTOMLEFT", 0, -4)
    f.listSub = listSub

    local listScroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", listSub, "BOTTOMLEFT", 0, -8)
    listScroll:SetPoint("TOPRIGHT", -34, 0)
    listScroll:SetHeight(90)
    f.listScroll = listScroll

    local listEdit = CreateFrame("EditBox", nil, listScroll, "BackdropTemplate")
    listEdit:SetMultiLine(true)
    listEdit:SetAutoFocus(false)
    listEdit:SetFontObject(ChatFontNormal)
    listEdit:SetWidth(460)
    listEdit:SetSpacing(2)
    listEdit:SetTextInsets(8, 8, 8, 8)
    listEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    listEdit:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    listEdit:SetBackdropColor(0.06, 0.06, 0.06, 0.9)
    listScroll:SetScrollChild(listEdit)
    f.listEdit = listEdit

    local listSaveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    listSaveBtn:SetSize(120, 26)
    listSaveBtn:SetPoint("TOPLEFT", listScroll, "BOTTOMLEFT", 0, -8)
    listSaveBtn:SetText("Save List")
    f.listSaveBtn = listSaveBtn

    local listRevertBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    listRevertBtn:SetSize(120, 26)
    listRevertBtn:SetPoint("LEFT", listSaveBtn, "RIGHT", 8, 0)
    listRevertBtn:SetText("Revert List")
    f.listRevertBtn = listRevertBtn

    -- Messages
    local msgHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    msgHeader:SetText("Messages (one per line)")

    local msgSub = f:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    msgSub:SetText("A random line will be used when you cast Power Infusion.")

    local msgScroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")

    local msgEdit = CreateFrame("EditBox", nil, msgScroll, "BackdropTemplate")
    msgEdit:SetMultiLine(true)
    msgEdit:SetAutoFocus(false)
    msgEdit:SetFontObject(ChatFontNormal)
    msgEdit:SetWidth(460)
    msgEdit:SetSpacing(2)
    msgEdit:SetTextInsets(8, 8, 8, 8)
    msgEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    msgEdit:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    msgEdit:SetBackdropColor(0.06, 0.06, 0.06, 0.9)
    msgScroll:SetScrollChild(msgEdit)

    f.scroll = msgScroll
    f.messagesEdit = msgEdit

    local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    saveBtn:SetSize(120, 26)
    saveBtn:SetPoint("BOTTOMLEFT", 18, 20)
    saveBtn:SetText("Save")

    local revertBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    revertBtn:SetSize(120, 26)
    revertBtn:SetPoint("LEFT", saveBtn, "RIGHT", 8, 0)
    revertBtn:SetText("Revert")

    local testBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    testBtn:SetSize(120, 26)
    testBtn:SetPoint("LEFT", revertBtn, "RIGHT", 8, 0)
    testBtn:SetText("Test")

    local testHint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    testHint:SetPoint("TOPLEFT", testBtn, "BOTTOMLEFT", 0, -2)
    testHint:SetText("Whispers you. Shift-click: target.")

    local countText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    countText:SetPoint("BOTTOMRIGHT", -18, 25)
    f.countText = countText

    -- Layout
    local function AnchorMessagesUnderTop()
        msgHeader:ClearAllPoints()
        msgHeader:SetPoint("TOPLEFT", audLabel, "BOTTOMLEFT", 0, -14)

        msgSub:ClearAllPoints()
        msgSub:SetPoint("TOPLEFT", msgHeader, "BOTTOMLEFT", 0, -4)

        msgScroll:ClearAllPoints()
        msgScroll:SetPoint("TOPLEFT", msgSub, "BOTTOMLEFT", 0, -8)
        msgScroll:SetPoint("BOTTOMRIGHT", -34, 70)
    end

    local function AnchorMessagesUnderList()
        msgHeader:ClearAllPoints()
        msgHeader:SetPoint("TOPLEFT", listSaveBtn, "BOTTOMLEFT", 0, -18)

        msgSub:ClearAllPoints()
        msgSub:SetPoint("TOPLEFT", msgHeader, "BOTTOMLEFT", 0, -4)

        msgScroll:ClearAllPoints()
        msgScroll:SetPoint("TOPLEFT", msgSub, "BOTTOMLEFT", 0, -8)
        msgScroll:SetPoint("BOTTOMRIGHT", -34, 70)
    end

    -- State helpers
    local function RefreshCount()
        local msgs = PowerWordsDB.messages or {}
        f.countText:SetText(("Saved messages: %d"):format(#msgs))
    end

    local function GetListKind()
        local mode = PowerWordsDB.audience.mode
        if mode == "WHITELIST" then return "whitelist" end
        if mode == "BLACKLIST" then return "blacklist" end
        return nil
    end

    local function HideListUI()
        f.listHeader:Hide()
        f.listSub:Hide()
        f.listScroll:Hide()
        f.listSaveBtn:Hide()
        f.listRevertBtn:Hide()
        AnchorMessagesUnderTop()
    end

    local function ShowListUI()
        f.listHeader:Show()
        f.listSub:Show()
        f.listScroll:Show()
        f.listSaveBtn:Show()
        f.listRevertBtn:Show()
        AnchorMessagesUnderList()
    end

    local function LoadListFromDB()
        local kind = GetListKind()
        if not kind then
            HideListUI()
            return
        end

        ShowListUI()

        if kind == "whitelist" then
            f.listHeader:SetText("Whitelist (one name per line)")
            f.listSub:SetText("Only these players will receive messages.")
            f.listEdit:SetText(PowerWords:NameSetToText(PowerWordsDB.audience.whitelist))
        else
            f.listHeader:SetText("Blacklist (one name per line)")
            f.listSub:SetText("Everyone receives messages except these players.")
            f.listEdit:SetText(PowerWords:NameSetToText(PowerWordsDB.audience.blacklist))
        end

        f.listEdit:SetCursorPosition(0)
        f.listScroll:SetVerticalScroll(0)
    end

    local function LoadMessagesFromDB()
        msgEdit:SetText(PowerWords:MessagesToText(PowerWordsDB.messages or {}))
        msgEdit:SetCursorPosition(0)
        msgScroll:SetVerticalScroll(0)
        RefreshCount()
    end

    local function LoadFromDB()
        f.enableCheck:SetChecked(PowerWordsDB.enabled)
        f.selfCheck:SetChecked(PowerWordsDB.allowSelf)

        LoadMessagesFromDB()

        LoadListFromDB()
    end

    -- Dropdown
    audDrop:SetupMenu(function(_, rootDescription)
        for _, opt in ipairs(AUDIENCE_OPTIONS) do
            rootDescription:CreateRadio(opt.text, function()
                return PowerWordsDB.audience.mode == opt.key
            end, function()
                PowerWordsDB.audience.mode = opt.key
                LoadListFromDB()
            end)
        end
    end)

    -- Handlers
    saveBtn:SetScript("OnClick", function()
        local msgs = PowerWords:SplitLinesToMessages(msgEdit:GetText())
        if #msgs == 0 then
            Print("Add at least 1 message line before saving.")
            return
        end
        PowerWordsDB.messages = msgs
        RefreshCount()
        Print(("Saved %d message(s)."):format(#msgs))
    end)

    revertBtn:SetScript("OnClick", function()
        LoadMessagesFromDB()
        Print("Reverted to saved messages.")
    end)

    testBtn:SetScript("OnClick", function()
        local toTarget = IsShiftKeyDown()
        if PowerWords and PowerWords.SendTestMessage then
            PowerWords:SendTestMessage(toTarget)
        end
    end)

    listSaveBtn:SetScript("OnClick", function()
        local kind = GetListKind()
        if not kind then
            Print("Switch Audience to Whitelist or Blacklist to edit the list.")
            return
        end

        local set = PowerWords:SplitLinesToNameSet(f.listEdit:GetText())
        PowerWordsDB.audience[kind] = set

        local c = 0
        for _, v in pairs(set) do if v then c = c + 1 end end
        Print(("Saved %s entries: %d"):format(kind, c))
    end)

    listRevertBtn:SetScript("OnClick", function()
        LoadListFromDB()
        Print("Reverted list to saved values.")
    end)

    f.LoadFromDB = LoadFromDB
    f.RefreshCount = RefreshCount

    LoadFromDB()
end

function PowerWords:ToggleConfig()
    if not PowerWordsConfigFrame then
        PowerWords:CreateConfigWindow()
    end

    if PowerWordsConfigFrame.LoadFromDB then
        PowerWordsConfigFrame:LoadFromDB()
    end

    if PowerWordsConfigFrame:IsShown() then
        PowerWordsConfigFrame:Hide()
    else
        PowerWordsConfigFrame:Show()
    end
end
