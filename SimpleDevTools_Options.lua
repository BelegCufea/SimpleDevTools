local addonName = SimpleDevTools.addonName

-- =====================
-- Options GUI
-- =====================

local optionsPanel = CreateFrame("Frame", addonName .. "OptionsPanel", UIParent)
optionsPanel.name = SimpleDevTools.addonName
optionsPanel:SetSize(480, 480)
optionsPanel:SetPoint("CENTER")
optionsPanel:Hide()

SimpleDevTools.optionsPanel = optionsPanel

local title = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("SimpleDevTools Configuration")

local desc = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
desc:SetText("Manage your built-in and addon command shortcuts.")

-- Input widgets for add/edit moved to the top
local sectionDropdown = CreateFrame("Frame", addonName .. "SectionDropDown", optionsPanel, "UIDropDownMenuTemplate")
sectionDropdown:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", -16, -16)
local selectedSection = "builtIn"

UIDropDownMenu_SetWidth(sectionDropdown, 120)
UIDropDownMenu_Initialize(sectionDropdown, function(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Built-in"
    info.func = function()
        selectedSection = "builtIn"
        UIDropDownMenu_SetSelectedName(sectionDropdown, "Built-in")
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Addons"
    info.func = function()
        selectedSection = "addons"
        UIDropDownMenu_SetSelectedName(sectionDropdown, "Addons")
    end
    UIDropDownMenu_AddButton(info)
end)
UIDropDownMenu_SetSelectedName(sectionDropdown, "Built-in")

local labelBox = CreateFrame("EditBox", nil, optionsPanel, "InputBoxTemplate")
labelBox:SetSize(120, 20)
labelBox:SetPoint("LEFT", sectionDropdown, "RIGHT", 10, 0)
labelBox:SetAutoFocus(false)

local commandBox = CreateFrame("EditBox", nil, optionsPanel, "InputBoxTemplate")
commandBox:SetSize(160, 20)
commandBox:SetPoint("LEFT", labelBox, "RIGHT", 10, 0)
commandBox:SetAutoFocus(false)

local addButton = CreateFrame("Button", nil, optionsPanel, "UIPanelButtonTemplate")
addButton:SetSize(60, 20)
addButton:SetPoint("LEFT", commandBox, "RIGHT", 10, 0)
addButton:SetText("Add")

local scrollFrame = CreateFrame("ScrollFrame", addonName .. "ScrollFrame", optionsPanel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", sectionDropdown, "BOTTOMLEFT", 16, -16)
scrollFrame:SetPoint("BOTTOMRIGHT", optionsPanel, "BOTTOMRIGHT", -40, 40) -- Dock to the bottom

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(380, 250)
scrollFrame:SetScrollChild(content)

local editingEntry, editingIndex
local itemFrames = {}

local function RefreshOptions()
    for i = 1, #itemFrames do
        itemFrames[i]:Hide()
    end

    local y = -4
    local frameIndex = 1

    local function AddSection(titleText, list, key)
        local sectionTitle = itemFrames[frameIndex]
        if not sectionTitle or sectionTitle:GetObjectType() ~= "FontString" then
            sectionTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            tinsert(itemFrames, frameIndex, sectionTitle)
        end
        sectionTitle:Show()
        sectionTitle:SetPoint("TOPLEFT", 0, y)
        sectionTitle:SetText(titleText)
        y = y - 20
        frameIndex = frameIndex + 1

        for idx, entry in ipairs(list) do
            local itemFrame = itemFrames[frameIndex]
            if not itemFrame or itemFrame:GetObjectType() ~= "Frame" then
                itemFrame = CreateFrame("Frame", nil, content)
                itemFrame:SetSize(400, 20)
                tinsert(itemFrames, frameIndex, itemFrame)

                itemFrame.label = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                itemFrame.label:SetPoint("TOPLEFT", 0, 0)

                itemFrame.editBtn = CreateFrame("Button", nil, itemFrame, "UIPanelButtonTemplate")
                itemFrame.editBtn:SetSize(50, 18)
                itemFrame.editBtn:SetPoint("LEFT", itemFrame.label, "RIGHT", 10, 0)
                itemFrame.editBtn:SetText("Edit")

                itemFrame.removeBtn = CreateFrame("Button", nil, itemFrame, "UIPanelButtonTemplate")
                itemFrame.removeBtn:SetSize(60, 18)
                itemFrame.removeBtn:SetPoint("LEFT", itemFrame.editBtn, "RIGHT", 5, 0)
                itemFrame.removeBtn:SetText("Remove")
            end

            itemFrame:Show()
            itemFrame:SetPoint("TOPLEFT", 0, y)
            itemFrame.label:SetText(entry.label .. " -> " .. entry.command)

            itemFrame.editBtn:SetScript("OnClick", function()
                labelBox:SetText(entry.label)
                commandBox:SetText(entry.command)
                selectedSection = key
                UIDropDownMenu_SetSelectedName(sectionDropdown, key == "builtIn" and "Built-in" or "Addons")
                editingEntry = list
                editingIndex = idx
                addButton:SetText("Save")
            end)

            itemFrame.removeBtn:SetScript("OnClick", function()
                table.remove(list, idx)
                RefreshOptions()
            end)

            y = y - 24
            frameIndex = frameIndex + 1
        end
        y = y - 8
    end

    AddSection("Built-in", SimpleDevToolsDB.builtIn, "builtIn")
    AddSection("Addons", SimpleDevToolsDB.addons, "addons")

    for i = frameIndex, #itemFrames do
        itemFrames[i]:Hide()
    end

    content:SetHeight(-y + 20)
end

addButton:SetScript("OnClick", function()
    local label = labelBox:GetText()
    local command = commandBox:GetText()
    if label == "" or command == "" then return end

    if editingEntry then
        editingEntry[editingIndex] = { label = label, command = command }
        editingEntry = nil
        editingIndex = nil
        addButton:SetText("Add")
    else
        table.insert(SimpleDevToolsDB[selectedSection], { label = label, command = command })
    end

    labelBox:SetText("")
    commandBox:SetText("")
    RefreshOptions()
end)

optionsPanel.refresh = RefreshOptions
optionsPanel:SetScript("OnShow", RefreshOptions)

local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name)
category.ID = optionsPanel.name
Settings.RegisterAddOnCategory(category)