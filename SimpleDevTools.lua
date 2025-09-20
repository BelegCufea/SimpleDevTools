-- Create a global addon table that will be shared between files.
SimpleDevTools = {}

-- Define the addon name as a property of the global table.
SimpleDevTools.addonName = "SimpleDevTools"

local L = LibStub("LibDataBroker-1.1")
local addonName = SimpleDevTools.addonName
local toolsIndent = "  "

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

-- Configuration popup
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
--- @param command string The slash command to run (e.g., "/lua").
local function RunCommand(command)
    DEFAULT_CHAT_FRAME.editBox:SetText(command)
    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
end

--- Build menu entries using MenuUtil
--- @param owner table The owner frame for the menu.
--- @param rootDescription table The menu description object.
local function SimpleDevToolsMenuGenerator(owner, rootDescription)
    rootDescription:CreateTitle("Simple Dev Tools")
    rootDescription:CreateDivider()

    -- Built-in tools
    rootDescription:CreateTitle("»Built-in")
    for _, entry in ipairs(SimpleDevToolsDB.builtIn) do
        rootDescription:CreateButton(toolsIndent .. entry.label, function()
            RunCommand(entry.command)
        end)
    end

    rootDescription:CreateSpacer()

    -- Addons
    rootDescription:CreateTitle("»Addons")
    for _, entry in ipairs(SimpleDevToolsDB.addons) do
        rootDescription:CreateButton(toolsIndent .. entry.label, function()
            RunCommand(entry.command)
        end)
    end

    rootDescription:CreateSpacer()

    -- Reload UI
    rootDescription:CreateButton("|cnACCOUNT_WIDE_FONT_COLOR:Reload|r", function()
        local dialog = StaticPopupDialogs[confirmationDialogName]
        dialog.OnAccept = function()
            ReloadUI()
        end
        StaticPopup_Show(confirmationDialogName)
    end)
end

-- Hook into LDB object
function ldbObject.OnClick(self, button)
    if button == "LeftButton" then
        MenuUtil.CreateContextMenu(self, SimpleDevToolsMenuGenerator)
    elseif button == "RightButton" then
        Settings.OpenToCategory(SimpleDevTools.optionsPanel.name)
    end
end

function ldbObject.OnTooltipShow(tooltip)
    tooltip:SetText("SimpleDevTools")
    tooltip:AddLine("Left-click for tools.")
    tooltip:AddLine("Right-click to open configuration.")
    tooltip:AddLine("Provides quick access to developer tools.")
end
