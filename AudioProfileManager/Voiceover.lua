local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local VoiceoverVolumeController = AudioProfileManager:NewModule("VoiceoverVolumeController", "AceEvent-3.0")

VoiceoverVolumeController.name = "Voiceover"

VoiceoverVolumeController.configOptions = {
    name = "Voiceover",
    type = 'group',
    disabled = function() return SAM.db.profile.overrides[VoiceoverVolumeController.name] == nil or SAM.db.profile.overrides[VoiceoverVolumeController.name].active == false end,
    hidden = function() return SAM.db.profile.overrides[VoiceoverVolumeController.name] == nil or SAM.db.profile.overrides[VoiceoverVolumeController.name].active == false end,
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
                return SAM.db.profile.overrides[VoiceoverVolumeController.name].masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[VoiceoverVolumeController.name].masterVolume = v
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
                return SAM.db.profile.overrides[VoiceoverVolumeController.name].musicVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[VoiceoverVolumeController.name].musicVolume = v
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
                return SAM.db.profile.overrides[VoiceoverVolumeController.name].sfxVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[VoiceoverVolumeController.name].sfxVolume = v
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
                return SAM.db.profile.overrides[VoiceoverVolumeController.name].ambienceVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[VoiceoverVolumeController.name].ambienceVolume = v
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
                return SAM.db.profile.overrides[VoiceoverVolumeController.name].dialogVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[VoiceoverVolumeController.name].dialogVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        }
    }
}

function VoiceoverVolumeController:InitializeDefaultValues()
    SAM.db.profile.overrides[self.name] = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MasterVolume)),
        musicVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MusicVolume)),
        sfxVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_SfxVolume)),
        ambienceVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume)),
        dialogVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_DialogVolume)),
        initialized = true,
    }
end

function VoiceoverVolumeController:ValidateSettings()
    if not SAM.db.profile.overrides[self.name] then
        override:InitializeDefaultValues()
    end 

    SAM.db.profile.overrides[self.name].masterVolume = max(0, min(1, SAM.db.profile.overrides[self.name].masterVolume))
    SAM.db.profile.overrides[self.name].musicVolume = max(0, min(1, SAM.db.profile.overrides[self.name].musicVolume))
    SAM.db.profile.overrides[self.name].sfxVolume = max(0, min(1, SAM.db.profile.overrides[self.name].sfxVolume))
    SAM.db.profile.overrides[self.name].ambienceVolume = max(0, min(1, SAM.db.profile.overrides[self.name].ambienceVolume))
    SAM.db.profile.overrides[self.name].dialogVolume = max(0, min(1, SAM.db.profile.overrides[self.name].dialogVolume))
end

function VoiceoverVolumeController:ApplyAudioSettings()
    SAM:Log("Applying: "..self.name, SAM.LogLevels.Verbose)

    AudioProfileManager.ActiveProfile = self.name

    if SAM.db.profile.blendBetweenAudioProfiles then
        AudioProfileManager:BlendToNewAudioProfile(
            SAM.db.profile.overrides[self.name].masterVolume,
            SAM.db.profile.overrides[self.name].musicVolume,
            SAM.db.profile.overrides[self.name].sfxVolume,
            SAM.db.profile.overrides[self.name].ambienceVolume,
            SAM.db.profile.overrides[self.name].dialogVolume
        )
    else
        AudioProfileManager:SetAudioProfile(
            SAM.db.profile.overrides[self.name].masterVolume,
            SAM.db.profile.overrides[self.name].musicVolume,
            SAM.db.profile.overrides[self.name].sfxVolume,
            SAM.db.profile.overrides[self.name].ambienceVolume,
            SAM.db.profile.overrides[self.name].dialogVolume
        )
    end
end

function VoiceoverVolumeController:Subscribe()
    SAM:Log("Subscribed to: "..self.name, SAM.LogLevels.Verbose)

    self:RegisterEvent(AudioProfileManager.KEY_Event_VoiceoverStart, VoiceoverVolumeController.OnVoiceoverStart)
    self:RegisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop, VoiceoverVolumeController.OnVoiceoverStop)
end

function VoiceoverVolumeController:Unsubscribe()
    SAM:Log("Unsubscribed from: "..self.name, SAM.LogLevels.Verbose)

    self:UnregisterEvent(AudioProfileManager.KEY_Event_VoiceoverStart)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop)
end

function VoiceoverVolumeController.OnVoiceoverStart()
    AudioProfileManager.Flags.InVoiceover = true

    if AudioProfileManager.ActiveProfile == VoiceoverVolumeController.name then return end

    VoiceoverVolumeController:ApplyAudioSettings()
end

function VoiceoverVolumeController.OnVoiceoverStop()
    AudioProfileManager.Flags.InVoiceover = false
    VoiceoverVolumeController:SendMessage(AudioProfileManager.KEY_Event_AddonRequest)
end

function VoiceoverVolumeController.UpdateEvent(event)
    if eventName == AudioProfileManager.KEY_Event_VoiceoverStart then
    elseif eventName == AudioProfileManager.KEY_Event_VoiceoverStop or eventName == AudioProfileManager.KEY_Event_MovieStop then
        AudioProfileManager.Flags.InVoiceover = false
    end
end

AudioProfileManager:RegisterOverride(VoiceoverVolumeController)