local addonName, addonTable = ...

local SAM = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AudioProfileManager = SAM:GetModule("AudioProfileManager")
local DungeonVolumeController = AudioProfileManager:NewModule("DungeonVolumeController", "AceEvent-3.0")

DungeonVolumeController.name = "Dungeon"
DungeonVolumeController.instanceName = "party"

DungeonVolumeController.configOptions = {
    name = "Dungeon",
    type = 'group',
    disabled = function() return SAM.db.profile.overrides[DungeonVolumeController.name] == nil or SAM.db.profile.overrides[DungeonVolumeController.name].active == false end,
    hidden = function() return SAM.db.profile.overrides[DungeonVolumeController.name] == nil or SAM.db.profile.overrides[DungeonVolumeController.name].active == false end,
    args = {
        header = {
            name = "Dungeon Volume Settings",
            type = 'header',
            order = 10,
        },
        descriptionMessage = {
            name = "Volume settings to be used during Dungeon instances.",
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].masterVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].masterVolume = v
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].musicVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].musicVolume = v
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].sfxVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].sfxVolume = v
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].ambienceVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].ambienceVolume = v
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
                return SAM.db.profile.overrides[DungeonVolumeController.name].dialogVolume
            end,
            set = function(info, v)
                SAM.db.profile.overrides[DungeonVolumeController.name].dialogVolume = v
                AudioProfileManager:RefreshConfig()
            end,
        }
    }
}

function DungeonVolumeController:InitializeDefaultValues()
    SAM.db.profile.overrides[self.name] = {
        masterVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MasterVolume)),
        musicVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_MusicVolume)),
        sfxVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_SfxVolume)),
        ambienceVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume)),
        dialogVolume = tonumber(GetCVar(AudioProfileManager.KEY_CVar_DialogVolume)),
        initialized = true,
    }
end

function DungeonVolumeController:ValidateSettings()
    if not SAM.db.profile.overrides[self.name] then
        self:InitializeDefaultValues()
    end 

    SAM.db.profile.overrides[self.name].masterVolume = max(0, min(1, SAM.db.profile.overrides[self.name].masterVolume))
    SAM.db.profile.overrides[self.name].musicVolume = max(0, min(1, SAM.db.profile.overrides[self.name].musicVolume))
    SAM.db.profile.overrides[self.name].sfxVolume = max(0, min(1, SAM.db.profile.overrides[self.name].sfxVolume))
    SAM.db.profile.overrides[self.name].ambienceVolume = max(0, min(1, SAM.db.profile.overrides[self.name].ambienceVolume))
    SAM.db.profile.overrides[self.name].dialogVolume = max(0, min(1, SAM.db.profile.overrides[self.name].dialogVolume))
end

function DungeonVolumeController:ApplyAudioSettings()
    SetCVar(AudioProfileManager.KEY_CVar_MasterVolume, SAM.db.profile.overrides[self.name].masterVolume)
    SetCVar(AudioProfileManager.KEY_CVar_MusicVolume, SAM.db.profile.overrides[self.name].musicVolume)
    SetCVar(AudioProfileManager.KEY_CVar_SfxVolume, SAM.db.profile.overrides[self.name].sfxVolume)
    SetCVar(AudioProfileManager.KEY_CVar_AmbienceVolume, SAM.db.profile.overrides[self.name].ambienceVolume)
    SetCVar(AudioProfileManager.KEY_CVar_DialogVolume, SAM.db.profile.overrides[self.name].dialogVolume)
end

function DungeonVolumeController:Subscribe()
    self:RegisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld, DungeonVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop, DungeonVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_CinematicStop, DungeonVolumeController.OnEnterWorld)
    self:RegisterEvent(AudioProfileManager.KEY_Event_MovieStop, DungeonVolumeController.OnEnterWorld)
    self:RegisterMessage(AudioProfileManager.KEY_Event_AddonRequest, DungeonVolumeController.OnEnterWorld)
end

function DungeonVolumeController:Unsubscribe()
    self:UnregisterEvent(AudioProfileManager.KEY_Event_PlayerEnteringWorld)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_VoiceoverStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_CinematicStop)
    self:UnregisterEvent(AudioProfileManager.KEY_Event_MovieStop)
    self:UnregisterMessage(AudioProfileManager.KEY_Event_AddonRequest)
end

function DungeonVolumeController.OnEnterWorld()
    -- being in a dungeon should not override cutscenes or talking heads
    if AudioProfileManager.Flags.InCutscene or AudioProfileManager.Flags.InVoiceover then return end

    local inInstance, instanceType = IsInInstance()

    if not inInstance then return end

    if instanceType == "party" then
        DungeonVolumeController:ApplyAudioSettings()
    end
end

AudioProfileManager:RegisterOverride(DungeonVolumeController)