local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local Registry = SituationalAudioManager.OverrideRegistry

local ContextsPage = {}

function ContextsPage:BuildContextPage(contextDef)
    overrideControls = {}
    overrideControls["header"] = 
    {
        name = string.format("%s Volume Settings",contextDef.name),
        type = "header",
        order = 0
    }

    for index, overrideKey in ipairs(contextDef.overrides) do
        local overrideControl = SituationalAudioManager.UI.BuildOverride(contextDef.key, overrideKey)
        overrideControl.order = index
        overrideControls[overrideKey] = overrideControl
    end

    local page = 
    {
        name = tostring(contextDef.name),
        type = "group",
        order = contextDef.menuOrder,
        args = overrideControls
    }
    
    return page
end

function ContextsPage:GetOptions()
    local contextPages = {}
    for index, contextKey in ipairs(SituationalAudioManager.ContextKeys) do
        local contextDef = SituationalAudioManager.Contexts[contextKey]
        contextPages[contextKey] = self:BuildContextPage(contextDef)
    end

    return 
    {
        name = "Situations",
        desc = "Settings for overriding volume settings under specific conditions (zone, activity etc.).",
        type = "group",
        order = 30,
        childGroups = "select",
        args = contextPages
    }
end

SituationalAudioManager.ConfigPages = SituationalAudioManager.ConfigPages or {}
SituationalAudioManager.ConfigPages.ContextsPage = ContextsPage