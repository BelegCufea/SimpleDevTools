local L = LibStub("LibDataBroker-1.1")
local addonName = "SimpleDevTools"

-- Create the LDB data object
local ldbObject = L:NewDataObject(addonName, {
    type = "launcher",
    icon = [[Interface\Icons\INV_Misc_Gear_03]],
    label = "DevTools",
    text = "DevTools",
})

-- Create a menu frame to hold our dropdown menu
local menuFrame = CreateFrame("Frame", "SimpleDevToolsMenu", UIParent, "UIDropDownMenuTemplate")

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
    info.text = label
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


-- A function to create and populate the dropdown menu
local function CreateMenu()
    UIDropDownMenu_Initialize(menuFrame, function(self, level)
        if level ~= 1 then return end

        AddTitle("Simple Dev Tools")

        AddMenuItem("WoWLUA", "/lua")
        AddMenuItem("Dev", "/dev")
        AddMenuItem("Code", "/cube code")
        AddMenuItem("API", "/apii")
        AddMenuItem("Profiler", "/nap")

        AddTitle()

        -- Reload Game
        local info = UIDropDownMenu_CreateInfo()
        info = UIDropDownMenu_CreateInfo()
        info.text = "|cnACCOUNT_WIDE_FONT_COLOR:Reload|r"
        info.func = function()
            ReloadUI()
            CloseDropDownMenus()
        end
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, 1)

        AddTitle()
        AddTitle("|cnADVENTURES_COMBAT_LOG_GREY:Click to run appropriate addon.|r")
    end, "MENU")
end

-- Initialize the menu
CreateMenu()

-- Disable tooltip
ldbObject.OnTooltipShow = nil

-- Show the dropdown on hover
ldbObject.OnEnter = function(self)
    ToggleDropDownMenu(nil, nil, menuFrame, "cursor", 0, 0)
end

-- Sticky hover close logic
ldbObject.OnLeave = function(self)
    C_Timer.After(0.2, function()
        -- check both the broker icon and the menu
        if not MouseIsOver(self) and not MouseIsOver(menuFrame) then
            CloseDropDownMenus()
        end
    end)
end

-- Also hook the menu itself, so leaving it closes things
menuFrame:SetScript("OnLeave", function(self)
    C_Timer.After(0.2, function()
        -- check both again, in case mouse went back to icon
        if not MouseIsOver(self) and not MouseIsOver(LibStub("LibDataBroker-1.1").objects[addonName]) then
            CloseDropDownMenus()
        end
    end)
end)