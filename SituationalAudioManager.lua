local addonName, addonTable = ...

SAM = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceComm-3.0", "AceTimer-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceEvent = LibStub("AceEvent-3.0")

-- default settings for a new profile
local defaultProfileSettings = {
    profile = {
        name = "Default",
        defaultVolumeSettings = { initialized = false },
        overrides = {},
        fixCutsceneBug = false,
        blendBetweenAudioProfiles = true
    }
}

function SAM:OnInitialize()
    -- setup app
    SAM.db = LibStub("AceDB-3.0"):New("SituationalAudioManager_Database", defaultProfileSettings, true)

    -- register chat commands
    SAM:RegisterChatCommand("sam", "SlashCommand")
    SAM:RegisterChatCommand("situationalaudiomanager", "SlashCommand")
end

function SAM:SlashCommand(msg)
    local args = {}

    for arg in string.gmatch(msg, "%S+") do
        table.insert(args, arg)
    end

    if #args >= 2 and string.lower(args[1]) == "profile" then
        for k,v in pairs(SAM.db:GetProfiles()) do
            if string.lower(args[2]) == string.lower(v) then
                SAM.db:SetProfile(v)                
                return nil
            end
        end
        SAM:LogWarning("No profile was found with name \""..args[2].."\". Please make sure one with this name exists in Options > Addons > SituationalAudioManager > Profiles.", SAM.LogLevels.Always)
        return nil
    elseif #args >= 1 and string.lower(args[1]) == "restart" then
        Sound_GameSystem_RestartSoundSystem()
    elseif #args >= 2 and string.lower(args[1]) == "log" then
        SAM:SetLogLevel(args[2])
    else
        -- must be called twice
        InterfaceOptionsFrame_OpenToCategory(SAM.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(SAM.optionsFrame)
        return nil
    end
end