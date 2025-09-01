-- Create a global addon table that will be shared between files.
SimpleDevTools = {}

-- Define the addon name as a property of the global table.
SimpleDevTools.addonName = "SimpleDevTools"

local L = LibStub("LibDataBroker-1.1")
local addonName = SimpleDevTools.addonName

-- Saved variables
SimpleDevToolsDB = SimpleDevToolsDB or {
    builtIn = {
        { label = "FStack", command = "/fstack" },
        { label = "ETrace", command = "/etrace" },
    },
    addons = {
        { label = "WoW Lua", command = "/lua" },
        { label = "DevTool", command = "/dev" },
        { label = "Cube Code", command = "/cube code" },
        { label = "API Interface", command = "/apii" },
        { label = "Addon Profiler", command = "/nap" },
    }
}

-- Create the LDB data object
local ldbObject = L:NewDataObject(addonName, {
    type = "launcher",
    icon = [[Interface\Icons\INV_Misc_Gear_03]],
    label = "DevTools",
    text = "DevTools",
})

-- Create a menu frame to hold our dropdown menu
local menuFrame = CreateFrame("Frame", "SimpleDevToolsMenu", UIParent, "UIDropDownMenuTemplate")

local confirmationDialogName = addonName .. "_confirmation"
StaticPopupDialogs[confirmationDialogName] = {
    text = "Do you want to proceed?",
    button1 = "Yes",
    button2 = "No",
    hideOnEscape = true,
    whileDead = true,
}

--- A function to execute a slash command by simulating chat input.
--- This method bypasses security restrictions on protected functions.
---@param command string The slash command to run (e.g., "/lua").
local function RunCommand(command)
    DEFAULT_CHAT_FRAME.editBox:SetText(command)
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
end

--- Helper function to add a standard clickable menu item to the dropdown menu.
---@param label string The text label for the menu item.
---@param command string The slash command to be executed when the item is clicked.
local function AddMenuItem(label, command)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "  " .. label
    info.func = function()
        RunCommand(command)
        CloseDropDownMenus()
    end
    info.notCheckable = true
    UIDropDownMenu_AddButton(info, 1)
end

--- Helper function to add a non-clickable title or separator line.
--- This can be used for section titles or simple horizontal separators.
---@param title string|nil The text for the title. If nil, it creates an empty separator line.
local function AddTitle(title)
    local info = UIDropDownMenu_CreateInfo()
    info.text = title
    info.notCheckable = 1
    info.notClickable = 1
    info.isTitle = 1
    UIDropDownMenu_AddButton(info, 1)
end

local function CreateMenu()
    UIDropDownMenu_Initialize(menuFrame, function(self, level)
        if level ~= 1 then return end

        AddTitle("Simple Dev Tools")

        AddTitle("|cnDIM_GREEN_FONT_COLOR:»Built-in|r")
        for _, entry in ipairs(SimpleDevToolsDB.builtIn) do
            AddMenuItem(entry.label, entry.command)
        end

        AddTitle()
        AddTitle("|cnDIM_GREEN_FONT_COLOR:»Addons|r")
        for _, entry in ipairs(SimpleDevToolsDB.addons) do
            AddMenuItem(entry.label, entry.command)
        end

        AddTitle()

        local info = UIDropDownMenu_CreateInfo()
        info.text = "|cnACCOUNT_WIDE_FONT_COLOR:Reload|r"
        info.func = function()
            local dialog = StaticPopupDialogs[confirmationDialogName]
            dialog.OnAccept = function()
                ReloadUI()
            end
            StaticPopup_Show(confirmationDialogName)
            CloseDropDownMenus()
        end
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, 1)
    end, "MENU")
end

CreateMenu()

function ldbObject.OnClick(self, button)
    if button == "LeftButton" then
        ToggleDropDownMenu(nil, nil, menuFrame, "cursor", 0, 0)
    elseif button == "RightButton" then
        Settings.OpenToCategory(SimpleDevTools.optionsPanel.name)
    end
end

function ldbObject.OnTooltipShow(tooltip)
    tooltip:SetText("SimpleDevTools")
    tooltip:AddLine("Left-click for options.")
    tooltip:AddLine("Right-click to open configuration.")
    tooltip:AddLine("This addon provides quick access to common developer tools.")
end