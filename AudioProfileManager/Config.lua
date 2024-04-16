local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")

local unappliedOverrides = {}
local appliedOverrides = {}

local options = {
    name = "Volume Settings",
    type = 'group',
    childGroups = "tab",
    order = 40,
    args = {
        overridesHeader = {
            name = "Overrides",
            type = 'header',
            order = 20
        },
        overridesDescription = {
            name = "Add overrides to automatically change the volume settings when entering an activity or cutscene.",
            type = 'description',
            order = 21
        },
        addOveride = {
            name = "Add Override",
            type = 'select',
            order = 22,
            values = unappliedOverrides,
            set = function(info, id)
                -- edge case for empty unapplied overrides list
                if id == "" then
                    return 
                end

                local override = AudioProfileManager.Overrides[id]

                if override == nil then
                    return
                end

                if SAM.db.profile.overrides[id] == nil or SAM.db.profile.overrides[id].initialized == false then
                    override:InitializeDefaultValues()
                end

                SAM.db.profile.overrides[id].active = true
                override:ValidateSettings()
                override:Subscribe()
                AudioProfileManager:RefreshConfig()
                AudioProfileManager:UpdateAppliedOverrides()
            end
        },
        removeOveride = {
            name = "Remove Override",
            type = 'select',
            order = 23,
            values = appliedOverrides,
            set = function(info, id)
                local override = AudioProfileManager.Overrides[id]

                -- edge case for empty applied overrides list
                if not SAM.db.profile.overrides[id] then
                    return
                end

                SAM.db.profile.overrides[id].active = false

                if override.Unsubscribe ~= nil then
                    override:Unsubscribe()
                end
                
                AudioProfileManager:UpdateAppliedOverrides()
                AudioProfileManager:RefreshConfig()
            end
        }
    }
}

function AudioProfileManager:RegisterConfig()
    local config = SAM:GetModule("Config")
    
    if not config then
        return
    end

    options.args[AudioProfileManager.DefaultAudioProfile.name] = AudioProfileManager.DefaultAudioProfile.configOptions

    for k, override in pairs(AudioProfileManager.Overrides) do
        options.args[override.name] = override.configOptions
    end

    config.options.plugins.volumeSettings = { volumeSettings = options }
end

function AudioProfileManager:UpdateAppliedOverrides()
    local appliedOverridesCount = 0
    local unappliedOverridesCount = 0

    for k, override in pairs(AudioProfileManager.Overrides) do 
        if SAM.db.profile.overrides[override.name] and SAM.db.profile.overrides[override.name].active then
            appliedOverrides[override.name] = override.name
            unappliedOverrides[override.name] = nil
            
            appliedOverridesCount = appliedOverridesCount + 1
        else
            appliedOverrides[override.name] = nil
            unappliedOverrides[override.name] = override.name

            unappliedOverridesCount = unappliedOverridesCount + 1
        end
    end

    -- stops the list displaying as an infinite length in situations where there are no elements
    appliedOverrides[""] = appliedOverridesCount == 0 and "" or nil
    unappliedOverrides[""] = unappliedOverridesCount == 0 and "" or nil
end