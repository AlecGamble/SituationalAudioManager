local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SituationalAudioManager:NewModule("AudioProfileManager", "AceEvent-3.0")
local Logger = LibStub("LibSituationalLogger-1.0")
local Registry = SituationalAudioManager.OverrideRegistry
local Handlers = SituationalAudioManager.OverrideHandlers

local SettingsEngine = {}
SettingsEngine.FadeFrame = CreateFrame("Frame")
SettingsEngine.FadeFrame.ActiveFades = {}

------------------------------------------------
-- Construct Settings Table
------------------------------------------------
function SettingsEngine:GetSettings()
    local db = SituationalAudioManager.db.profile
    local settings = {}

    if not Registry then
        Logger:Error("Unable to load override registry")
        return
    end

    for overrideKey, overrideDef in pairs(Registry) do
        local applied = false

        for _, context in ipairs(SituationalAudioManager.PrioritisedContexts) do
            if not applied and context:IsActive() then
                local overrideData = db.contexts[context.key].overrides[overrideKey]
                if overrideData then
                    if overrideData.enabled then
                        table.insert(settings, { source = context.name, def = overrideDef, value = overrideData.value })
                        applied = true
                    end
                end
            end
        end
    end
    return settings
end

------------------------------------------------
-- Apply Settings
------------------------------------------------
function SettingsEngine:Apply()
    local settings = self:GetSettings()

    for _, setting in ipairs(settings) do
        local handler = Handlers[setting.def.Handler]
        if handler then
            Logger:Log(Logger.LogLevels.verbose, "Applying %s from %s: %s", setting.def.Name, setting.source, tostring(setting.value))
            handler.Apply(setting.def, setting.value)
        end
    end
end

------------------------------------------------
-- Fade CVar
------------------------------------------------
function SettingsEngine:FadeCVar(cvar, targetValue, duration)
    local startValue = tonumber(GetCVar(cvar)) or 0
    local startTime = GetTime()

    self.FadeFrame = self.FadeFrame or CreateFrame("Frame")
    self.FadeFrame.ActiveFades = self.FadeFrame.ActiveFades or {}

    self.FadeFrame.ActiveFades[cvar] = 
    {
        startValue = startValue,
        startTime = startTime,
        targetValue = targetValue,
        duration = duration
    }

    self.FadeFrame:SetScript("OnUpdate", function(frame)
        local time = GetTime()
        local active = true

        for cvar, fade in pairs(frame.ActiveFades) do
            local progress = (time - fade.startTime) / fade.duration
            if progress >= 1 then
                SetCVar(cvar, fade.targetValue)
                frame.ActiveFades[cvar] = nil
            else
                local value = addonTable.Utils.lerp(fade.startValue, fade.targetValue, progress)
                SetCVar(cvar, value)
            end
        end

        if not next(frame.ActiveFades) then
            frame:SetScript("OnUpdate", nil)
        end
    end)
end

------------------------------------------------
-- Update Settings
------------------------------------------------
function SettingsEngine:Refresh()
    self:Apply()
end

SituationalAudioManager.SettingsEngine = SettingsEngine