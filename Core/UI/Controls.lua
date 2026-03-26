-- UI Controls Builder
local addonName, addonTable = ...
local SituationalAudioManager = LibStub("AceAddon-3.0"):GetAddon(addonName)
local Registry = SituationalAudioManager.CVarRegistry
local Logger = LibStub("LibSituationalLogger-1.0")

SituationalAudioManager.UI = SituationalAudioManager.UI or {}

------------------------------------------------
-- Range Slider
------------------------------------------------
-- context params:
-- label or cvar: the name shown next to the control
-- min: minimum value of the slider
-- max: maximum value of the slider
-- step: the slide delta of the range slider
-- getter: getter function
-- setter: setter function
------------------------------------------------
function SituationalAudioManager.UI.BuildRangeSlider(context)
    if not context then
        Logger:LogError("[Controls.BuildRangeSlider] No context was provided when building a range slider control.")
        return
    end

    if not context.min then
        Logger:LogError("[Controls.BuildRangeSlider] Context was malformed and did not provide a min value.")
        return
    end

    if not context.max then
        Logger:LogError("[Controls.BuildRangeSlider] Context was malformed and did not provide a max value.")
        return
    end

    if not context.getter then
        Logger:LogError("[Controls.BuildRangeSlider] Context was malformed and did not provide a getter function.")
        return
    end

    if not context.setter then
        Logger:LogError("[Controls.BuildRangeSlider] Context was malformed and did not provide a setter function.")
        return
    end

    return {
        type = "range",
        name = context.label or context.cvar or "",
        min = context.min, max = context.max, step = context.step or 0.01,
        get = context.getter,
        set = context.setter,
        hidden = context.hidden or function() return true end
    }
end

------------------------------------------------
-- Toggle
------------------------------------------------
-- context params:
-- label or cvar: the name shown next to the control
-- getter: getter function
-- setter: setter function
------------------------------------------------
function SituationalAudioManager.UI.BuildToggle(context)
    if not context then
        Logger:LogError("[Controls.BuildToggle] No context was provided when building a range slider control.")
        return
    end

    if not context.getter then
        Logger:LogError("[Controls.BuildToggle] Context was malformed and did not provide a getter function.")
        return
    end

    if not context.setter then
        Logger:LogError("[Controls.BuildToggle] Context was malformed and did not provide a setter function.")
        return
    end

    return {
        type = "toggle",
        name = context.label or context.CVar,
        get = context.getter,
        set = context.setter
    }
end

------------------------------------------------
-- Override Control Automation
------------------------------------------------
function SituationalAudioManager.UI.BuildOverride(contextKey, overrideKey)
    local contextDef = SituationalAudioManager.Contexts[contextKey]
    local overrideDef = SituationalAudioManager.OverrideRegistry[overrideKey]
    local overrideData = SituationalAudioManager.db.profile.contexts[contextKey].overrides[overrideKey]

    local control = nil

    if overrideDef.Control.Type == "toggle" then
        control = SituationalAudioManager.UI.BuildToggle({
            label = "",
            getter = function() return overrideData.value end,
            setter = function(_, v) 
                overrideData.value = v 
                SituationalAudioManager.SettingsEngine:Refresh()
            end,
            hidden = function() return not overrideData.enabled end
        })
    elseif overrideDef.Control.Type == "range" then
        control = SituationalAudioManager.UI.BuildRangeSlider({
            label = "",
            min = overrideDef.Control.Min or 0,
            max = overrideDef.Control.Max or 1,
            step = overrideDef.Control.Step or 0.01,
            getter = function() return overrideData.value end,
            setter = function(_, v) 
                overrideData.value = v 
                SituationalAudioManager.SettingsEngine:Refresh()
            end,
            hidden = function() return not overrideData.enabled end
        })
    else
        Logger:LogError("No control type was found for [%s].", context.control.type)
        return
    end

    control.order = 2
    
    local group = {
        type = "group",
        name = "",
        inline = true,
        args = 
        {
            enabled = 
            {
                type = "toggle",
                name = overrideDef.Name,
                width = "normal",
                get = function() return overrideData.enabled end,
                set = function(_, v) overrideData.enabled = v end,
                order = 1
            },
            control = control
        }
    }

    return group
end