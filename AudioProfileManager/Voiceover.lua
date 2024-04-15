local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local VoiceoverVolumeController = AudioProfileManager:NewModule("VoiceoverVolumeController", "AceEvent-3.0")

local override = {}

override.name = "Voiceover"

override.configOptions = {
    name = "",
    type = 'group',
    inline = true,
    disabled = function() return SAM.db.profile.overrides[override.name] == nil or SAM.db.profile.overrides[override.name].active == false end,
    hidden = function() return SAM.db.profile.overrides[override.name] == nil or SAM.db.profile.overrides[override.name].active == false end,
    args = {
        header = {
            name = "Voiceover Volume Settings",
            type = 'header',
            order = 10,
        },
        descriptionMessage = {
            name = "Volume settings to be used when a voiceover is playing.",
            type = 'description',
            order = 11,
        },
        masterVolume = {
            name = "Master Volume",
            type = 'range',
            order = 12,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[override.name].masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].masterVolume = v
                if AudioProfileManager.ActiveVolumeController == override then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
            end,
        },
        musicVolume = {
            name = "Music Volume",
            type = 'range',
            order = 13,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[override.name].musicVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].musicVolume = v
                if AudioProfileManager.ActiveVolumeController == override then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
            end,
        },
        sfxVolume = {
            name = "SFX Volume",
            type = 'range',
            order = 14,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[override.name].sfxVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].sfxVolume = v
                if AudioProfileManager.ActiveVolumeController == override then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
            end,
        },
        ambienceVolume = {
            name = "Ambience Volume",
            type = 'range',
            order = 15,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[override.name].ambienceVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].ambienceVolume = v
                if AudioProfileManager.ActiveVolumeController == override then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
            end,
        },
        dialogVolume = {
            name = "Dialog Volume",
            type = 'range',
            order = 16,
            min = 0,
            max = 1,
            step = 0.05,
            isPercent=true,
            get = function(info)
                return SAM.db.profile.overrides[override.name].dialogVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[override.name].dialogVolume = v
                if AudioProfileManager.ActiveVolumeController == override then
                    AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
                end
            end,
        }
    }
}

function override:InitializeDefaultValues()
    SAM.db.profile.overrides[override.name] = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MasterVolume)),
        musicVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MusicVolume)),
        sfxVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_SfxVolume)),
        ambienceVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume)),
        dialogVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_DialogVolume)),
        initialized = true,
    }
end

function override:ValidateSettings()
    if not SAM.db.profile.overrides[override.name] then
        override:InitializeDefaultValues()
    end 

    SAM.db.profile.overrides[override.name].masterVolume = max(0, min(1, SAM.db.profile.overrides[override.name].masterVolume))
    SAM.db.profile.overrides[override.name].musicVolume = max(0, min(1, SAM.db.profile.overrides[override.name].musicVolume))
    SAM.db.profile.overrides[override.name].sfxVolume = max(0, min(1, SAM.db.profile.overrides[override.name].sfxVolume))
    SAM.db.profile.overrides[override.name].ambienceVolume = max(0, min(1, SAM.db.profile.overrides[override.name].ambienceVolume))
    SAM.db.profile.overrides[override.name].dialogVolume = max(0, min(1, SAM.db.profile.overrides[override.name].dialogVolume))
end

function override:ApplyAudioSettings()
    SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, SAM.db.profile.overrides[override.name].masterVolume)
    SetCVar(AudioProfileManager.KEY_CVar_MusicVolume, SAM.db.profile.overrides[override.name].musicVolume)
    SetCVar(AudioProfileManager.KEY_CVar_SfxVolume, SAM.db.profile.overrides[override.name].sfxVolume)
    SetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume, SAM.db.profile.overrides[override.name].ambienceVolume)
    SetCVar(AudioProfileManager.KEY_CVar_DialogVolume, SAM.db.profile.overrides[override.name].dialogVolume)
end

function RegisterListeners()
end

function UnregisterListeners()
end

function override:ShouldBeActive(eventName)
    
    if eventName == "TALKINGHEAD_REQUESTED" then
        return true
    end

    return false
end

AudioProfileManager:RegisterOverride(override)