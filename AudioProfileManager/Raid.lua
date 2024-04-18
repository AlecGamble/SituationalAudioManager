local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local RaidVolumeController = AudioProfileManager:NewModule("RaidVolumeController", "AceEvent-3.0")

RaidVolumeController.name = "Raid"
RaidVolumeController.instanceName = "raid"


RaidVolumeController.configOptions = {
    name = "Raid",
    type = 'group',
    disabled = function() return SAM.db.profile.overrides[RaidVolumeController.name] == nil or SAM.db.profile.overrides[RaidVolumeController.name].active == false end,
    hidden = function() return SAM.db.profile.overrides[RaidVolumeController.name] == nil or SAM.db.profile.overrides[RaidVolumeController.name].active == false end,
    args = {
        header = {
            name = "Raid Volume Settings",
            type = 'header',
            order = 10,
        },
        descriptionMessage = {
            name = "Volume settings to be used during Raid instances.",
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
                return SAM.db.profile.overrides[RaidVolumeController.name].masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[RaidVolumeController.name].masterVolume = v
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
                return SAM.db.profile.overrides[RaidVolumeController.name].musicVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[RaidVolumeController.name].musicVolume = v
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
                return SAM.db.profile.overrides[RaidVolumeController.name].sfxVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[RaidVolumeController.name].sfxVolume = v
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
                return SAM.db.profile.overrides[RaidVolumeController.name].ambienceVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[RaidVolumeController.name].ambienceVolume = v
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
                return SAM.db.profile.overrides[RaidVolumeController.name].dialogVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[RaidVolumeController.name].dialogVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        }
    }
}

function RaidVolumeController:InitializeDefaultValues()
    SAM.db.profile.overrides[self.name] = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MasterVolume)),
        musicVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MusicVolume)),
        sfxVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_SfxVolume)),
        ambienceVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume)),
        dialogVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_DialogVolume)),
        initialized = true,
    }
end

function RaidVolumeController:ValidateSettings()
    if not SAM.db.profile.overrides[self.name] then
        self:InitializeDefaultValues()
    end 

    SAM.db.profile.overrides[self.name].masterVolume = max(0, min(1, SAM.db.profile.overrides[self.name].masterVolume))
    SAM.db.profile.overrides[self.name].musicVolume = max(0, min(1, SAM.db.profile.overrides[self.name].musicVolume))
    SAM.db.profile.overrides[self.name].sfxVolume = max(0, min(1, SAM.db.profile.overrides[self.name].sfxVolume))
    SAM.db.profile.overrides[self.name].ambienceVolume = max(0, min(1, SAM.db.profile.overrides[self.name].ambienceVolume))
    SAM.db.profile.overrides[self.name].dialogVolume = max(0, min(1, SAM.db.profile.overrides[self.name].dialogVolume))
end

function RaidVolumeController:ApplyAudioSettings()
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

function RaidVolumeController:Subscribe()
    SAM:Log("Subscribed to: "..self.name, SAM.LogLevels.Verbose)

    self:RegisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld, RaidVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop, RaidVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStop, RaidVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStop, RaidVolumeController.OnEnterWorld)
    self:RegisterMessage(AudioProfileManager.KEY_Event_AddonRequest, RaidVolumeController.OnEnterWorld)
end

function RaidVolumeController:Unsubscribe()
    SAM:Log("Unsubscribed from: "..self.name, SAM.LogLevels.Verbose)

    self:UnregisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStop)
    self:UnregisterMessage(AudioProfileManager.KEY_Event_AddonRequest)
end

function RaidVolumeController.OnEnterWorld()
    if AudioProfileManager.ActiveProfile == RaidVolumeController.name then return end

    -- being in a raid should not override cutscenes or talking heads
    if AudioProfileManager.Flags.InCutscene or AudioProfileManager.Flags.InVoiceover then return end

    local inInstance, instanceType = IsInInstance()

    if not inInstance then return end

    if instanceType == "raid" then
        RaidVolumeController:ApplyAudioSettings()
    end
end

AudioProfileManager:RegisterOverride(RaidVolumeController)