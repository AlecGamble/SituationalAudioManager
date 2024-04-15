local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local DefaultVolumeController = AudioProfileManager:NewModule("DefaultVolumeController", "AceEvent-3.0")

DefaultVolumeController.name = "Default"

DefaultVolumeController.configOptions = {
    name = "",
    type = 'group',
    inline = true,
    order = 10,
    args = {
        defaultVolumeHeader = {
            name = "Default Volume Settings",
            type = 'header',
            order = 10,
        },
        defaultVolumeDescription = {
            name = "The volume settings to use in general content.\n\n|cffff8000These settings will override Blizzard's audio options so adjust your volume settings here instead.|r",
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
                return SAM.db.profile.defaultVolumeSettings.masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.defaultVolumeSettings.masterVolume = v
                AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
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
                return SAM.db.profile.defaultVolumeSettings.musicVolume
            end,
            set = function(info, v)
                SAM.db.profile.defaultVolumeSettings.musicVolume = v
                AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
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
                return SAM.db.profile.defaultVolumeSettings.sfxVolume
            end,
            set = function(info, v)
                SAM.db.profile.defaultVolumeSettings.sfxVolume = v
                AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
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
                return SAM.db.profile.defaultVolumeSettings.ambienceVolume
            end,
            set = function(info, v)
                SAM.db.profile.defaultVolumeSettings.ambienceVolume = v
                AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
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
                return SAM.db.profile.defaultVolumeSettings.dialogVolume
            end,
            set = function(info, v)
                SAM.db.profile.defaultVolumeSettings.dialogVolume = v
                AudioProfileManager.ActiveVolumeController:ApplyAudioSettings()
            end,
        },
    }
}

function DefaultVolumeController:InitializeDefaultValues()
    SAM.db.profile.defaultVolumeSettings = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MasterVolume)),
        musicVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MusicVolume)),
        sfxVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_SfxVolume)),
        ambienceVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume)),
        dialogVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_DialogVolume)),
        initialized = true
    }
end

function DefaultVolumeController:ValidateSettings()
    if not SAM.db.profile.defaultVolumeSettings then
        DefaultVolumeController:InitializeDefaultValues()
    end 

    SAM.db.profile.defaultVolumeSettings.masterVolume = max(0, min(1, SAM.db.profile.defaultVolumeSettings.masterVolume))
    SAM.db.profile.defaultVolumeSettings.musicVolume = max(0, min(1, SAM.db.profile.defaultVolumeSettings.musicVolume))
    SAM.db.profile.defaultVolumeSettings.sfxVolume = max(0, min(1, SAM.db.profile.defaultVolumeSettings.sfxVolume))
    SAM.db.profile.defaultVolumeSettings.ambienceVolume = max(0, min(1, SAM.db.profile.defaultVolumeSettings.ambienceVolume))
    SAM.db.profile.defaultVolumeSettings.dialogVolume = max(0, min(1, SAM.db.profile.defaultVolumeSettings.dialogVolume))
end

function DefaultVolumeController:ApplyAudioSettings()
    SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, SAM.db.profile.defaultVolumeSettings.masterVolume)
    SetCVar(AudioProfileManager.KEY_CVar_MusicVolume, SAM.db.profile.defaultVolumeSettings.musicVolume)
    SetCVar(AudioProfileManager.KEY_CVar_SfxVolume, SAM.db.profile.defaultVolumeSettings.sfxVolume)
    SetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume, SAM.db.profile.defaultVolumeSettings.ambienceVolume)
    SetCVar(AudioProfileManager.KEY_CVar_DialogVolume, SAM.db.profile.defaultVolumeSettings.dialogVolume)
end

AudioProfileManager.DefaultAudioProfile = DefaultVolumeController