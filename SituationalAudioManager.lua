local addonName, addonTable = ...
SituationalAudioManager = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceComm-3.0", "AceTimer-3.0", "AceEvent-3.0")
local Logger = LibStub("LibSituationalLogger-1.0")

-- default settings for a new profile
local defaultProfileSettings = 
{
    profile = 
    {
        name = "Default",
        defaultVolumeSettings = { initialized = false },
        overrides = {},
        enabledContexts = {},
        fixCutsceneBug = false,
        blendBetweenAudioProfiles = true,
        disableTalkingHead = false
    }
}

function SituationalAudioManager:OnInitialize()
    -- setup app
    self.db = LibStub("AceDB-3.0"):New("SituationalAudioManager_Database", defaultProfileSettings, true)
    self:EnsureDBIntegrity()
    SituationalLogger_Database = SituationalLogger_Database or {}
    Logger:Initialise(SituationalLogger_Database)

    -- register chat commands
    SituationalAudioManager:RegisterChatCommand("sam", "SlashCommand")
    SituationalAudioManager:RegisterChatCommand("situationalaudiomanager", "SlashCommand")

    self.SettingsEngine:Apply()
end

function SituationalAudioManager:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteredWorld")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnZoneChangedNewArea")
    self:RegisterEvent("ZONE_CHANGED_INDOORS", "OnZoneChangedIndoors")
end

function SituationalAudioManager:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD", "OnPlayerEnteredWorld")
    self:UnregisterEvent("ZONE_CHANGED_NEW_AREA", "OnZoneChangedNewArea")
    self:UnregisterEvent("ZONE_CHANGED_INDOORS", "OnZoneChangedIndoors")
end

function SituationalAudioManager:OnPlayerEnteredWorld()
    Logger:Log(Logger.LogLevels.verbose, "Update triggered from PLAYER_ENTERING_WORLD")
    self.SettingsEngine:Apply()
end

function SituationalAudioManager:OnZoneChangedNewArea()
    Logger:Log(Logger.LogLevels.verbose, "Update triggered from ZONE_CHANGED_NEW_AREA")
    self.SettingsEngine:Apply()
end

function SituationalAudioManager:OnZoneChangedIndoors()
    Logger:Log(Logger.LogLevels.verbose, "Update triggered from ZONE_CHANGED_INDOORS")
    self.SettingsEngine:Apply()
end

function SituationalAudioManager:RegisterContext(context)
    self.Contexts = self.Contexts or {}
    self.ContextKeys = self.ContextKeys or {}
    self.PrioritisedContexts = self.PrioritisedContexts or {}

    table.insert(self.ContextKeys, context.key)
    table.insert(self.PrioritisedContexts, context)
    self.Contexts[context.key] = context
    table.sort(self.PrioritisedContexts, function(a,b) return a.priority > b.priority end)
    if context.OnEnable then
        context:OnEnable()
    end
end

function SituationalAudioManager:SlashCommand(msg)
    local args = {}

    for arg in string.gmatch(string.lower(msg), "%S+") do
        table.insert(args, arg)
    end

    if #args == 0 then
        -- self.Config:Show()
        Settings.OpenToCategory(self.optionsFrame.name)
        return nil
    end

    local command = args[1]

    if command == "profile" and #args >= 2 then
        local profileName = args[2]
        for key, value in pairs(SituationalAudioManager.db:GetProfiles()) do
            if profileName == string.lower(value) then
                SituationalAudioManager.db:SetProfile(value)                
                return nil
            end
        end
        Logger:LogWarning("No profile was found with name \"%s\". Please make sure one with this name exists in Options > Addons > SituationalAudioManager > Profiles.", profileName)
        return nil
    elseif command == "restart" then
        Sound_GameSystem_RestartSoundSystem()
    elseif command == "log" or command == "loglevel" then
        Logger:SetLogLevel(args[2])
    else
        Settings.OpenToCategory(self.optionsFrame.name)
        return nil
    end
end

function SituationalAudioManager:EnsureDBIntegrity()
    -- Ensure root context table exists
    local profileRecord = self.db.profile
    profileRecord.contexts = profileRecord.contexts or {}

    -- Ensure all registered context records exist
    for contextKey, contextDef in pairs(self.Contexts) do
        profileRecord.contexts[contextKey] = profileRecord.contexts[contextKey] or {}
        local contextRecord = profileRecord.contexts[contextKey]
        contextRecord.overrides = contextRecord.overrides or {}

        -- Ensure records for all overrides in context exist
        for _, overrideKey in ipairs(contextDef.overrides) do
            local overrideDef = self.OverrideRegistry[overrideKey]
            if overrideDef then
                contextRecord.overrides[overrideKey] = contextRecord.overrides[overrideKey] or {}
                local overrideRecord = contextRecord.overrides[overrideKey]

                -- If override is missing, default to false
                if overrideRecord.enabled == nil or overrideRecord.value == nil then
                    Logger:Log(Logger.LogLevels.debug, "Initialising override %s.%s", contextKey, overrideKey)
                    overrideRecord.enabled = false
                    overrideRecord.value = tonumber(GetCVar(overrideDef.CVar))
                end
            else
                Logger:Error("[SituationalAudioManager:EnsureDBIntegrity] Could not find override definition in registry for %s.", overrideKey)
            end
        end
    end
end