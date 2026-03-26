local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local MinimapButtonModule = SituationalAudioManager:NewModule("MinimapButton", "AceEvent-3.0")
local Logger = LibStub("LibSituationalLogger-1.0")
local ldb = LibStub("LibDataBroker-1.1")
local ldbi = LibStub("LibDBIcon-1.0")

function MinimapButtonModule:OnInitialize()
    SituationalAudioManager.db.profile.minimap = SituationalAudioManager.db.profile.minimap or { enabled = true }
    if not SituationalAudioManager.db.profile.minimap.enabled then
        ldbi:Hide(addonName)
        return
    end
    addonTable.broker = ldb:NewDataObject(addonName,{
        type = "data source", 
        text = "SAM", 
        icon = "Interface\\AddOns\\SituationalAudioManager\\Media\\Icon.tga",
        OnClick = function(_, button)
            if button == "LeftButton" then
                SituationalAudioManager:OpenDropdownMenu()
            elseif button == "RightButton" then
                if IsShiftKeyDown() then
                    SituationalAudioManager.db.profile.minimap.enabled = false
                    ldbi:Hide(addonName)
                else
                    SituationalAudioManager.Config:Show()
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Situational Audio Manager")
            tooltip:AddLine("Left-Click: Select Profile")
            tooltip:AddLine("Right-Click: Open Settings")
            tooltip:AddLine("Shift-Right-Click: Remove Minimap Button")
        end
    })

    ldbi:Register(addonName, addonTable.broker, SituationalAudioManager.db.profile.minimap)
end

function SituationalAudioManager:OpenDropdownMenu()
    if not self.dropdownMenu then
        self.dropdownMenu = CreateFrame("Frame", "SituationalAudioManagerIconDropdown", UIParent, "UIDropDownMenuTemplate")
    end

    UIDropDownMenu_Initialize(self.dropdownMenu, function(frame, level, menuList)
        local profiles = {}

        self.db:GetProfiles(profiles)
        local activeProfile = self.db:GetCurrentProfile()

        for _, name in ipairs(profiles) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.checked = name == activeProfile
            info.func = function()
                self.db:SetProfile(name)
            end
            UIDropDownMenu_AddButton(info)
        end

    end)

    ToggleDropDownMenu(1, nil, self.dropdownMenu, "cursor", 0, 0)
end