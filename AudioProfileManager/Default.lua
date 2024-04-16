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
                AudioProfileManager:RefreshConfig()
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
                AudioProfileManager:RefreshConfig()
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
                AudioProfileManager:RefreshConfig()
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
                AudioProfileManager:RefreshConfig()
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
                AudioProfileManager:RefreshConfig()
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
    if not SAM.db.profile.defaultVolumeSettings or SAM.db.profile.defaultVolumeSettings.initialized == false then
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

function DefaultVolumeController:Subscribe()
    self:RegisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld, DefaultVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop, DefaultVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStop, DefaultVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStop, DefaultVolumeController.OnEnterWorld)
    self:RegisterMessage(AudioProfileManager.KEY_Event_AddonRequest, DefaultVolumeController.OnEnterWorld)
end

function DefaultVolumeController:Unsubscribe()
    self:UnregisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStop)
    self:UnregisterMessage(AudioProfileManager.KEY_Event_AddonRequest)
end

function DefaultVolumeController.OnEnterWorld()
    -- default volume controller should not override cutscenes or talking heads
    if AudioProfileManager.Flags.InCutscene or AudioProfileManager.Flags.InVoiceover then return end

    local inInstance, instanceType = IsInInstance()

    -- TODO:
    -- not technically correct. If there is no override for the specific instance the default volume controller should be used in sed instance.
    if not inInstance then
        DefaultVolumeController:ApplyAudioSettings()
    end
end

AudioProfileManager.DefaultAudioProfile = DefaultVolumeController