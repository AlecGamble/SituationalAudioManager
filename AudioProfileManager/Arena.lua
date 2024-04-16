local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local ArenaVolumeController = AudioProfileManager:NewModule("ArenaVolumeController", "AceEvent-3.0")

ArenaVolumeController.name = "Arena"

ArenaVolumeController.instanceName = "arena"

ArenaVolumeController.configOptions = {
    name = "Arena",
    type = 'group',
    disabled = function() return SAM.db.profile.overrides[ArenaVolumeController.name] == nil or SAM.db.profile.overrides[ArenaVolumeController.name].active == false end,
    hidden = function() return SAM.db.profile.overrides[ArenaVolumeController.name] == nil or SAM.db.profile.overrides[ArenaVolumeController.name].active == false end,
    args = {
        header = {
            name = "Arena Volume Settings",
            type = 'header',
            order = 10,
        },
        descriptionMessage = {
            name = "Volume settings to be used during Arena matches.",
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
                return SAM.db.profile.overrides[ArenaVolumeController.name].masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[ArenaVolumeController.name].masterVolume = v
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
                return SAM.db.profile.overrides[ArenaVolumeController.name].musicVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[ArenaVolumeController.name].musicVolume = v
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
                return SAM.db.profile.overrides[ArenaVolumeController.name].sfxVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[ArenaVolumeController.name].sfxVolume = v
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
                return SAM.db.profile.overrides[ArenaVolumeController.name].ambienceVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[ArenaVolumeController.name].ambienceVolume = v
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
                return SAM.db.profile.overrides[ArenaVolumeController.name].dialogVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[ArenaVolumeController.name].dialogVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        }
    }
}

function ArenaVolumeController:InitializeDefaultValues()
    SAM.db.profile.overrides[self.name] = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarMasterVolume)),
        musicVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarMusicVolume)),
        sfxVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarSfxVolume)),
        ambienceVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarAmbienceVolume)),
        dialogVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVarDialogVolume)),
        initialized = true,
    }
end

function ArenaVolumeController:ValidateSettings()
    if not SAM.db.profile.overrides[self.name] then
        self:InitializeDefaultValues()
    end 

    SAM.db.profile.overrides[self.name].masterVolume = max(0, min(1, SAM.db.profile.overrides[self.name].masterVolume))
    SAM.db.profile.overrides[self.name].musicVolume = max(0, min(1, SAM.db.profile.overrides[self.name].musicVolume))
    SAM.db.profile.overrides[self.name].sfxVolume = max(0, min(1, SAM.db.profile.overrides[self.name].sfxVolume))
    SAM.db.profile.overrides[self.name].ambienceVolume = max(0, min(1, SAM.db.profile.overrides[self.name].ambienceVolume))
    SAM.db.profile.overrides[self.name].dialogVolume = max(0, min(1, SAM.db.profile.overrides[self.name].dialogVolume))
end

function ArenaVolumeController:ApplyAudioSettings()
    SetCVar(AudioProfileManager.KEY_CVarMasterVolume, SAM.db.profile.overrides[self.name].masterVolume)
    SetCVar(AudioProfileManager.KEY_CVarMusicVolume, SAM.db.profile.overrides[self.name].musicVolume)
    SetCVar(AudioProfileManager.KEY_CVarSfxVolume, SAM.db.profile.overrides[self.name].sfxVolume)
    SetCVar(AudioProfileManager.KEY_CVarAmbienceVolume, SAM.db.profile.overrides[self.name].ambienceVolume)
    SetCVar(AudioProfileManager.KEY_CVarDialogVolume, SAM.db.profile.overrides[self.name].dialogVolume)
end

function ArenaVolumeController:Subscribe()
    self:RegisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld, ArenaVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop, ArenaVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStop, ArenaVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStop, ArenaVolumeController.OnEnterWorld)
    self:RegisterMessage(AudioProfileManager.KEY_Event_AddonRequest, ArenaVolumeController.OnEnterWorld)
end

function ArenaVolumeController:Unsubscribe()
    self:UnregisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStop)
    self:UnregisterMessage(AudioProfileManager.KEY_Event_AddonRequest)
end

function ArenaVolumeController.OnEnterWorld()
    -- being in an arena should not override cutscenes or talking heads
    if AudioProfileManager.Flags.InCutscene or AudioProfileManager.Flags.InVoiceover then return end

    local inInstance, instanceType = IsInInstance()

    if not inInstance then return end

    if instanceType == "arena" then
        DungeonVolumeController:ApplyAudioSettings()
    end
end

AudioProfileManager:RegisterOverride(ArenaVolumeController)