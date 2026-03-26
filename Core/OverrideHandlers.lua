local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
SituationalAudioManager.OverrideHandlers = {}
local Logger = LibStub("LibSituationalLogger-1.0")


SituationalAudioManager.OverrideHandlers.VolumeHandler = 
{
    Apply = function(def, value)
        if not def then
            Logger:LogError("Unable to apply Volume Handler due to a nil def.")
            return 
        end

        local num = tonumber(value)
        if not num then
            Logger:LogError("Unable to apply Volume Handler due to an invalid value type: %s.", type(value))
             return 
        end

        if def.Control.Min then num = max(def.Control.Min, num) end
        if def.Control.Max then num = min(def.Control.Max, num) end

        -- if def.Fade then
            SituationalAudioManager.SettingsEngine:FadeCVar(def.CVar, num, 1)
        -- else
        --     Logger:LogError("%s, %s", tostring(def.CVar), tostring(num))
        --     SetCVar(def.CVar, num)
        -- end
    end
}

SituationalAudioManager.OverrideHandlers.ToggleHandler = 
{
    Apply = function(cvar, value)
        SetCVar(cvar, value and 1 or 0)
    end
}